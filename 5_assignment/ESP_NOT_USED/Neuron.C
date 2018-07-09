
//////////////////////////////////////////////////////////////////////
//
// Neuron 
//
//////////////////////////////////////////////////////////////////////

#include <math.h>
#include <iostream.h>
#include "Neuron.h"

ostream& operator<<(ostream& os, Neuron &n)
{
  os.precision(20);
  os << n.getName() << " " << n.getID() << ": " << endl;
  for(unsigned int i=0; i <  n.getSize(); ++i)
    os << n.getWeight(i) << " ";
  os << endl;
  return os;
}

//--------------------------------------------------------------------
//Neuron constructor
Neuron::Neuron(int size)
  : weight(size),
    lesioned(false),
    trials(0), 
    fitness(0.0),
    parent1(-1),
    parent2(-1),
    tag(false)
{
  name = "basic neuron";
  static int counter = 0;
  id = ++counter;  //newID();
}

inline 
bool Neuron::checkBounds(int i) 
{ 
  if(i >=0 && i < (int) weight.size()) 
    return true; 
  else {
    cerr << "Error: weight index out of bounds" << endl;
    abort();
  }
}

//! Assign fitness to a Neuron.
void Neuron::addFitness(double fit)
{
  fitness += fit;
  ++trials;
}

//! Set a Neuron's fitness to zero.
void Neuron::resetFitness()
{
  fitness = 0;
  trials = 0;
}

inline
double Neuron::getFitness()
{
  if (trials) 
    return (double) fitness/trials;
  else
    return fitness;
}

inline 
void Neuron::setWeight(int i, double w) 
{ 
  if( checkBounds(i) ){ 
    weight[i] = w; 
    //    resetFitness();  //size weight has been changed, fitness is no longer valid.
    newID(); 
  }
}

//---------------------------------------------------------------------
//! Perturb the weights of a Neuron. 
/*! Used to search in a neighborhood around some Neuron (best).
 */
void Neuron::perturb(const Neuron *n, double (*randFn)(double), double coeff)
{
  for(unsigned int i = 0; i < weight.size() ; ++i) 
    setWeight(i , n->weight[i] + (randFn)(coeff));
  resetFitness(); // reset the fitness after the weight vector is perturbed
}

void Neuron::perturb(const Neuron *n)
{
  perturb(n, rndCauchy, 0.3);
}


//---------------------------------------------------------------------
//! Same as above but called on self and returns new Neuron
Neuron* Neuron::perturb(double coeff = 0.3)
{
  Neuron *n = new Neuron( weight.size() );
  for(unsigned int i = 0 ; i < weight.size() ; ++i) 
    n->setWeight(i ,  weight[i] + rndCauchy(coeff) );
  return n;
}


//---------------------------------------------------------------------
//! Neuron assignment operator
Neuron Neuron::operator=(const Neuron &n)
{
  //!< \todo NOTE
  id  = n.id;
  ///////////
 
  parent1 = n.parent1;
  parent2 = n.parent2;
  fitness = n.fitness;
  trials = n.trials;  
  weight = n.weight;

  return *this;
}

//! Check if two Neurons are equal
/*!
    Two Neurons are considered equal if they
    have equal \c weight vectors
*/
bool Neuron::operator==(Neuron &n)
{
  if(weight == n.weight)
     return true;
  else
     return false;
}

//! Check if two Neurons are NOT equal.
/*!
    Two Neurons are considered equal if they
    have \c weight vectors that are NOT equal.
*/
bool Neuron::operator!=(Neuron &n)
{
  if(*this == n)
    return false;
  else
    return true;
}

//! Add a connection to a Neuron.
/*!
 */
inline
void Neuron::addConnection(int n)
{
  weight.insert(weight.begin() + n, 1.0);
}

inline 
void Neuron::removeConnection(int n)
{
  weight.erase(weight.begin() + n);
}

//---------------------------------------------------------------------
//! Create a new set of random weights
void Neuron::create()
{
  for (unsigned int i = 0 ; i < weight.size() ; ++i) 
    weight[i] = (drand48() * 12.0) - 6.0;
  //if(RELAX) weight [(int) weight.weight.size()()-1] = (double) (lrand48() % 3);
}

void Neuron::mutate()
{
  weight[lrand48()%weight.size()] += rndCauchy( 0.3 );
}


Neuron* Neuron::crossoverOnePoint(Neuron &n)
{
  int s1 = weight.size();
  int s2 = n.weight.size();
  std::vector<double>::iterator i,j,k;
  int cross1 = lrand48() % (s1 - 1) + 1;
  Neuron *child = new Neuron( s1 );
  k = n.weight.begin()+cross1;
  j = weight.begin();

  /* 
  if(s1 > s2){
    cross1 = lrand48() % s2;
    j = n.weight.begin();
    k = weight.begin();
  }
  */
  /*
  cout << cross1 << endl;
  printWeights(stdout);
  cout << endl;
  n.printWeights(stdout);
  */
  for (i = child->weight.begin(); i != child->weight.begin()+cross1; i++, j++)
    *i = *j;
  for (; i != child->weight.end(); i++, k++)
    *i = *k;
  /* 
     cout << endl;
     child->printWeights(stdout);
     cout << endl;
     cout << endl;
  */
  return child;
}


//----------------------------------------------------------------------
// generate a random number form a cauchy distribution centered on zero.
#define PI 3.1415926535897931 
double rndCauchy(double wtrange) 
{
  double u = 0.5, Cauchy_cut = 10.0;
 
  while (u == 0.5) 
    u = drand48();
  u = wtrange * tan(u * PI);
  if(fabs(u) > Cauchy_cut)
    return rndCauchy(wtrange);
  else
    return u;
}

