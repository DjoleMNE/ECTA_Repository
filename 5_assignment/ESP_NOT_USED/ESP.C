//////////////////////////////////////////////////////////////////////
//   Faustino Gomez  
// 
//   ESP C++ implementation.
//
//
//////////////////////////////////////////////////////////////////////

#include <typeinfo>
#include <stdio.h>
#include <stdlib.h>
#include <iostream.h>
#include <fstream.h>
#include <unistd.h>
#include <time.h>
#include <ctype.h>
#include <math.h>
#include <string.h>
//#include "/lusr/X11R6/include/GL/glut.h"
#include "ESP.h"
#include "Environment.h"
#include "Neuron.h"
#include "Network.h"
//#include "gnuplot_pipes.h"
#include "signal-handler.h"
#include <algorithm>
#include <numeric>



//extern int PLOTTING;
//int PRINT_ALL_NETS = 0;
//FILE *ALL_NETS;
//FILE *NET_FITNESS_FILE;
//gnuplot_ctrl *PLOT;
//gnuplot_ctrl *CLUSTER;



//////////////////////////////////////////////////////////////////////
//
// Esp
//
//////////////////////////////////////////////////////////////////////

Esp::Esp(struct espArgs *args, Environment &e, Network &n)
  : NeuroEvolution(e),
    network(n),                     //!< \todo move to NE.
    mutationRate(args->mutation),   //!< set mutation rate.
    numPops(args->numpops),         //!< set number of subpops.
    subPopSize(args->popsize),      //!< set subpop size.
    generation(0),                  //!< start at generation 0.
    prevBest(0.0),
    perfQ(),                        //!< initial perfQ to size 0.
    averageFitness(0.0),            //!< set ave fitness to 0.
    stagnation(args->stagnation),   //!< set stagnation criteria.
    recombineP(true),               //!< whether to reombine = yes. 
    verbose(args->verbose),
    growNets(args->grownets),       //!< whether to grow the nets.
    saveNets(args->savenets)        //!< whether to save each new best net
{
  minimize = args->minimize;        //!< minimize fitness instead of max
  
  if(args->popfile != ""){
    loadPopulation(args->popfile.c_str());
  }
  else{
    if(args->seednet) numPops = network.getNumNeurons();

    numTrials = subPopSize * 10;    //!< # of trials ~10/neuron
    setGeneSize();                  //!< calculate the input layer size and gene size
  
    //!< allocate the subpopulations.
    for (int i = 0; i < numPops; ++i) {  // construct numPops # of NeuronPops
      Neuron *tmp = new Neuron(geneSize);
      subPops.push_back( new SubPop(subPopSize, *tmp ) );
      subPops[i]->setNumBreed((unsigned int) subPopSize/4);
    }
    create();
    
    phaseBest = genNetwork();       //!< generate new net 
    bestNetwork = genNetwork();     //!< generate new net 
    phaseBest->create();            // create net            
    bestNetwork->create();    

    if(args->seednet){
      setBestNetwork( &network );
      burstMutate();
    }
  }

  //!< output a list of the parameter settings.
  echoParams();
  //initGraph();
}


//----------------------------------------------------------------------
// destructor
Esp::~Esp()
{
  for (int i = 0; i < numPops; ++i) {
    delete subPops[i];
    cout << "deleting subpop " << i << "\n";
  }
  delete &Envt;
}

//! Print out the parameters
void Esp::echoParams()
{   
  cout << "\nESP settings:\n";
  cout << "------------\n";
  cout << "Number of subpopulations : " << numPops           << endl;
  cout << "Size of subpopulations   : " << subPopSize        << endl;
  cout << "Type of neural network   : " << network.getName() << endl;
  cout << "Number of trials/gen     : " << numTrials         << endl;
  cout << "Mutation rate            : " << mutationRate      << endl;
  cout << "Stagnation               : " << stagnation        << endl;
  if(!growNets)
    cout << "Adding/removing subpops  : DISABLED\n";
  if(minimize)
    cout << "Fitness is being MINIMIZED" << endl;
  cout << "\n";
}

//----------------------------------------------------------------------
//! Set the length of neuron chromosomes.
/*! Get the size of the Neuron chromosomes from the network
   and assign it to \c geneSize.  Need to get this from 
   a network because it will vary depending of the size and 
   type of networks being used.
*/
void Esp::setGeneSize()
{
  Network *tmp = genNetwork();
  geneSize = tmp->getGeneSize();
  cout << geneSize << endl;
  delete tmp;
}

//----------------------------------------------------------------------
/*! Create the subpopulations of neurons, initializing them to 
  random weights.
*/
void Esp::create() 
{
  for (int i=0;i<numPops;++i)
    subPops[i]->create();    //!< create each subpop.
}


