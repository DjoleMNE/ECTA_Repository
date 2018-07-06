#include <iostream.h>
#include "Environment.h"
#include "NE.h"
#include "Network.h"

//! Evaluate a \a Network in the Environment.
/*! Takes a \a Network and evaluates it on a task.  First
    checks to see if it is connected to a neuroevolution 
    algorithm (\a NE), then increments the algorithm's 
    evaluate the network, assigns it a fitness and return the
    fitness of the network.  This function is a friend of \a 
    Network and is the only function outside of the \a Network
    class that can set the value of a Network.  This ensures
    that networks are only assigned fitness when they are 
    evaluated.
*/
double Environment::evaluateNetwork(Network *net)
{
  if(nePtr) nePtr->incEvals();  //<! increment the algorithms \c evaluations member.
  net->resetActivation();
  double fit = evalNet(net);
  //<! \todo Environment should know whether it needs to be minimized
  if(nePtr && nePtr->minimize)  net->setFitness( 1.0/(fit + 1.0) );
  else net->setFitness( fit );
  return fit;
}




