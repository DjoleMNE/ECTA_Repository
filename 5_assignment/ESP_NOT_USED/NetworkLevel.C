#include <stdio.h>
#include <algorithm>
#include <numeric>
#include "NetworkLevel.h"
#include "Neuron.h"
#include "Network.h"
#include "Environment.h"
#include "ESP.h"
#include "Population.h"
#include <typeinfo>

#define DUMP 0

//////////////////////
// send new network to ESP is it has been successfully
// inserted into the netpop
/////////////////////
NetPop::NetPop(Esp *e, int n)
  : numNets(n),
    espPtr(e),
    active(false),  // should this be true?
    mutationRate(0.1)
{
  networks = new NetworkPop(numNets, *e->genNetwork() );
  networks->create();
  reset();
}


#include "CartPole.h"
#include <typeinfo>

//evaluate the networks and sort them 
void NetPop::reset()
{
  //CartPole *cp = dynamic_cast<CartPole *>(&espPtr->Envt);
  //double (*func)(Network *) = &(espPtr->Envt.evaluateNetwork);
  //func = &Envt.evaluateNetwork
  // networks->map(&Environment::evaluateNetwork);
  networks->qsortIndividuals();
}


// Need to work on this
void NetPop::cycleEvolution(int cycles = 1)
{
  //  for(int i = 0 ; i<numNets; ++i)
  // cout << getNetwork(i)->getFitness() << " ";
  //cout << endl;
  if(active){
    cout << "*"; flush(cout);
    for(int i = 0; i < cycles; ++i) {
      recombine();
    }
    active = false;
  }
}


bool NetPop::insertNetHeap(Network *net)
{
}
/*
  if(net->getFitness() > networks->front()->getFitness()){   //worstFitness){ 
    Network *tmp;
    tmp = espPtr->genNetwork();
    tmp->create();
    *tmp = *net;
    pop_heap(networks->begin(), networks->end(), max_fit() );
    delete networks->back();
    networks->pop_back();
    networks->push_back(tmp);
    push_heap(networks->begin(), networks->end(), max_fit() );
    return 1;
  }
  else
    return 0;
}
*/
bool NetPop::insertNet(Network *net)
{
  int i = 0;
  Network *tmp;
  bool inserted = false;
  
  /*  if (DUMP){  
    fprintf(NETS,"ID %d\n", tmp->getID() );
    tmp->printWeights(NETS);
  }
  */
    
  if(net->getFitness() > (getNetwork(numNets-1)->getFitness() + espPtr->Envt.getTolerance()) ){
    tmp = net->newNetwork(net->numInputs, net->getNumNeurons(), net->numOutputs);
    //    tmp->create();
    *tmp = *net;
    while(i < numNets && !inserted){
      if( *tmp != *getNetwork(i) ){
	if(tmp->getFitness() > getNetwork(i)->getFitness()){ 
	  networks->individuals.insert( networks->individuals.begin()+i, tmp ); 
	  //!< get rid of individuals make it private and have accessors
	  //	  if (DUMP) fprintf(NETS,"INSERTED %d\n",i);
	  networks->popIndividual();
	  inserted = true;
	  active = true;
	  //	  cout << "INSERT" << endl;
	  //	printf("%f ", net->getFitness());
	  //fflush(stdout);
	  //printf("NUM NETS %d fit %f Netpop best %f worst %f\n", numNets, net->getFitness(), bestFitness, worstFitness);
	}
      }
      else i = numNets;
      i++;
    }
    if(!inserted) delete tmp;
  }
  
  return inserted;
}




void NetPop::recombine()
{
  int tmp; 
  Network *child1 = espPtr->genNetwork();
  Network *child2 = espPtr->genNetwork(); 
  child1->create();
  child2->create();
  
  for(int i = 0; i < numNets; ++i) {
    tmp = lrand48()% numNets;  //(i+1)
    if(getNetwork(i) != getNetwork(tmp) ){
         
      espPtr->crossoverOnePoint(getNetwork(i), getNetwork(tmp), 
				child1, child2);
      child1->mutate(mutationRate);  
      //child2->mutate(mutationRate);
      
      //*child1 = *getNetwork(i)->perturb();
      *child2 = *getNetwork(i)->perturb();

      espPtr->Envt.evaluateNetwork(child1);
      espPtr->Envt.evaluateNetwork(child2);
      
      insertNet(child1); 
      espPtr->incorporateNeurons( child1 );

      insertNet(child2); 
      espPtr->incorporateNeurons( child2 );
      
    }
  }
  //  printNets(NETS);
  delete child1;
  delete child2;
}










/*
void NetPop::removeNet(int n)
{
  if( numNets > 1){
    printf("Removing net %d, Size %d, Fit %f\n", n, numNets, 
	   networks[n]->getFitness());
    delete networks[n];
    networks->erase(networks->begin()+n);
    --numNets;
  }
}


void NetPop::burstMutate()
{
  int i,j;

  sortNets();
  for(i = 1; i < numNets; ++i){
    for(j= 0; j < networks[0]->getNumNeurons(); ++j)
      networks[i]->hiddenUnits[j]->perturb( *networks[0]->hiddenUnits[j] );
  }
}

*/
void NetPop::addNeuron()
{
  for(unsigned int i = 0; i < networks->getNumIndividuals(); ++i)
    getNetwork(i)->addNeuron();
}


void NetPop::removeNeuron(int sp)
{
  for(unsigned int i = 0; i < networks->getNumIndividuals(); ++i)
    getNetwork(i)->removeNeuron(sp);
}

/*
void NetPop::burstMutate(Network *net)
{
  int i,j;
  Network *tmpNet = espPtr->genNetwork();

  tmpNet->create();
  *tmpNet = *net;

  printf("Burst mutating L2\n");
  
  for (i = 0; i < numNets; ++i) 
    for (j = 0; j < net->getNumNeurons(); ++j) 
      networks[i]->hiddenUnits[j]->perturb( *tmpNet->hiddenUnits[j] ); 
 
  reset();
  //printNets(stdout); 
  cycleEvolution(50); // do this so the mutated nets can improve
                      // before ESP start to insert network and erase
                      // these new nets

}

*/
