//////////////////////////////////////////////////////////////////////
//
// ESP definitions
//
//////////////////////////////////////////////////////////////////////


/*! \file ESP.h
    \brief Header file for ESP.C
*/

#ifndef _ESP_H_
#define _ESP_H_

#include <fstream>
#include <vector>
#include <deque>
#include "NE.h"
#include "Population.h"

class Neuron;
class Environment;
class Network;

//! User defined parameters for ESP
struct espArgs 
{
  int numpops;
  int popsize;
  Network *net;
  int seed; 
  int stagnation;
  bool grownets;
  bool minimize;
  double mutation;
  bool verbose;
  bool seednet;
  char netfile[100];
  std::string popfile;
  bool savenets;
};


typedef Population<Neuron> SubPop;


//! Esp class
class Esp : public NeuroEvolution {

private:
  std::vector< SubPop* > subPops;  //!< std::vector of points to the subpopulations.

public:
  // constructors
  Esp(struct espArgs *, Environment &, Network &);
  ~Esp();

  Network* genNetwork() { return network.newNetwork(inputDimension, 
						    numPops, 
						    outputDimension); }
  int getMinUnits() { Network *n = genNetwork(); 
                     int tmp = n->getMinUnits(); delete n; return tmp;}
  void echoParams();
  void create(); // creates a random population of Neurons
  void evolve(int);
  void recombine();
  void addSubPop();
  void endEvolution();
  void setMutation(double);
  void activateBurstMutation();
  double getAveFit() { return averageFitness; }
  bool incorporateNeurons(Network *);

  // Accessors
  double getBestFit(){  return phaseBest->getFitness(); }
  int getNumPops() { return numPops; }
  int getGeneSize() { return geneSize; }
  void savePopulation(char *);
  Neuron* getNeuron(int i, int j) { return subPops[i]->getIndividual(j); }
  int getSubPopSize() { return subPopSize; }
  int getGeneration() { return generation; }

private:
  Network &network;
  double mutationRate;  //!< Rate of mutation.
  int numPops;          //!< Number of subpopulations
  int subPopSize;       //!< Number of neurons in each subpopulation.
  int numTrials;        //!< Number of evaluations each generation.
  int generation;       //!< Counter for the number of generations.
  double prevBest;
  
  //  bool forceBurstMutation;
  std::deque<double> perfQ;   //!< A queue of the best fitness from each gen.
  double averageFitness; //!< The average fitness for a generation.
  int geneSize;          //!< The length of the neuron chromosomes. \todo move to NE?
  unsigned int stagnation;        //!< Then number of generations w/out improvement before action is taken.
  bool recombineP;       //!< Whether to recombine. \todo change name
  bool verbose;
  
  bool growNets;

  bool saveNets;
  ofstream graphfile;

  Network *bestNetwork; //!< \todo make private after debug
  Network *phaseBest; 


  Esp(const Esp &); // just for safety
  Esp &operator=(const Esp &);

  void evalPop();
  void setGeneSize();
  void setBestNetwork(Network *);
  void handleStagnation();
  void burstMutate();  
  void burstMutate(Network *);
  int removeSubPop(int);
  int removeSubPop(Network *);
  void printStats();
  void doPlotting();
  int lesionTest(Network *);
  void loadPopulation(const char *);
};



#endif

