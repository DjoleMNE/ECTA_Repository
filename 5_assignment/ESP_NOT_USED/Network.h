#ifndef _NETWORK_H_
#define _NETWORK_H_
/*! \file Network.h
 */

#include <vector>
#include <string>
#include "Environment.h"

class Neuron;

//! Neural network base class
/*! Virtual class for neural networks consisting
    of a \c std::vector of \a Neurons that are connected
    through the implementation is an \a activation
    function in the derived classes.
*/
class Network {//: public subPop {
protected:
  std::vector<double> activation;
  std::vector<Neuron*> hiddenUnits;

public:
  bool created;
  int numInputs; 
  int numOutputs;
  double bias;

  Network(int, int, int);
  Network(const Network &n){}
  
  virtual ~Network();
  virtual Network* newNetwork(int, int, int) = 0;
  //  virtual Network* newNetwork(int, Neuron *n) = 0;
  virtual Network* clone() = 0;
  virtual void growNeuron( Neuron * ) = 0;
  virtual void shrinkNeuron( Neuron *, int ) = 0;
  virtual void addNeuron() = 0;
  virtual void removeNeuron(int) = 0;
  virtual void activate(std::vector<double> &, std::vector<double> &) = 0; 
  inline virtual int getMinUnits() { return 1; }

  void releaseNeurons();
  void deleteNeurons();
  void operator=(Network &n);
  bool operator==(Network &n);
  bool operator!=(Network &n);
  void create();
  //  Network(const Network &n) : subPop(n){;}
  void resetActivation();
  void setNeuron(Neuron *, int);
  void setNetwork(Network *);
  void addFitness();
  void perturb(Network *);
  Network* perturb(double coeff = 0.3);
  void mutate(double);
  void printActivation(FILE *);
  void saveText(char *);
  void resetFitness() { fitness = 0.0; trials = 0; }
  friend double Environment::evaluateNetwork(Network *);
  inline int getNumNeurons() { return (int) hiddenUnits.size(); }
  double getFitness();
  Neuron* getNeuron(int);
  inline int getGeneSize() { return geneSize; }
  int getParent (int);
  inline int getID() { return id; }
  void setParent(int, int);  //!< fix this. parents should only be set in cross ops
  std::string getName () { return name; }
  int getType () { return type; }
  /*
  friend void NeuroEvolution::crossoverOnePoint(Network *parent1, 
						Network *parent2, 
						Network *child1, 
						Network *child2);
  friend void NeuroEvolution::crossoverNPoint(Network *parent1, 
					      Network *parent2, 
					      Network *child1, 
					      Network *child2);
  */
protected:
  int trials; 
  double fitness;
  int id;       //!< \todo make id a struct that has p1,p2,and name;
  int parent1;
  int parent2;
  int geneSize;
  std::string name;
  int type;

  void setFitness (double);
  void addConnection(int);
  void removeConnection(int);
  double sigmoid(double x, double slope = 1.0);

private:
 
  bool sizeEqual(Network &n);
};


std::ostream& operator<<(std::ostream &, Network &);

#endif
