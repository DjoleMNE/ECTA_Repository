#ifndef _POPULATION_H_
#define _POPULATION_H_

/*! \file Population.h
 */

//! A NeuronPop class
#include <typeinfo>
#include <stdio.h>
#include <vector>
#include <functional>
#include "Network.h"

class Neuron;
class Network;


template<class T>
class Population {

public:
  Population(int, T&);
  ~Population();
  //  Population(const Population &s);
  void create();
  //  virtual void create(int, int, int); // creates a random subpopulation of neurons
  struct max_fit : public std::binary_function<T*, T*, bool> {
    bool operator()(T *x, T *y) { return x->getFitness() > y->getFitness(); }
  };  
  void destroyIndividuals();

  void map( double (*map_fn)(T*))
  {
    for(std::vector<T*>::iterator i = individuals.begin(); i != individuals.end(); ++i)
      map_fn(i);
  }
  void mapv( void (T::*map_fn)())
  {
    for(std::vector<T*>::iterator i = individuals.begin(); i != individuals.end(); ++i)
      (*i->*map_fn)();
  }

  T* operator[](int i);
  void evalReset();
  T* selectRndIndividual(int i = -1);
  void average();
  void qsortIndividuals();
  void mutate(double);
  void deltify(T*);
  void popIndividual();
  void pushIndividual(T*);
  double getAverageFitness();
  inline unsigned int getNumIndividuals() { return individuals.size(); }
  inline T* getIndividual( int i ) { return individuals[i]; }
  inline unsigned int getNumBreed() { return numBreed; }
  inline void setNumBreed( int n ) { if(n > 0) numBreed = n; }
  inline int getMaxID() { return maxID; }

  std::vector<T*> individuals;  

protected:
  T &exemplar;
  bool evolvable; 
  T *bestIndividual;
  // std::vector<T*> elite;
  bool created;
  unsigned int numBreed;  //make this an Esp member of NE as percent breed
  int maxID;
};

/*

class ProbNeuron;


template< class T >
class NeuronCluster: public NeuronPop< T > {//change to public NeuronPop?
public:
  int id;
  NeuronCluster() 
    : NeuronPop<T>(0,0)
  {
    static int counter = 0;
    id = counter++;
  }
  void create() {}  //!< cannot create
  void empty();
  void pushNeuron(ProbNeuron *n);
  void deltify(Neuron *) {} 
  //These must gooooooooo
  void crossoverAvg(const std::vector<double> &parent1, 
		    const std::vector<double> &parent2, 
		    std::vector<double> &child1, 
	    	    std::vector<double> &child2);
};
 
*/ 
typedef Population<Neuron> NeuronPop;
typedef Population<Network> NetworkPop;

#include "Population.C"
#endif
