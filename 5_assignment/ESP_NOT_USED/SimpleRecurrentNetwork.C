///////////////////////////////////////////////////////////////////
// SimpleRecurrentNetwork
//

//! ELMAN Net
/*! \todo make tmp a member to avoid reallocation
 */

#include "SimpleRecurrentNetwork.h"
#include "Neuron.h"

SimpleRecurrentNetwork::SimpleRecurrentNetwork(int in, int hid, int out) 
  : Network(in, hid, out), 
    tmp()
{ 
  name = "Simple Recurrent Network";
  type = 1;
  geneSize = in+hid+out; 
}

void SimpleRecurrentNetwork::activate(std::vector<double> &input, 
				      std::vector<double> &output)

{ 
  register int i,j;

  tmp = input;

  // evaluate hidden/output layer 
  for (i=0;i<(int) hiddenUnits.size();++i){
    tmp.push_back(activation[i]);
      /* printf("%f \n", net[i]->activation);   */
  }
  for (i=0;i<(int) hiddenUnits.size();++i) {  /*for each hidden unit*/
    activation[i] = 0.0;
    if(!hiddenUnits[i]->lesioned){
      for (j=0;j<numInputs+(int) hiddenUnits.size();++j) {
	activation[i] += hiddenUnits[i]->getWeight(j) * tmp[j];
	//printf("%f\n", activation[i]);
      }
    //inner_product(hiddenUnits[i]->weight.begin(), 
      //	  hiddenUnits[i]->weight.end(), 
      //	  input.begin(), 0.0);
      activation[i] = sigmoid( activation[i] );//, hiddenUnits[i]->getWeight(geneSize-1]); 
      // fabs(hiddenUnits[i]->getWeight(numInputs+1]/6.0)) * 2 - 1.0;
      //printf("%f\n", activation[i]);
    }
  }
  for(i=0;i<numOutputs;++i) {
    output[i] = 0.0;
    for (j=0;j<(int) hiddenUnits.size();++j) {
      output[i] += activation[j] * hiddenUnits[j]->getWeight(numInputs + hiddenUnits.size() + i);
    }
    output[i] = sigmoid( output[i] );//, hiddenUnits[i]->getWeight(geneSize-1]);  
    //printf("%f\n", output[0]); //->getWeight(j]);
  }  
}

inline
void SimpleRecurrentNetwork::growNeuron(Neuron *n)
{  
  n->addConnection(numInputs + (int) hiddenUnits.size() - 1);
}

inline
void SimpleRecurrentNetwork::shrinkNeuron(Neuron *n, int pos = -1)
{
  n->removeConnection(numInputs + pos);
}


void SimpleRecurrentNetwork::addNeuron()
{
  activation.push_back(0.0);
  addConnection(numInputs+(int) hiddenUnits.size() );
  geneSize = numInputs + (int) hiddenUnits.size() + numOutputs + 1;  
  hiddenUnits.push_back( new Neuron(geneSize) );
}

void SimpleRecurrentNetwork::removeNeuron(int sp)
{
  if( hiddenUnits.size() > 1 ){
    activation.pop_back();
    removeConnection(numInputs+sp);
    delete hiddenUnits[sp];
    hiddenUnits.erase(hiddenUnits.begin()+sp);
    geneSize = numInputs + (int) hiddenUnits.size() + numOutputs;  
  }
}
