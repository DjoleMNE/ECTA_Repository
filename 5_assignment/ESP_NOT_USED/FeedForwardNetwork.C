///////////////////////////////////////////////////////////////////////
// FeedForwardNetwork
//

#include "FeedForwardNetwork.h"
#include "Neuron.h"

FeedForwardNetwork::FeedForwardNetwork(int in, int hid, int out) 
  : Network(in, hid, out)
{ 
  name = "Feed Forward"; 
  type = 0;
  geneSize = in+out; 
  if(bias != 0) ++geneSize;
}

void FeedForwardNetwork::activate(std::vector<double> &input, 
				  std::vector<double> &output)
{ 
  register int i,j,k=0;
  // evaluate hidden/output layer 
  for (i=0 ; i < (int) hiddenUnits.size() ; ++i) {  //for each hidden unit
    if(!hiddenUnits[i]->lesioned){
      activation[i] = 0.0;
      if(bias != 0){  //<! if we are using bias units
      	activation[i] += hiddenUnits[i]->getWeight(0) * bias;
      	k = 1;
      }
      for (j=k ; j < numInputs+k ; ++j) {
	activation[i] += hiddenUnits[i]->getWeight(j) * input[j-k];
	//printf("%f\n", activation[i]);
      }
      //inner_product(hiddenUnits[i]->weight.begin(), 
      //	  hiddenUnits[i]->weight.end(), 
      //	  input.begin(), 0.0);
      activation[i] = sigmoid( activation[i] );
      //printf("%f\n", activation[i]);
    }
  }
  for(i=0;i<numOutputs;++i) {
    output[i] = 0.0;
    //    if(bias != 0){
    //	output[i] += bias * hiddenUnits[j]->getWeight(numInputs+i];
    //	k = 1;
    //}
    for (j=0 ; j < (int) hiddenUnits.size() ; ++j) {
      output[i] += activation[j] * hiddenUnits[j]->getWeight( numInputs+i );
    }
    output[i] = sigmoid( output[i] );
    //printf("%f\n", output[0]); //->getWeight(j]);
  }  
}


inline
void FeedForwardNetwork::growNeuron(Neuron *n){}
inline
void FeedForwardNetwork::shrinkNeuron(Neuron *n, int pos){}

void FeedForwardNetwork::addNeuron()
{
  hiddenUnits.push_back( new Neuron(geneSize) );
}

void FeedForwardNetwork::removeNeuron(int sp)
{
  delete hiddenUnits[sp];
  hiddenUnits.erase(hiddenUnits.begin()+sp);
}






