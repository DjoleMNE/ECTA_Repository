#ifndef _NETPOP_
#define _NETPOP_

/*! \file NetworkLevel.h
 */

#include "Population.h"

class Network;
class Esp;
//! Population of Networks
/*! This class implements evolution at the
    network level.  Designed to be used in
    conjuction with and \c Esp object when the
    \c --net-level option is selected.  When used with
    a \c NeuroEvolution object (e.g. \c Esp) it
    allows for evolution to be conducted on two levels that 
    communicate with each other through the \a NetPop::insertNet and 
    \a Esp::incorporareNeurons.
 */
class NetPop {
public:
  int numNets;
  Esp  *espPtr;

  NetPop(Esp *, int);
  void init();
  void reset();
  bool insertNetHeap(Network *);
  bool insertNet(Network *);
  void removeNet(int);
  void update();
  void cycleEvolution(int cycles = 1);
  void burstMutate();
  void addNeuron();
  void removeNeuron(int);
  void printNets(FILE *);
  void burstMutate(Network *);
  inline Network* getNetwork(int i) { return networks->getIndividual(i); }

private:
  NetworkPop *networks;
  bool active;
  double worstFitness;
  double mutationRate;
  void recombine();
};

#endif
