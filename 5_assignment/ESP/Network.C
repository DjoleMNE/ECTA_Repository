//////////////////////////////////////////////////////////////////////
//
// Network
//
//////////////////////////////////////////////////////////////////////

#include <math.h>
#include <stdio.h>
#include <iostream.h>
#include <fstream.h>
#include "Network.h"
#include "Neuron.h"
 

double rndCauchy(double wtrange);



std::ostream& operator<<(std::ostream& os, Network &net)
{
  os << net.getName() << " " << net.getID() << ": "  << endl;
  for(int i=0; i <  net.getNumNeurons(); ++i)
    os << *net.getNeuron(i) << endl;
  
  return os;
}

//////////////////////////////////////////////////////////////
// Network
//
Network::Network(int in, int hid, int out)
 : activation(hid), 
  hiddenUnits(hid),
  created (false),
  numInputs(in),
  numOutputs(out),
  bias(0.0), 
  trials(0),
  fitness(0.0),  
  parent1(-1),
  parent2(-1)

{
  static int counter = 0;
  id = ++counter;  
}


Network::~Network()
{
  deleteNeurons();
}


inline 
double Network::sigmoid(double x, double slope = 1.0)
{
  return (1/(1+exp(-(slope * x)) ) );
}

//! delete the neurons
void Network::deleteNeurons()
{
  if(created)
    for(unsigned int i = 0; i < hiddenUnits.size(); ++i) 
      delete hiddenUnits[i];
  created = false;
}

//! delete a network w/out deleting its neurons
void Network::releaseNeurons()
{
  for(unsigned int i = 0; i < hiddenUnits.size(); ++i)
    hiddenUnits[i] = NULL;
  delete this;
}

//! Set the Fitness 
void Network::setFitness(double fit)
{
  ++trials;
  fitness += fit;
}


double Network::getFitness() 
{
  if(trials)
    return (double) fitness/trials; 
  else 
    return fitness;
}

  
void Network::create() 
{
  //if(created) deleteNeurons();
  for (unsigned int i = 0; i < hiddenUnits.size(); ++i) {
    hiddenUnits[i] = new Neuron(geneSize);
    hiddenUnits[i]->create();
  }
  created = true;
}


bool Network::sizeEqual(Network &n)
{
  bool equal = true;
  
  if (!created || !n.created)
    equal = false;
  else if (hiddenUnits.size() != n.hiddenUnits.size())
    equal = false;
  else
    for(unsigned int i = 0; i < hiddenUnits.size(); ++i)
      if(hiddenUnits[i]->getSize() != n.hiddenUnits[i]->getSize()){
	 equal = false;
	 break;
      }

  return equal;
}



void Network::operator=(Network &n)
{
  if(!n.created){
    cerr << "assigning uncreated Network; Network::operator=" << endl;
    abort();
  }
  //check if nets are of the same type
  if(type != n.type ){
    cerr << "assigning networks of type " << n.getName()
         << " to type " << getName() << "; Network::operator=" << endl;
    abort();
  }

  activation = n.activation;
  trials  = n.trials;
  fitness = n.fitness;
  parent1 = n.parent1;
  parent2 = n.parent2;
  geneSize = n.geneSize;
  numInputs = n.numInputs;
  numOutputs = n.numOutputs;
  bias = n.bias;

  deleteNeurons();    //if created delete the neurons
  hiddenUnits.clear(); // resize(n.(int) hiddenUnits.size());
  //create();
  for(int i = 0; i < n.getNumNeurons(); ++i) {
    hiddenUnits.push_back( new Neuron(geneSize) );
    *hiddenUnits[i] = *n.hiddenUnits[i]; 
  }
  
  created = true;
}

bool Network::operator==(Network &n)
{
  bool equal = true;

  if(hiddenUnits.size() != n.hiddenUnits.size())
    equal = false;
  else
    for(unsigned int i = 0; i < hiddenUnits.size(); ++i){
      if(*hiddenUnits[i] != *n.hiddenUnits[i]){
	equal = false;
	break;
      }
    }
  return equal;
}

bool Network::operator!=(Network &n)
{
  if(*this == n) 
    return false;
  else 
    return true;
}

