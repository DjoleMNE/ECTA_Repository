#include <iostream.h>
#include <fstream.h>
#include "Environment.h"
#include "Network.h"
#include "FeedForwardNetwork.h"
#include "FullyRecurrentNetwork.h"
#include "SimpleRecurrentNetwork.h"
#include "SecondOrderRecurrentNetwork.h"
#include "Neuron.h"

Network* genNet(int type, int in=0, int hid=0, int out=0 )
{
  switch ( type ){
  case 0: return new FeedForwardNetwork(in,hid,out);          break;
  case 1: return new SimpleRecurrentNetwork(in,hid,out);      break;
  case 2: return new SecondOrderRecurrentNetwork(in,hid,out); break;
  case 3: return new FullyRecurrentNetwork(in,hid,out);       break;
  case 4: return new FullyRecurrentNetwork2(in,hid,out);      break;
  default:
    cerr << "Error - network not of known type: " 
	 << type << endl;
    exit(1);
    break;
  }
}

Network* loadNetwork(Environment *e, char *filename)
{
  int i, j, type, numInputs, numUnits, numOutputs;
  Network *net;
  double tmp;
  char space;
  ifstream netfile(filename);


  if (!netfile) {
    cerr << "Error - cannot open" << filename << " (in loadNetwork)" << endl;
    exit(1);
  }
  else{
    netfile >> type;
    netfile >> numInputs;
    netfile >> numUnits;
    netfile >> numOutputs;

    net = genNet(type, numInputs, numUnits, numOutputs);

    cout << "loading "  << filename << "; type " << net->getName() << endl;

    if( e->getInputDimension() != numInputs ||
	e->getOutputDimension() != numOutputs ){
      cerr << "Network " << filename 
	   << " has incorrect I/O dimensionality for " 
	   << e->getName() << " domain" << endl; 
      exit(1);
    }
    net->create();
          
    //make the following a call to Network::load();
    for(i=0;i<net->getNumNeurons();++i) {
      for(j=0;j<net->getGeneSize();++j) {
	netfile >> tmp;
	//fscanf(fptr, "%.25f%c", &tmp, &space);
	net->getNeuron(i)->setWeight(j, tmp);
      }
    }
  }
  
  netfile.close();
  //  cout << *net << endl;
  return net;
}

void testNetwork(Environment *e, char *filename)
{
  char *type;
  double tmp;
  double total;

  Network *net;
  

  net = loadNetwork(e, filename);

  //      net->printWeights(stdout);
  //tmp = e->generalizationTest(net);            
  //tmp = e->evalNetDump(net,stdout);            
  //for(i =0; i < 1000; i++)
  tmp = e->evaluateNetwork(net);
  //total += tmp;
      
  cout << "Testing " << filename << " fitness = " << tmp << endl;
  
  
  delete net;
  
}