//! Evolve the neurons.
/*!

  Evolve is the main genetic function.  The subpopulations are first
  evaluated in the given task.  Then for each subpop the neurons are
  ranked (sorted by fitness) and recombined using crossover.  
  Mating is allowed only between the top 'numBreed' members of 
  the same subpop. The neurons are then mutated.
*/

void Esp::evolve(int gens)
{
  
  if(generation == 0) cout << "\nEvolving for " << gens << " generations.\n\n";
  gens += generation; //in case we are restarting
  while(gInterrupt == false && generation++ < gens){
    evalPop();       //!< build and evaluate networks    
    
    //skip recombination if we have just burst mutated
    if(!recombineP) recombineP = true; 
    else 
      recombine();
  }
  endEvolution();
}

//! Recombine the subpopulations.
/*! First sort the each of the subpopulations by fitness.
    Then take the top \c numBreed neurons in each subpop and 
    mate then with each other to produce enough neurons to 
    replace the bottom half of each subpop.  There is no
    mating between subpops.
*/
void Esp::recombine()
{
  int i,j,mate,excess;
  Neuron *child1, *child2;

  for (i = 0; i < numPops; ++i){
    subPops[i]->qsortIndividuals();

    excess = subPops[i]->getNumIndividuals() - subPopSize;
    for (j = 0; j < excess; ++j)
      subPops[i]->popIndividual();
    
    
    for (j = 0; j < subPops[i]->getNumBreed(); ++j){
      if(!j)  mate = lrand48() % subPops[j]->getNumBreed();
      else mate = lrand48() % j;   
      child1 = new Neuron(geneSize);
      child2 = new Neuron(geneSize);
      crossoverOnePoint(subPops[i]->getIndividual(j),
			subPops[i]->getIndividual(mate),
			child1,
			child2);
      subPops[i]->pushIndividual(child1);
      subPops[i]->pushIndividual(child2);
    }
  }
  //!< mutate the neurons in each subpop.
  for (i = 0; i < numPops; ++i){
    subPops[i]->mutate(mutationRate);
  }
}


//--------------------------------------------------------------------
//! Evaluate the networks on the task.
/*!
  Evaluation stage.  Evaluate \c numTrials networks, each containing
  \c numPops neurons selected randomly from the subpopulations.  Each 
  participating neuron receives the fitness value of the 
  network it parcipates in.
  \todo rewrite this.
*/

void Esp::evalPop()
{
  int i,j;
  double newAveFit = 0;
  Network *net, *bestNet; // pointers to current and best net

  net = genNetwork(); 
  bestNet = genNetwork(); 
  bestNet->created = true;
  net->created = true;

  // reset the neuron fitnesses
  for (i = 0; i < numPops; ++i) 
    subPops[i]->evalReset();

  numTrials = subPops[0]->getNumIndividuals() * 10;
  //cout << subPops[0]->getNumIndividuals() << endl;
  for(i = 0; i < numTrials; ++i) {
    if(gInterrupt) break;

    // Build the network
    for(j = 0; j < numPops; ++j) 
      net->setNeuron( subPops[j]->selectRndIndividual(), j );
    
    net->resetFitness(); //!< need to do this because we are using the
                         //!< same underlying network for all trials
    //evaluate the network , should addFitness and inc tests here

    newAveFit += Envt.evaluateNetwork(net);
    
    if(verbose)
      if(minimize) cout << "fitness : " << 1.0/net->getFitness() + 1.0 << "\n";
      else cout << "fitness " << i << ": " << net->getFitness() << "\n";

    net->addFitness(); // add network fitness to its neurons 

    if(net->getFitness() > bestNet->getFitness()){ 
      bestNet->setNetwork(net);
      if (bestNet->getFitness() >= Envt.maxFitness )
	break;
    }
  }
  
  if(bestNet->getFitness() > phaseBest->getFitness() ) 
    *phaseBest = *bestNet; 
  if(bestNet->getFitness() > bestNetwork->getFitness() ) 
    setBestNetwork( phaseBest );

  averageFitness = newAveFit/numTrials;
  
  perfQ.push_front(phaseBest->getFitness());
  
  // if performance stagnates, do something
  if( perfQ.size() >= stagnation && 
      phaseBest->getFitness() <= perfQ[stagnation-1] )
    handleStagnation();

  
  if(minimize) //!< \todo should move these output statements to separate area
    cout << "gen " << generation 
	 << ": best " << 1.0/bestNet->getFitness() + 1.0
	 << ", task best " << 1.0/phaseBest->getFitness() + 1.0
	 << ", overall best " << 1.0/bestNetwork->getFitness() + 1.0
	 << "\n";
  else 
    cout << "gen " << generation 
	 << ": best " << bestNet->getFitness()   
	 << ", task best " << phaseBest->getFitness() 
	 << ", overall best " << bestNetwork->getFitness()
	 << "\n";
  
}
  

