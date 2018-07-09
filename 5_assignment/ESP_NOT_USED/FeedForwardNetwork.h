//! Feed-forward neural network with 1 hidden layer.
/*!
    This \c Network type has only feed-forward connections 
    (i.e. no internal state).  Therefore, it can only implement
    static mappings and should be used only in Markov domains.
 */

#include "Network.h"

class FeedForwardNetwork : public Network {
public:
  FeedForwardNetwork(int in, int hid, int out);  
  Network* newNetwork(int in, int hid, int out){ 
    return new FeedForwardNetwork(in, hid, out); }
  Network* clone(){ return new FeedForwardNetwork(numInputs, hiddenUnits.size(), numOutputs); }  
  void activate(std::vector<double> &input, 
		std::vector<double> &output);
  void growNeuron( Neuron * );
  void shrinkNeuron( Neuron *, int );
  void addNeuron();
  void removeNeuron(int sp);
};
