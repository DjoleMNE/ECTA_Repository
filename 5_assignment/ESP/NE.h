/*! \file NE.h
 */

#ifndef _NE_
#define _NE_


class Neuron;
class Network;


class Environment;

//! Base class for other neuroevolution algorithms
/*! Class NeuroEvolution is a virtual class that 
    describes the basic structure that derived neuroevolutionary
    algirthms must take, as well as implementing the genetic operators
    for recombining Networks and Neurons;
\todo make genopts methods of Networks and Neurons.
*/

class NeuroEvolution {
protected: 
  int inputDimension;  //!< The number of variables that the nets receive as input.
  int outputDimension; //!< The number of variables in the action space.
  int evaluations;     //!< The number of network evaluations.
 
public:
  bool minimize;       //!< Whether or not fitness is maximized or minimized.
  Environment &Envt;   //!< The task environment.
  NeuroEvolution(Environment &e);   
  // Accessors
  int getInDim() { return inputDimension; }
  int getOutDim() { return outputDimension; }
  // Genetic operators
  void crossoverOnePoint(Neuron *, Neuron *, Neuron *, Neuron *);
  void crossoverArithmetic(Neuron *, Neuron *, Neuron *, Neuron *);
  void crossoverEir(Neuron *, Neuron *, Neuron *, Neuron *);
  void crossoverOnePoint(Network *, Network *, Network *, Network *);
  void crossoverArithmetic(Network *, Network *, Network *, Network *);
					   

  void crossoverNPoint(Network *, Network *, Network *, Network *);
  void incEvals() { ++evaluations; }
};

#endif