//----------------------------------------------------------------------
//! Make a decision about what to do when performace stagnates.
void Esp::handleStagnation(){
  perfQ.clear();   

  if(phaseBest->getFitness() <= prevBest ){
    if (growNets && !removeSubPop(phaseBest))
      addSubPop();
    // Envt.simplifyTask();
  }
  else  prevBest = phaseBest->getFitness();
  //if(evolveNetLevel) networkLevel->burstMutate( bestNetwork );


  burstMutate();  
  phaseBest->resetFitness();
}


//----------------------------------------------------------------------
//! Burst mutate the subpops.
void Esp::burstMutate()
{
  burstMutate(bestNetwork);
}

void Esp::burstMutate(Network *net)
{
  cout << "#BURST MUTATION STARTED\n";
  recombineP = false;
  for(int i=0; i < numPops; ++i){
    if(i < net->getNumNeurons() )
      subPops[i]->deltify( net->getNeuron(i) );
  }
}

/*! \todo Need to make sure that net a phase best are the same size.
          This could be handled in the assigment operator.
*/
void Esp::setBestNetwork(Network *net)
{
  char fname[100];

  *bestNetwork = *net; 
  //**bestNetwork->setNetwork(net);

  sprintf(fname , "net%u-%d-%f", getpid(), generation, bestNetwork->getFitness() );
  if(bestNetwork->getFitness() >= Envt.maxFitness){
    phaseBest->resetFitness();
    bestNetwork->resetFitness();
    perfQ.clear();
    cout << "Task Completed" << endl;
    if( Envt.getIncremental() )
      Envt.nextTask();
    else
      endEvolution();
  }
  //make function setPhaseBest that alway updates perfQ
  //perfQ.push_front(phaseBest->getFitness());
  if(saveNets) bestNetwork->saveText(fname);
}



/////////////////////////////////////////////////////////////////////
//
// ESP I/O fns



/*! Load subpopulations of neurons from a file.  This method
    assumes that the correct network type has already been 
    set.
  */
void Esp::loadPopulation(const char *fname)
{
  int i,j,k, type;
  ifstream popIn;

  popIn.open(fname);
  
  if(!popIn){
    cerr << "\nError - cannot open " << fname << " (in Esp::loadPopulation)" << endl;
    exit(1);
  }

  cout << "Loading subpopulations from file: " << fname << endl;
  popIn >> type;
  popIn >> generation;
  cout << generation << endl;
  popIn >> numPops;
  cout << numPops << endl;
  popIn >> geneSize;
  cout << geneSize << endl;
  popIn >> subPopSize;
  cout << subPopSize << endl;
  numTrials = subPopSize * 10;

  subPops.clear();
  double tmp;
  std::string id = "";

  for(i = 0 ; i < numPops ; ++i) {
    subPops.push_back( new SubPop( subPopSize, *network.getNeuron(0) ) );  
    subPops.back()->create();
    cout << "." << flush;
    for(j = 0 ; j < subPopSize ; ++j) {
      for(k = 0 ; k < geneSize ; ++k) {
	popIn >> tmp;
	subPops[i]->getIndividual(j)->setWeight(k, tmp);
      }
    }
  }
  cout << "DONE" << endl;
  popIn.close();
  //  savePopulation("tmp");  
  //exit(3);
} 


//---------------------------------------------------------------
/*! Save the neuron subpopulations to a file as text
  \todo add saving of netlevel
*/
void Esp::savePopulation(char *fname)
{
  int i,j;
  ofstream popOut;

  popOut.open(fname);

  if(!popOut){
    cerr << "\nError - cannot open " << fname << " (in Esp::savePopulation)" << endl;
    exit(1);
  }

  cout << "\nSaving population to " << fname << endl;
  
  popOut << network.getType() << endl;
  popOut << generation << endl;
  popOut << numPops << endl;
  popOut << geneSize << endl;
  popOut << subPopSize << endl; 

  //if(NetworkLevel) 
  //  popOut << networkLevel;
    
  for(i=0;i<numPops;++i) 
    popOut << *subPops[i] << endl;
  
  popOut.close();
} 


//----------------------------------------------------------------------
void Esp::endEvolution()
{
  char fname[100];
  char popfile[100];

  printStats();
  //printf("\nSave best net? ");
  //tmp = getchar()-48;
  // scanf("%c", &tmp);     
  //printf("%c \n", tmp);
  sprintf(fname , "net%u", getpid() );
  sprintf(popfile , "pop%u", getpid() );

  Envt.evaluateNetwork(bestNetwork);

  if(minimize)
    printf("phase best %f \n", 1.0/bestNetwork->getFitness() + 1.0);
  else 
    printf("phase best %f \n", bestNetwork->getFitness() );

  bestNetwork->saveText(fname);

  savePopulation(popfile);
  
  cout << "BYE!\n";
  exit(0);
}


