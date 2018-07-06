#ifndef _NEURON_
#define _NEURON_

/*! \file Neuron.h 
*/

//#include "Neural.h"
#include <string>
#include <stdio.h>
#include <vector>

//! Neuron Class
/*! Neuron base class.  A neuron is the basic unit used
   to construct neural networks. 
*/


class Neuron {
  
public:
  //private: 
  

  bool lesioned;
  
  Neuron(int);
  //virtual ~Neuron(){} // cout << "Destroying " << id << endl; }
  virtual Neuron* clone() { return new Neuron( weight.size() ); }  
  virtual Neuron operator=(const Neuron &);
  bool operator==(Neuron &);
  bool operator!=(Neuron &);
  virtual void create();
  virtual void addFitness(double);
  virtual void resetFitness();
  virtual void addConnection(int);
  virtual void removeConnection(int);
  void perturb(const Neuron *);
  void perturb(const Neuron *, double (*randFn)(double), double);
  Neuron* perturb(double coeff = 0.3);
  virtual void mutate();
  double getFitness();
  bool checkBounds(int);
  inline unsigned int getSize() { return weight.size(); }
  inline double getWeight(int i) { if( checkBounds(i) ) return weight[i]; }
  void setWeight(int, double);
  inline int getID() { return id; }
  inline string getName() { return name; }

  Neuron* crossoverOnePoint (Neuron &);

public:
  int parent1;
  int parent2;
  bool tag;
  

protected:
  inline int newID() { Neuron n(0); id = n.getID(); }
  std::vector<double> weight; 
  int trials;
  double fitness;               //neuron's fitness value
  int id;
  std::string name;
};

double rndCauchy(double);


std::ostream& operator<<(std::ostream &, Neuron &);

#endif






