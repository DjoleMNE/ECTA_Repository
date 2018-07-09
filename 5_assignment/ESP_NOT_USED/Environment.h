/////////////////////////////////////////////////////////////////////
//
// Environment
//
// Virtual Class for modelling a specific environment/task.
// 
//////////////////////////////////////////////////////////////////////

// The only function that really needs to do anything when implemented
// is evalNet. It must take a Network and return a double.  That is, 
// evalNet is not restricted in any way in what it does with the 
// Network (except alter its weights) as long as it returns 
// a double (fitness).

#ifndef _ENVT_
#define _ENVT_

/*! \file Environment.h
 */

class Network;

#include <string>
#include <vector>
#include <stdio.h>


class NeuroEvolution;

/*! Virtual class that describes the interface  
    for all task environments used in \c NeuroEvolution
    objects.
*/
class Environment {
public:
  double maxFitness;  
  
  Environment() :  nePtr(NULL),
		   tolerance(0), 
		   incremental(false) {} 
  virtual ~Environment() {}
  double evaluateNetwork(Network *);  //!< make net const
  virtual void nextTask() {}   
  virtual void simplifyTask() {}
  virtual double evalNetDump(Network *net, FILE *) { return 0.0;} 
  virtual double generalizationTest(Network *) { return 0.0;}
  void setNePtr(NeuroEvolution *e) { nePtr = e; }
  inline int getInputDimension() { return inputDimension; }
  inline int getOutputDimension() { return outputDimension; }
  inline double getTolerance() { return tolerance; }
  inline bool getIncremental() { return incremental; }
  inline std::string getName() { return name; }
protected:
  NeuroEvolution *nePtr;  //!< Pointer to the Neuroevolution algorithm 
  std::string name;
  double tolerance;
  bool incremental;
  int inputDimension;     //!< dimension of input space
  int outputDimension;    //!< dimension of output space 

  virtual void setupInput(std::vector<double> &input) = 0;
  virtual double evalNet(Network *net) = 0;   // evaluate a network
};

#endif