void Esp::printStats()
{
  cout << "\nTotal number of network evaluations : " << evaluations << endl;
}

////////////////////////////////////////////////////////////////////////////
//
// Code to add/remove subpops
//
//
///////////////////////////////////////////////////////////////////////////


//----------------------------------------------------------------------
//! Add a new subbpop. In effect: add a unit to the networks.
void Esp::addSubPop()
{
  int i,j;
   
  //  for(i=0; i < numPops; ++i)  //freeze best network? false=yes
  //  subPops[i]->evolvable = true;    // true = no.
  ++numPops;                    //inc # subpops
  setGeneSize();                //adjust geneSize
  Network *n = genNetwork();    //need a Network to resize the neurons correctly
  n->create();
  for(i=0; i < numPops-1; ++i)  
    for(j=0; j < subPops[i]->getNumIndividuals() ; ++j)  
      n->growNeuron( subPops[i]->getIndividual(j) ); 

  //  phaseBest->addNeuron();  // add a neuron to the phaseBest and bestNetwork.
  phaseBest->resetFitness();
  //bestNetwork->addNeuron(); 
  Neuron *tmp = new Neuron(geneSize);
  SubPop *newSp = new SubPop(subPopSize, *tmp ); //constuct and create
  newSp->create();                         //  new subpop
  subPops.push_back( newSp ); // put its pointer in Esp's vector 
                              //  of sp pointers.
  cout << "Adding SUBPOP " << numPops << endl;
  cout << "Now " << numPops << " subpops" << endl;
}

//----------------------------------------------------------------------
//! Opposite of addSubPop.
int Esp::removeSubPop( Network *net )
{
  int sp;

  sp = lesionTest(net);  //see which (if any) subpop can be removed
  return ( removeSubPop(sp) );  // remove it.
}

//----------------------------------------------------------------------
int Esp::removeSubPop(int sp)
{ 
  if ( sp >= 0       && 
       sp < numPops  && 
       numPops > getMinUnits() )
    {
      int i,j;
      // cout << numPops << " " << getMinUnits() << endl;
      --numPops;
      setGeneSize();
      Network *n = genNetwork();
     
      delete subPops[sp];
      subPops.erase( subPops.begin()+sp );      
      for(i=0; i < numPops; ++i)  // remove connection to neurons in spops
	for(j=0; j < subPops[i]->getNumIndividuals(); ++j)  
	  n->shrinkNeuron( subPops[i]->getIndividual(j), sp );
      //      phaseBest->removeNeuron( sp ); //handled is Net::operator=
      //bestNetwork->removeNeuron( sp );

      cout << "Remove SUBPOP " << sp+1 << "\n";
      cout << "Now " << numPops << " subpops\n";
      return 1;      
    }
  else
    return 0;
}


#define LESION_THRESHOLD 0.8
/*! \todo 
    May want to reset fitness here or automatically reset it
    when lesioned is set by lesion(int).  Make lesioned private to
    \a Network so that even subclasses cannot access is directly.
    Think about this because there are cases were you might want
    to repeatedly eval with a particular lesion.  Have lesion(int)
    check if int is different since last eval.
*/

int Esp::lesionTest( Network *net )  
{
  int i,j,sp;
  double lesionFitness, max = 0.0, min = 1000000000;

  for(i=0; i < 1; ++i)
    Envt.evaluateNetwork(net);
  double ulfit = net->getFitness();  
  if(minimize) cout << "UNlesioned :" << 1.0/ulfit + 1.0 << endl;
  else cout << "UNlesioned :" << ulfit << endl;
  for(i=0; i < net->getNumNeurons(); ++i){
    net->resetFitness();
    net->getNeuron(i)->lesioned = true;
    for(j=0; j < 1; ++j)
      Envt.evaluateNetwork(net);
    lesionFitness = net->getFitness();
    if(minimize) cout << "lesion " << i << ":" << 1.0/lesionFitness + 1.0 << endl;
    else cout << "lesion " << i+1 << ":" << lesionFitness << endl;
    net->getNeuron(i)->lesioned = false;
    if(minimize){
      if(lesionFitness < min){
	min = lesionFitness;
	sp = i;
      }
    }
    else
      if(lesionFitness > max){
	max = lesionFitness;
	sp = i;
      }
  }
  if(minimize){
    if(min <= (ulfit * LESION_THRESHOLD) )
      return sp;
  }
  else if(max >= (ulfit * LESION_THRESHOLD) )
    return sp;
  else return -1;
}

