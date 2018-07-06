/*! \file CartPole.h
 */

#ifndef _CARTPOLE_H_
#define _CARTPOLE_H_

#include <vector>
#include <deque>
#include "Environment.h"

struct cartArgs {
  int markov;
  int numpoles;
  double polelength;
  double poleangle;
  double noise;
  double trajnoise;
  bool gruau;
  bool model;
  char modelfile[100];
  double gain;
};

class Network;
//! Pole Balancing domain
/*! 
    Implements the pole balancing dynamics using
    the Runge-Kutta 4th-order integration method.
    Can be instantiated with one or two poles.
*/
class CartPole : public Environment {
public:
  bool useModel;
  CartPole(struct cartArgs *);
  virtual ~CartPole(){}
  virtual void simplifyTask();  
  virtual void nextTask();
  double evalNetDump(Network *net, FILE *fptr);
  double generalizationTest(Network *net);
  void echoParams();
  double state[6]; //<! \todo  make private again!
  void performAction(const std::vector<double> &output); //<! \todo  make private again!
  void resetState(); //<! \todo  make private again!
  cartArgs *arguments;

protected:
  virtual void setupInput(std::vector<double> &input);
  void init();


private:
  int numPoles;
  bool initialized;
  bool reset;
  bool markov; // markov (full state) or non-markov (no-velocities).
  bool gruau;
  std::deque< double* > stateQ;
  double noise;
  double trajNoise;
  double gain; // NEW_EXP

  double dydx[6];
  double longPoleAngle;
  virtual double evalNet(Network *net);

  void step(double action, double *state, double *derivs);
  void rk4(double f, double y[], double dydx[], double yout[]);
  bool outsideBounds();

};

#endif

