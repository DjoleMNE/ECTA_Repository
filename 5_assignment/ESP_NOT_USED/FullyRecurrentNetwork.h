//! Fully recurrent network.
/*! This \c Network type consists of a single layer
    of neurons w. Each neuron receives input from the
    environment \e and from the other neurons.  That is,
    each neuron's activation is fed back into the network.
    These networks have internal state and can be used in
    non-Markov task--task that require short-term memory.
*/

#include "Network.h"

class FullyRecurrentNetwork : public Network {
public:
  FullyRecurrentNetwork(int in, int hid, int out);
  Network* newNetwork(int in, int hid, int out){ 
    return new FullyRecurrentNetwork(in, hid, out); }  
  Network* clone(){ return new FullyRecurrentNetwork(numInputs, hiddenUnits.size(), numOutputs); }  

  void activate(std::vector<double> &, 
		std::vector<double> &);
  void growNeuron( Neuron * );
  void shrinkNeuron( Neuron *, int );
  void addNeuron();
  void removeNeuron(int);
  inline int getMinUnits() { return numOutputs; }

private:
  int relax; 
  std::vector<double> tmp;
};

class FullyRecurrentNetwork2 : public Network {
public:
  FullyRecurrentNetwork2(int in, int hid, int out);
  Network* newNetwork(int in, int hid, int out){ 
    return new FullyRecurrentNetwork2(in, hid, out); }
  Network* clone(){ return new FullyRecurrentNetwork2(numInputs, hiddenUnits.size(), numOutputs); }  
  void activate(std::vector<double> &, 
		std::vector<double> &);
  void growNeuron( Neuron * );
  void shrinkNeuron( Neuron *, int );
  void addNeuron();
  void removeNeuron(int);
  inline int getMinUnits() { return numOutputs; }

private:
  int relax; 
  std::vector<double> tmp;
};
