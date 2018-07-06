#include <algorithm>
#include "NE.h" 
#include "Environment.h"
#include "Neuron.h"
#include "Network.h"


NeuroEvolution::NeuroEvolution(Environment &e) 
  : inputDimension(e.getInputDimension() ),
    outputDimension(e.getOutputDimension() ),
    evaluations(0),  
    Envt(e)
{
  Envt.setNePtr(this);
}
//----------------------------------------------------------------------
//! Arithmetic crossover

void NeuroEvolution::crossoverArithmetic(Neuron *parent1, 
					 Neuron *parent2, 
					 Neuron *child1, 
					 Neuron *child2)
{
  double a,b;
  register unsigned int i;
  
  a=0.25;
  b=0.75;
  
  child1->parent1 = parent1->getID();
  child1->parent2 = parent2->getID();
  child2->parent1 = parent1->getID();
  child2->parent2 = parent2->getID();
  child1->resetFitness();
  child2->resetFitness();  
  for (i=0 ;i < parent1->getSize(); ++i) {
    child1->setWeight(i, a * parent1->getWeight(i) + (b * parent2->getWeight(i)) );
    child2->setWeight(i, a * parent2->getWeight(i) + (b * parent1->getWeight(i)) );
   }
}

//! Another linear combination crossover.
void NeuroEvolution::crossoverEir(Neuron *parent1, 
				  Neuron *parent2, 
				  Neuron *child1, 
				  Neuron *child2)
{
  double i,d2,d = 0.4; //was int for some time (?)
  d2 = 2*d + 1;
  child1->parent1 = parent1->getID();
  child1->parent2 = parent2->getID();
  child2->parent1 = parent1->getID();
  child2->parent2 = parent2->getID();
  
  for (i=0;i< (int) parent1->getSize();++i) {
    child1->setWeight(i, parent1->getWeight(i) + (((drand48() * d2) - d) *
					      (parent2->getWeight(i) - parent1->getWeight(i))) );
    child2->setWeight(i, parent2->getWeight(i) + (((drand48() * d2) - d) *
					      (parent1->getWeight(i) - parent2->getWeight(i))) );
  }

/*
  child1->p1 = parent1->sp;
  child1->p2 = parent2->sp;
  child2->p1 = parent1->sp;
  child2->p2 = parent2->sp;
  child1->sp = parent1->sp;
  child2->sp = parent1->sp;
*/
}


//! One-point crossover for neurons
/*!
    Two parent neurons are mated to produce two offspring 
    by exchanging chromosal substrings at a random crossover point.
*/

void NeuroEvolution::crossoverOnePoint(Neuron *parent1, 
				       Neuron *parent2, 
				       Neuron *child1, 
				       Neuron *child2)
{
  //find crossover point
  double tmp;
  int cross1 = lrand48() % parent1->getSize();
  if(parent1->getSize() > parent2->getSize())
    cross1 = lrand48() % parent2->getSize();
  *child1 = *parent2;
  *child2 = *parent1;

  child1->parent1 = parent1->getID();
  child1->parent2 = parent2->getID();
  child2->parent1 = parent1->getID();
  child2->parent2 = parent2->getID();
  
  child1->resetFitness();
  child2->resetFitness();
  for(unsigned int i = 0; i < cross1; ++i){
    tmp = child2->getWeight(i);
    child2->setWeight( i, child1->getWeight(i) );
    child1->setWeight( i, tmp );
  }
  //  swap_ranges(child1->weight.begin(), child1->weight.begin()+cross1, child2->weight.begin());
}
/*

void NeuroEvolution::crossoverOnePoint( Neuron *parent1, 
				        Neuron *parent2, 
					Neuron *child1, 
					Neuron *child2)
{
  //find crossover point
  if(child1) delete child1;
  if(child2) delete child2;

  child1 = parent1->crossoverOnePoint(*parent2);
  child2 = parent2->crossoverOnePoint(*parent1);
}
*/

//! One-point crossover for Networks
/*!
    Two parent Networks are mated to produce two offspring 
    by exchanging chromosal substrings at a random crossover point.
*/

void NeuroEvolution::crossoverOnePoint(Network *parent1, 
				       Network *parent2, 
				       Network *child1, 
				       Network *child2)
{
  int crossNeuron = lrand48()%parent1->getNumNeurons();
    
  *child1 = *parent1;
  *child2 = *parent2;
   if(parent1->getNumNeurons() > parent2->getNumNeurons())
    crossNeuron = lrand48()%parent2->getNumNeurons();
  child1->resetFitness();
  child2->resetFitness();
  crossoverOnePoint(parent1->getNeuron(crossNeuron),
		    parent2->getNeuron(crossNeuron),
		    child1->getNeuron(crossNeuron),
		    child2->getNeuron(crossNeuron));
  child1->setParent(1, parent1->getID() );
  child1->setParent(2, parent2->getID() );
  child2->setParent(1, parent1->getID() );
  child2->setParent(2, parent2->getID() );
}



//! N-point crossover for Networks
/*!
    Two parent Networks are mated to produce two offspring 
    by exchanging chromosal substrings at N random crossover points.
*/
void NeuroEvolution::crossoverNPoint(Network *parent1, 
				       Network *parent2, 
				       Network *child1, 
				       Network *child2)
{
  *child1 = *parent1;
  *child2 = *parent2;
  child1->resetFitness();
  child2->resetFitness();
  for(int i = 0; i < parent1->getNumNeurons(); ++i){
    crossoverOnePoint(parent1->getNeuron(i),
		      parent2->getNeuron(i),
		      child1->getNeuron(i),
		      child2->getNeuron(i));
  }
  child1->setParent(1, parent1->getID() );
  child1->setParent(2, parent2->getID() );
  child2->setParent(1, parent1->getID() );
  child2->setParent(2, parent2->getID() );
}

//check for size
void NeuroEvolution::crossoverArithmetic(Network *parent1, 
					 Network *parent2, 
					 Network *child1, 
					 Network *child2)
{
  child1->resetFitness();
  child2->resetFitness();
  
  for(int i = 0; i < parent1->getNumNeurons(); ++i)
    crossoverArithmetic(parent1->getNeuron(i), parent2->getNeuron(i),
			child1->getNeuron(i), child2->getNeuron(i) );
  child1->setParent(1, parent1->getID() );
  child1->setParent(2, parent2->getID() );
  child2->setParent(1, parent1->getID() );
  child2->setParent(2, parent2->getID() );
}