void Network::setNeuron(Neuron *n, int position)
{
  hiddenUnits[position] = n;
}

inline 
Neuron* Network::getNeuron(int i) 
{ 
  if (i >= 0 && i < (int) hiddenUnits.size())
    return hiddenUnits[i];
  else 
    cerr << "Index out of bounds; Network::getNeuron" << endl;
}

inline
int Network::getParent(int p)
{
  if(p == 1)
    return parent1;
  else if(p == 2)
    return parent2;
  else
    cerr <<  "Parent must be 1 or 2; Network::getParent" << endl;
}

inline
void Network::setParent(int p, int id)
{
  if(p == 1)
    parent1 = id;
  else if(p == 2)
    parent2 = id;
  else
    cerr <<  "Parent must be 1 or 2; Network::getParent" << endl;
}

void Network::setNetwork(Network *n)
{
  parent1 = n->parent1;
  parent2 = n->parent2;
  fitness = n->fitness;
  trials = n->trials;
  for(unsigned int i = 0; i <  hiddenUnits.size(); ++i) 
    hiddenUnits[i] = n->hiddenUnits[i];

}

void Network::addFitness()
{
  for(unsigned int i = 0; i < hiddenUnits.size(); ++i)
    hiddenUnits[i]->addFitness(fitness);
}

void Network::resetActivation()
{
  for(unsigned int i=0; i < hiddenUnits.size();++i)
    activation[i] = 0.0;
}


//  void Network::perturb(Network *net)
//  {
//    for(int i=0;i<(int) hiddenUnits.size();++i){
//      net->setNeuron( hiddenUnits[i]->perturb(0.2), i);
//    }
//  }

//used by complete
void Network::perturb(Network *net)
{
  for(unsigned int i=0 ; i < hiddenUnits.size();++i){
    hiddenUnits[i]->perturb(net->hiddenUnits[i], rndCauchy, 0.01);
  }
}

//---------------------------------------------------------------------
//! Same as above but called on self and returns new Network
Network* Network::perturb(double coeff = 0.3)
{
  Network *n = this->clone();
  //*n = *this;
  for(unsigned int i = 0 ; i < hiddenUnits.size() ; ++i) 
    n->hiddenUnits[i] = hiddenUnits[i]->perturb(0.05);
  n->created = true;
  return n;
}

void Network::mutate(double mutRate)
{
  if(drand48() < mutRate)
    hiddenUnits[lrand48()%(int) hiddenUnits.size()]->mutate();
}
  
   

void Network::printActivation(FILE *file)
{
  for(unsigned int i=0; i < hiddenUnits.size(); ++i){
    fprintf(file,"%f ", activation[i]);
  }
  fprintf(file,"\n");
}

//----------------------------------------------------------------------

//may eliminate these two or give it a better interface
void Network::addConnection(int locus)
{
  // if(locus < geneSize)
    for(unsigned int i=0; i < hiddenUnits.size(); ++i)
      hiddenUnits[i]->addConnection(locus);
}

//----------------------------------------------------------------------
// opposite of addConnection.
void Network::removeConnection(int locus)
{
  if(locus < geneSize)
    for(unsigned int i=0; i < hiddenUnits.size(); ++i)
      hiddenUnits[i]->removeConnection(locus);
}


//----------------------------------------------------------------------
//
void Network::saveText(char *fname)
{
  int i,j;
  FILE *fptr;
  char newname[100];

  strcpy(newname, fname);
  strcat(newname, name.c_str() );

  if ((fptr = fopen(fname,"w")) == NULL) {
    printf("\n Error - cannot open %s (in Network::saveText)",fname);
    exit(1);
  }
  
  printf("Saving network to %s\n", fname);
  fprintf(fptr, "%d\n", type);
  fprintf(fptr, "%d\n", numInputs ); 
  fprintf(fptr, "%d\n", (int) hiddenUnits.size());
  fprintf(fptr, "%d\n", numOutputs);  
   
  for(i=0;i<(int) hiddenUnits.size();++i){
    for(j=0;j<geneSize;++j)
      fprintf(fptr, "%.50f ", hiddenUnits[i]->getWeight(j));
    fprintf(fptr, "\n"); 
  }
  fclose(fptr);
}






