//////////////////////////////////////////////////////////////////////
// SecondOrderRecurrentNetwork
//

#include "SecondOrderRecurrentNetwork.h"
#include "Neuron.h"

SecondOrderRecurrentNetwork::SecondOrderRecurrentNetwork(int in, 
							 int hid, 
							 int out)
  : Network(in, hid, out), 
    newWeights(hid)
{
  int j;

  name = "Second Order Recurrent";
  type = 2;
  geneSize = in*hid+out; 
  numInputs = in; 
  numOutputs = out;
  outOffset = numInputs * (int) hiddenUnits.size();
  for(unsigned int i = 0; i < hiddenUnits.size(); ++i)
    for(j = 0; j < numInputs; ++j)
      newWeights[i].push_back(0.0);
}

void SecondOrderRecurrentNetwork::activate(std::vector<double> &input, 
					   std::vector<double> &output)
{ 
  register unsigned int i,k;
  register int j;
     
  // calculate new weights wij 
  for (i = 0 ; i < hiddenUnits.size() ; ++i )
    if(!hiddenUnits[i]->lesioned){
      for (j = 0 ; j < numInputs ; ++j ){
	(newWeights[i])[j] = 0.0;
	for (k = 0 ; k < hiddenUnits.size() ; ++k ){
	  newWeights[i][j] += activation[k] * hiddenUnits[i]->getWeight( j * hiddenUnits.size()+k );
	}
      }    
    }
  // activate hidden layer
  for ( i = 0 ; i < hiddenUnits.size() ; ++i ) {
    activation[i] = 0.0;
    if(!hiddenUnits[i]->lesioned){
      for (j=0;j<numInputs;++j) {
	activation[i] += newWeights[i][j] * input[j];
	//printf("%f\n", activation[i]);
      }
      activation[i] = sigmoid( activation[i] );//, fabs(hiddenUnits[i]->getWeight(0]/6.0));
    }
  }
  // for (i=0;i<NUM_OUTPUTS;++i) 
  //output[i] = activation[i];
  for(i=0;i < numOutputs ; ++i) {
    output[i] = 0.0;
    for (j=0; j < hiddenUnits.size(); ++j) {
      output[i] += activation[j] * hiddenUnits[j]->getWeight( outOffset+i );
    }
    output[i] = sigmoid( output[i] );
    //printf("%f\n", output[0]); //->getWeight(j]);
  } 
}
//! \todo This is totally wrong!
void SecondOrderRecurrentNetwork::growNeuron(Neuron *n)
{  
  n->addConnection(numInputs + (int) hiddenUnits.size() - 1);
}

inline
void SecondOrderRecurrentNetwork::shrinkNeuron(Neuron *n, int pos = -1)
{
  n->removeConnection(numInputs + pos);
}

inline
void SecondOrderRecurrentNetwork::addNeuron()
{
  int i;

  for(i=1; i < numInputs+1; ++i)  // add connection to Neurons in hiddenUnitss
    addConnection((int) hiddenUnits.size()*i+i-1);
  geneSize = numInputs * (int) hiddenUnits.size() + numOutputs;
  hiddenUnits.push_back( new Neuron(geneSize) );
}

void SecondOrderRecurrentNetwork::removeNeuron(int sp)
{
  geneSize = numInputs * (int) hiddenUnits.size() + numOutputs;
  for(int i=1; i < numInputs+1; ++i)  // remove connection to Neurons in shiddenUnitss
    removeConnection((int) hiddenUnits.size()*i);
  
  delete hiddenUnits[sp];
  hiddenUnits.erase(hiddenUnits.begin()+sp);
}
