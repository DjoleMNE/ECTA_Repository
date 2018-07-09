//! Second Order Recurrent Network
/*! Coming soon
 */

#include "Network.h"

class SecondOrderRecurrentNetwork : public Network {
public:
  SecondOrderRecurrentNetwork(int, int, int);
  Network* newNetwork(int in, int hid, int out){ 
    return new SecondOrderRecurrentNetwork(in, hid, out); }
  Network* clone(){ return new SecondOrderRecurrentNetwork(numInputs, hiddenUnits.size(), numOutputs); }  
  void activate(std::vector<double> &, 
		std::vector<double> & );
  void growNeuron( Neuron * );
  void shrinkNeuron( Neuron *, int );
  void addNeuron();
  void removeNeuron(int sp);
private:
  int outOffset;
  std::vector< std::vector<double> > newWeights;
};
