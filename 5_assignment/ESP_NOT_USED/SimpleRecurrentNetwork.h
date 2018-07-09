//! Simple Recurrent Network (SRN)
/*! Implementation of the Elman SRN. 
    Like \c FeedForwardNetwork (1 hidden layer) except that, like 
    \c FullyReccurentNetwork the neuron activation
    is fed back into the network.  
*/

#include "Network.h"

class SimpleRecurrentNetwork : public Network {
public:
  SimpleRecurrentNetwork(int in, int hid, int out);
  Network* newNetwork(int in, int hid, int out){ 
    return new SimpleRecurrentNetwork(in, hid, out); }
  Network* clone(){ return new SimpleRecurrentNetwork(numInputs, hiddenUnits.size(), numOutputs); }  
  void activate(std::vector<double> &input, 
		std::vector<double> &output);
  void growNeuron( Neuron * );
  void shrinkNeuron( Neuron *, int );
  void addNeuron();
  void removeNeuron(int);
private:
  std::vector<double> tmp;
};
