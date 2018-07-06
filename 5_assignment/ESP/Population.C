//////////////////////////////////////////////////////////////////////
//
// Population
//
//////////////////////////////////////////////////////////////////////

#include <iostream.h>
#include <algorithm>
#include <numeric>
#include <typeinfo>
#include "Neuron.h"




///////////////////////////////////////////////////////////////////////
/*!  We leave method \a create to 
     actually create the neurons.
     \todo mentioned elsewhere: numBreed needs to be a percentage 
     that is set by the algorithm
*/
template< class T >
Population<T>::Population(int size, T &ex)  
  : exemplar(ex),
    evolvable(true),
    individuals(size),
    //elite(),
    created(false),
    maxID(0)
{
  //T* tmp;
  //assert(NULL != dynamic_cast<Neuron*>(tmp) ||
  //	 NULL != dynamic_cast<Network*>(tmp) );
  // T *tmp = new T();
  //assert(NULL != dynamic_cast<Neuron*>(tmp));
  numBreed =  (unsigned int) individuals.size()/4;
}

//-----------------------------------------------------------------------------------
//---------------------------------------------------------------------
//! Create the Population.
/*! Create the random Population set the member \a created to \c true.  
    \todo { get rid of \c evolvable; return \c bool; output message to stderr
    if called when created = \c true}
*/
template< class T >
void Population<T>::create() 
{
  if(!created)
    if(evolvable){
      for (unsigned int i = 0; i < individuals.size(); ++i) {
	individuals[i] = exemplar.clone();
	individuals[i]->create();
      }
      created = true;
    }
  maxID = individuals.back()->getID();
  bestIndividual = individuals.front();
}


//---------------------------------------------------------------------
//! destructor
template< class T >
Population<T>::~Population()
{
  destroyIndividuals();
}


//--------------------------------------------------------------------
//! Destroy the Neurons in the Population.
/*! The Neurons are destroyed without deleting the
    Population.  If \a create is called after calling
    this method new neurons will be create and placed
    in the Population.
 */
template< class T > 
void Population<T>::destroyIndividuals()
{
  cout << "destroying individuals\n"; 
  
  for (unsigned int i = 0; i < individuals.size(); ++i)    
    delete individuals[i];
  created = false;
}


//----------------------------------------------------------------------
template< class T >
T* Population<T>::operator[](int i)
{
  if((i >= 0) && (i < individuals.size()))
    return individuals[i];
  else
    cerr << "Index out of bounds\n ";
}


//----------------------------------------------------------------------
//! reset fitness and test vals of all Neurons
/*! \todo Change name to reset? Change \c Network::resetFitness() to
    \c Network::reset() or change \c Neuron::reset() to \c 
    Neuron::resetFitnes()
 */
template< class T >
void Population<T>::evalReset()
{
  mapv(&T::resetFitness);
}
/*
  for(unsigned int i=0; i < individuals.size(); ++i)  {
    individuals[i]->resetFitness();
  }
}
*/


//----------------------------------------------------------------------
//! select an individual at random
template< class T >
T* Population<T>::selectRndIndividual(int i)
{
  if((i > 0) && (i < (int) individuals.size()))
    return individuals[lrand48() % i];
  else
    return individuals[lrand48() % individuals.size()];
}


//----------------------------------------------------------------------
//! Sort the neurons by fitness in each NeuronIndividuals. 
/*!
    using quicksort.
 */
template< class T >
void Population<T>::qsortIndividuals()
{
  sort(individuals.begin(), individuals.end(), max_fit() );
  bestIndividual = individuals.front(); 
}


//----------------------------------------------------------------------
//! Mutate half of the neurons with cauchy noise.
/*! \todo Should be a \a NeuroEvolution or \a Neuron method
 */
template< class T >
void Population<T>::mutate(double mutrate)
{
  for (unsigned int i = numBreed*2 ; i < individuals.size(); ++i) 
    if (drand48() < mutrate) 
      individuals[i]->mutate();
}


//---------------------------------------------------------------------
//! Used to perform "delta-coding" like burst mutation.
/*! Make each Neuron a perturbation of the neuron in 
    the best network that corresponds to that \a subIndividuals.
\todo { change name to burst mutation }
*/
template< class T >
void Population<T>::deltify(T *best)
{
  //  Neuron tmp = *individuals[0];
  for(unsigned int i= 0; i < individuals.size(); ++i){
    individuals[i]->perturb( best );  
  }
}


//! Remove an individual from the \a Population.
/*!
   */


template< class T >
void Population<T>::popIndividual()
{
  if(individuals.size() > 0){
    delete  individuals.back();
    individuals.pop_back();
  }
}

//! Add an individual to the \a Population.
/*!
  The individual is added to the \a Population by pushing the pointer to it
  onto the back of the std::vector \c individuals.  
 */
template< class T >
void Population<T>::pushIndividual(T *n)
{
  if(n->getID() > maxID) maxID = n->getID(); // keep track of newest indiv.

  individuals.push_back( n );
}

template< class T >
double Population<T>::getAverageFitness()
{
  double sum = 0;

  for (unsigned int i = 0 ; i < individuals.size(); ++i) 
    sum += individuals[i]->getFitness();
  return sum/individuals.size();
}


//-----------------------------------------------------------------------------
template <class T>
ostream& operator<<(ostream& os, Population<T> &p)
{
  for(unsigned int i=0; i < p.getNumIndividuals(); ++i)
    os << *p.getIndividual(i) << endl;
  
  return os;
}


