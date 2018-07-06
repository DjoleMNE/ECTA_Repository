#include <stdlib.h>
#include <stdio.h>
#include <iostream.h>
#include <vector>
#include <deque>
#include <math.h>
#include "CartPole.h"
#include "Network.h" 
#include "signal-handler.h"


#define sgn(x)                  ((x >= 0) ? 1 : -1)

//////////////////////////////////////////////////////////////////////
//
// Double Pole physics
//
//////////////////////////////////////////////////////////////////////

static const double TRACK_SIZE  = 2.4;
static const double MUP         = 0.000002;
static const double MUC         = 0.0005;
static const double GRAVITY     = -9.8;
static const double MASSCART    = 1.0;
static const double MASSPOLE_1  = 0.1;
double MASSPOLE_2        = 0.01;
static const double LENGTH_1    = 0.5;	 // actually half the pole's length 
double LENGTH_2          = 0.05;
static const double FORCE_MAG   = 10.0;
static const double TAU         = 0.01;	  //seconds between state updates 

#define BIAS 0.5
#define one_degree 0.0174532	/* 2pi/360 */
#define six_degrees 0.1047192
#define twelve_degrees 0.2094384
#define fifteen_degrees 0.2617993
#define thirty_six_degrees 0.628329
#define degrees64    1.2566580
#define fifty_degrees 0.87266

int WINDOW = 0;

/// MODEL

#define NUM_UNITS 20
#define MOD_INPUTS 7
#define MOD_OUTPUTS 6

typedef struct{
  double first_layer[NUM_UNITS][MOD_INPUTS+1];
  double first_layer_activation[NUM_UNITS];
  double second_layer[MOD_OUTPUTS][NUM_UNITS+1];
  double outputs[MOD_OUTPUTS]; 
} network;


int UNIFORM_NOISE = 0; 
#define GAUSSIAN_NOISE 0


void feed_forward( std::vector<double> &, std::vector<double> & );
void loadModel(char *);

network MODEL;

//////////////////////////////////////////////////////////////////////
double rndGauss(double a, double d);

char modelfile[100];
CartPole::CartPole(struct cartArgs *args)
  : numPoles(args->numpoles), 
    initialized(false),
    reset(false),
    markov(args->markov),
    gruau(args->gruau),
    stateQ(),
    longPoleAngle(args->poleangle * one_degree),
    useModel(args->model),
    arguments(args)
{  
  name = "CartPole";
  LENGTH_2 = args->polelength/2;
  MASSPOLE_2 = args->polelength/10;
  if(useModel) strcpy(modelfile, args->modelfile);
  noise = args->noise/50;
  trajNoise = args->trajnoise;  //!< make a percent later.
  tolerance = 1.0;
  init();
}



void CartPole::init()
{
  if(useModel){
     loadModel(modelfile);
  }

  switch (numPoles){
  case 1:
    if(!markov) {
      inputDimension = 3;
      if(WINDOW) inputDimension = 2*WINDOW+1;
    }
    else inputDimension = 5;
    break;
  case 2:
    if(!markov) {
      inputDimension = 4;   
      if(WINDOW) inputDimension = 3*WINDOW+1;
    }
    else inputDimension = 7;
    break;
  };
  outputDimension = 1;
  if(gruau) maxFitness = 1000;
  else  maxFitness = 100000;
  for(int i =0;i<WINDOW;++i)
    stateQ.push_back( new double[3] );
  initialized = true;
  echoParams();
}

void CartPole::echoParams(){
  cout << "\nCart-pole environment settings: \n";
  cout << "------------------------------\n";
  cout << "Number of poles            : " << numPoles << "\n";
  cout << "Length of short pole       : " << LENGTH_2 * 2 << " meters\n";
  cout << "Initial angle of long pole : " << longPoleAngle/one_degree << " degrees\n";
  cout << "Number of inputs           : " << inputDimension << "\n";	 
  if(markov)
    cout << "Markov -- full state information." << endl;
  else
    cout << "Non-Markov -- no velocity information." << endl;
  if(WINDOW)
    cout << "Using input window; size set to " << WINDOW << "\n";
  if(noise)
    cout << "Percent sensor noise    : " << noise * 50 << "\n";
  if(trajNoise)
    cout << "Percent trajectory noise    : " << trajNoise << "\n";
  if(gruau)
    cout << "Using Gruau fitness." << endl;
  if(useModel) 
    cout << "Using neural network model: " << modelfile << endl;
}

  
void CartPole::resetState()
{
  int i,j;

  dydx[0] = dydx[1] = dydx[2] = dydx[3] =  dydx[4] = dydx[5] = 0.0;
  state[0] = state[1] = state[3] = state[4] = state[5] = 0;
  state[2] = longPoleAngle;
  if(WINDOW)
    for( i =0;i<WINDOW;++i){
      for( j =0;j<3;++j)
	stateQ[i][j] = 0.0; 
      //      delete [] stateQ[i];
      //      stateQ[i] = new double[3];
    }
  reset = true;
}  

#define SCALE 1.6  //used in training the model


void scale( std::vector<double> &vec )
{
  vec[0] =  vec[0] / 2.4;//2.416055; //1.813128;
  vec[1] =  vec[1] / 10.0; //3.028383; //2.624673;
  vec[2] =  vec[2] / 0.628329;//0.915499; //0.653708;
  vec[3] =  vec[3] / 5.0; //3.047803; //1.904003;
  vec[4] =  vec[4] / 0.628329;//0.669818; //0.593206;
  vec[5] =  vec[5] / 16.0; //4.362577; //4.582844;
}

void unscale( std::vector<double> &vec )
{
  vec[0] = vec[0] * 2.4      * SCALE; //2.416055; //1.813128;
  vec[1] = vec[1] * 10.0     * SCALE; // 3.028383; //2.624673;
  vec[2] = vec[2] * 0.628329 * SCALE;//0.915499; //0.653708;
  vec[3] = vec[3] * 5.0      * SCALE;  //3.047803; //1.904003;
  vec[4] = vec[4] * 0.628329 * SCALE;//0.669818; //0.593206;
  vec[5] = vec[5] * 16.0     * SCALE; //4.362577; //4.582844;
}

//extern bool GRUAU;

int DELAY = 0;
double CartPole::evalNet(Network *net)
{
  int i,steps=0;
  std::vector<double> input(inputDimension), output(outputDimension);
  std::vector<double> modelInput(6), modelOutput(6);
  double *tmp;
  std::deque<double> delayQ(0);
  double f1,f2 = 0;
  std::deque<double> x(0), xDot(0), theta(0), thetaDot(0);

  //int n = 1;
  //std::vector<double> max(n), min(n), rec(n);
  double tmp1[6];


  /*
  for(i=0;i<n;++i){
    max[i] = -100;
    min[i] = 100;
  }
  */
  if(!initialized) init();
  
  //  net->printWeights(stdout);
  //for(int k =0; k < 10000; ++k) {
  if(!reset)  resetState();
  //steps = 0;
  //if(k % 100 == 0) cout << k << endl;
  
  if(useModel) {
    for(i=0;i<6;++i)
      modelInput[i] = state[i];
    scale(modelInput);
  }

  //printf("\n\n\n");
  
  while (steps++ < maxFitness) {
    //    if(steps == 100) exit(4);
    //if(fabs (state[5]) > max)
    //  max = fabs(state[5]);
    if(WINDOW){
      tmp = new double[3];
      if(markov == 3){
	tmp[0] = dydx[1];
	tmp[1] = dydx[3];
	tmp[2] = dydx[5];
      }
      else{
	tmp[0] = state[0];
	tmp[1] = state[2];
	tmp[2] = state[4];
      }
      stateQ.push_back(tmp);
      delete [] stateQ.front();
      stateQ.pop_front();
    }
  
    setupInput(input);
    net->activate(input, output);
    
    //    rec[steps-1] = state[2];
   
    if(DELAY > 0){
      delayQ.push_back(output[0]);
      if(steps < DELAY) 
	output[0] = 0.5;
      else{
	output[0] = delayQ[0];
	delayQ.pop_front();
      }
    }
    if(gruau){
      x.push_front(input[0]);
      xDot.push_front(input[1]);
      theta.push_front(input[2]);
      thetaDot.push_front(input[3]);
      if(x.size() > 100){
	x.pop_back();
	xDot.pop_back();
	theta.pop_back();
	thetaDot.pop_back();
      }
    }

    ////////////////////////
    if(useModel){
      modelInput.push_back( output[0] * 2.0 - 1.0 );
      feed_forward(modelInput, modelOutput);
      modelInput.pop_back();
      //trajNoise = 0.013;
      /*for(i=0;i<6;++i){
	trajNoise += (modelInput[i] - modelOutput[i]) * 
	             (modelInput[i] - modelOutput[i]);
      }
      */
      //if(steps < 100000)
      //	trajNoise = 0.022 - (0.022 * (double) steps/10000);
     
      //printf("%f\n", trajNoise);
      for(i=0;i<6;++i){
	modelInput[i] = modelOutput[i] * SCALE + (drand48()  * trajNoise - trajNoise/2);
      }
      unscale(modelOutput);
      
      //printf("%f \n", modelOutput[2]);          
      for(i=0;i<6;++i){
	state[i] = modelOutput[i]; 
      }
      
      
    }
   
    ////////////////////////
    else{
      performAction(output);
    }
    //    printf("%f\n ", state[2]);      
    
    if (outsideBounds())	// if failure
      break;			// stop it now
  }
  reset = false;

  /*  
  if(steps >= n){
    for(i =0; i < n; ++i) {  
      if(rec[i] > max[i])
	max[i] = rec[i];
      if(rec[i] < min[i])
	min[i] = rec[i];
    }
  }
  
  }
  for(i=0;i<n;++i)
    printf("%d %f\n", i, max[i]);
  printf("\n\n\n");
  for(i=0;i<n;++i)
    printf("%d %f\n", i, min[i]);
  */
  
  
  if(gruau){
    f1 =  (double) steps/maxFitness;
    if(steps < 100)
      f2 = 0;
    else{
      for(int i = 0; i < 100; ++ i)
	f2 += fabs(x[i]) + fabs(xDot[i]) + fabs(theta[i]) + fabs(thetaDot[i]);
      f2 = (1/f2) * 0.75;
    }
    return (0.1 * f1 + 0.9 * f2);
    if (steps > maxFitness)
      if(generalizationTest(net) > 300)
	return steps;
  }
  else   
    return (double) steps;
}


#define PULSE 0
#define PERTURB 0
#define SETTLING 0
#define ELONGATE 1
#define deg18 (thirty_six_degrees/2)

double CartPole::evalNetDump(Network *net, FILE *fptr)
{
  int i,steps=0, count = 0, settlingTime = 0;
  std::vector<double> input(inputDimension), output(outputDimension);
  std::vector<double> modelInput(6), modelOutput(6);
  std::vector<double> prevState(6);
  double externalForce = 0.0, pulseForce = 0.0;  
  int pulseWidth = 0;
  int settlingStart;

  LENGTH_2 = 0.05;
  MASSPOLE_2 = 0.01;
  if(!initialized) init();

  if(!reset)  resetState();
  if(useModel) {
    for(i=0;i<6;++i)
      modelInput[i] = state[i];
    scale(modelInput);
  }
  //net->printWeights(stdout);

  net->resetActivation();
 
  while (steps++ < maxFitness) {
    
    //for(i=0;i<6;++i)
   
      /* + (drand48() *  thirty_six_degrees * 0.05 - deg18 * 0.05),
	 state[2] + (drand48() *  thirty_six_degrees * 0.1 - deg18 * 0.1), 
	 state[2] + (drand48() *  thirty_six_degrees * 0.2 - deg18 * 0.2));
	 fprintf(fptr, "\n");
      */
    /*if(noise > 0.0){
      fprintf(fptr, "%f ", input[0] * 2.4);
      fprintf(fptr, "%f ", input[2] * thirty_six_degrees);
      fprintf(fptr, "%f ", input[4] * thirty_six_degrees);
      }
      fprintf(fptr, "\n");
      fprintf(fptr, "%f ", externalForce);
      net->printActivation(stdout);
    */

    setupInput(input);
    net->activate(input, output);
    //    printf("%f %f %f %f %f %f\n", state[0], state[1], state[2], state[3],
    //	   state[4], state[5])
    printf("%i %f\n", steps, state[2]);
    
    if(PULSE){
      if( (steps%10000  == 0) && (steps > 0)){
	settlingStart = steps;
 	pulseWidth = 2;
	pulseForce += 0.1;
      }
      if(pulseWidth > 0){
	printf("Applying External Force of %f Newtons\n", pulseForce * 10);
	output[0] += pulseForce;
	--pulseWidth;
      }
    }
    if(PERTURB){
      externalForce = rndGauss(0, 0.05);
      output[0] += externalForce;
    }

    if(SETTLING){
    //find settling time
      if(fabs(state[2]) <  one_degree ){
	++count;
	if (count == 1000){
	  settlingTime = steps - settlingStart - 1000;
	  printf("settling time = %d\n" ,settlingTime);
	  if(!PULSE) break;
	} 
      }
      else{
	count = 0;
      }
    }
    if(ELONGATE)
      if((steps%10000) == 0){
	LENGTH_2 += 0.01;
	MASSPOLE_2 += 0.002;
	resetState();
	printf("POLE LENGTH %f\n", LENGTH_2);
      }
    
    for(i=0; i < 6; ++i)
      prevState[i] = state[i];  

    ////////////////////////
    if(useModel){
      modelInput.push_back( output[0] * 2.0 - 1.0 );
      feed_forward(modelInput, modelOutput);
      modelInput.pop_back();
      for(i=0;i<6;++i){
	modelInput[i] = modelOutput[i] * SCALE + (drand48()  * trajNoise - trajNoise/2);
      }
      unscale(modelOutput);
      
      //      printf("%f \n", modelOutput[2]);          
      for(i=0;i<6;++i){
	state[i] = modelOutput[i];
      }
      
      
    }
    ////////////////////////
    else{
      performAction(output);
    }
    
     
    
    /*    if((steps % 10) == 0){
      fprintf(fptr, "%f %f %f %f %f %f %f\n", 
	      prevState[0], prevState[1], prevState[2], 
	      prevState[3], prevState[4], prevState[5], output[0]*2.0 - 1.0 );
      fprintf(fptr, "%f %f %f %f %f %f\n", 
	      state[0], state[1], state[2], state[3], state[4], state[5]);
	      }*/
    if (outsideBounds())	// if failure
      break;	// stop it now
  }
  reset = false;

  if(SETTLING)
    return (double) settlingTime;
  else
    return (double) steps;
}



#define one_over_256  0.0390625
void CartPole::step(double action, double *st, double *derivs)
{
  double force;
  double costheta_1, costheta_2;
  double sintheta_1, sintheta_2;
  double gsintheta_1,gsintheta_2; 
  double temp_1,temp_2;
  double ml_1, ml_2;
  double fi_1,fi_2=0.0;
  double mi_1,mi_2=0.0;

  force =  (action - 0.5) * FORCE_MAG * 2;

  
  if((force >= 0) && (force < one_over_256))
    force = one_over_256;
  if((force < 0) && (force > -one_over_256))
    force = -one_over_256;
  

  costheta_1 = cos(st[2]);
  sintheta_1 = sin(st[2]);
  gsintheta_1 = GRAVITY * sintheta_1;
  ml_1 = LENGTH_1 * MASSPOLE_1;   
  temp_1 = MUP * st[3] / ml_1;
  fi_1 = (ml_1 * st[3] * st[3] * sintheta_1) +
    (0.75 * MASSPOLE_1 * costheta_1 * (temp_1 + gsintheta_1));
  mi_1 = MASSPOLE_1 * (1 - (0.75 * costheta_1 * costheta_1));

  if(numPoles > 1){
    costheta_2 = cos(st[4]);
    sintheta_2 = sin(st[4]);
    gsintheta_2 = GRAVITY * sintheta_2;
    ml_2 = LENGTH_2 * MASSPOLE_2;
    temp_2 = MUP * st[5] / ml_2;
    fi_2 = (ml_2 * st[5] * st[5] * sintheta_2) +
      (0.75 * MASSPOLE_2 * costheta_2 * (temp_2 + gsintheta_2));
    mi_2 = MASSPOLE_2 * (1 - (0.75 * costheta_2 * costheta_2));
  }
  
  derivs[1] = (force + fi_1 + fi_2)
	/ (mi_1 + mi_2 + MASSCART);
  
  derivs[3] = -0.75 * (derivs[1] * costheta_1 + gsintheta_1 + temp_1)
    / LENGTH_1;
  if(numPoles > 1)
    derivs[5] = -0.75 * (derivs[1] * costheta_2 + gsintheta_2 + temp_2)
      / LENGTH_2;

}

void CartPole::rk4(double f, double y[], double dydx[], double yout[])
{

	int i;

	double hh,h6,dym[6],dyt[6],yt[6];
	int vars = 3;

	if(numPoles > 1)
	  vars = 5;
       
	hh=TAU*0.5;
	h6=TAU/6.0;
	for (i=0;i<=vars;i++) yt[i]=y[i]+hh*dydx[i];
	step(f,yt,dyt);
	dyt[0] = yt[1];
	dyt[2] = yt[3];
	dyt[4] = yt[5];
	for (i=0;i<=vars;i++) yt[i]=y[i]+hh*dyt[i];
	step(f,yt,dym);
	dym[0] = yt[1];
	dym[2] = yt[3];
	dym[4] = yt[5];
	for (i=0;i<=vars;i++) {
	  yt[i]=y[i]+TAU*dym[i];
	  dym[i] += dyt[i];
	}
	step(f,yt,dyt);
	dyt[0] = yt[1];
	dyt[2] = yt[3];
	dyt[4] = yt[5];
	for (i=0;i<=vars;i++)
	  yout[i]=y[i]+h6*(dydx[i]+dyt[i]+2.0*dym[i]);
}
	
/*
inline
double noiseGenerator()
{
  if(UNIFORM_NOISE)
    return drand48() * noise - (noise/2);
  else if(GAUSSIAN_NOISE){
    //printf("%f \n", rndGauss(0, 0.05));
    return rndGauss(0, noise);
    }
  else
    return 0.0;
}
*/

void CartPole::setupInput(std::vector<double> &input)
{
  if(WINDOW){
    for(int i = 0; i < WINDOW; ++i){
      input[i*3] = stateQ[i][0]/2.4;
      input[i*3+1] = stateQ[i][1] /thirty_six_degrees;
      input[i*3+2] = stateQ[i][2] / thirty_six_degrees;
    }
    input[inputDimension-1] = 0.5;
  }
  else{
    switch(numPoles){
    case 1:
      if(markov){
	input[0] = state[0] / 2.4                + (drand48() * noise - (noise/2));
	input[1] = state[1] / 10.0               + (drand48() * noise - (noise/2));
	input[2] = state[2] / twelve_degrees     + (drand48() * noise - (noise/2));
	input[3] = state[3] / 5.0                + (drand48() * noise - (noise/2));
	input[4] = BIAS;
      }
      else{
	input[0] = state[0] / 2.4                + (drand48() * noise - (noise/2));
	input[1] = state[2] / twelve_degrees     + (drand48() * noise - (noise/2));
	input[2] = BIAS;
      }
      break;
    case 2:
      if(markov){
	input[0] = state[0] / 2.4                + (drand48() * noise - (noise/2));
	input[1] = state[1] / 10.0               + (drand48() * noise - (noise/2));
	input[2] = state[2] / thirty_six_degrees + (drand48() * noise - (noise/2));
	input[3] = state[3] / 5.0                + (drand48() * noise - (noise/2));
	input[4] = state[4] / thirty_six_degrees + (drand48() * noise - (noise/2));
	input[5] = state[5] / 16.0               + (drand48() * noise - (noise/2));
	input[6] = BIAS;
      }
      else{
	input[0] = state[0] / 2.4                + (drand48() * noise - (noise/2));
	input[1] = state[2] / thirty_six_degrees + (drand48() * noise - (noise/2));
	input[2] = state[4] / thirty_six_degrees + (drand48() * noise - (noise/2));
	input[3] = BIAS;
      }
      break;
    };
  }
  //  for(int i=0;i<input.size();++i)
  // printf("%f ",input[i]);
  //printf("\n");
}

#define RK4 1
#define EULER_TAU (TAU/8)
void CartPole::performAction(const std::vector<double> &output)
{ 
  
  int i;
  double tmpState[6];
  double force;

  force = output[0];
  /*random start state for long pole*/
  /*state[2]= drand48();   */
  
    
  /*--- Apply action to the simulated cart-pole ---*/

  if(RK4){      
    dydx[0] = state[1];
    dydx[2] = state[3];
    dydx[4] = state[5];
    step(force,state,dydx);
    rk4(force,state,dydx,state);
    for(i=0;i<6;++i)
      tmpState[i] = state[i];
    dydx[0] = state[1];
    dydx[2] = state[3];
    dydx[4] = state[5];
    step(force,state,dydx);
    rk4(force,state,dydx,state);
    if(markov == 3){
      dydx[1] = (state[1] - tmpState[1])/TAU;
      dydx[3] = (state[3] - tmpState[3])/TAU; 
      dydx[5] = (state[5] - tmpState[5])/TAU;
    }
  }
  else{
    for(i=0;i<16;++i){
      step(output[0],state,dydx);
      state[0] += EULER_TAU * state[1];
      state[1] += EULER_TAU * dydx[1];
      state[2] += EULER_TAU * state[3];
      state[3] += EULER_TAU * dydx[3];
      state[4] += EULER_TAU * state[5];
      state[5] += EULER_TAU * dydx[5];
    }
  }
}


bool CartPole::outsideBounds()
{
  double failureAngle; 

  if(numPoles > 1){
    failureAngle = thirty_six_degrees; 
    return 
      fabs(state[0]) > TRACK_SIZE       || 
      fabs(state[2]) > failureAngle     ||
      fabs(state[4]) > failureAngle;  
  }
  else{
    failureAngle = twelve_degrees; 
    return 
      fabs(state[0]) > TRACK_SIZE       || 
      fabs(state[2]) > failureAngle;
  }
}


#define MIN_INC 0.001
double POLE_INC = 0.05;
double MASS_INC = 0.01;

void CartPole::nextTask()
{
  LENGTH_2 += POLE_INC;   /* LENGTH_2 * INCREASE;   */
  MASSPOLE_2 += MASS_INC; /* MASSPOLE_2 * INCREASE; */
  //  ++new_task;
  printf("#Pole Length %2.4f\n", LENGTH_2);
  //noise += 0.1;
  //printf("#NOISE %2.4f\n", noise);
  //printf("#DONE \n");
  //  gInterrupt = true;  
}

void CartPole::simplifyTask()
{
  if(POLE_INC > MIN_INC) {
    POLE_INC = POLE_INC/2;
    MASS_INC = MASS_INC/2;
    LENGTH_2 -= POLE_INC;
    MASSPOLE_2 -= MASS_INC;
    printf("#SIMPLIFY\n");
    printf("#Pole Length %2.4f\n", LENGTH_2);
  }
  else
    {
      printf("#NO TASK CHANGE\n");
    }
}



double rndGauss(double a, double d)
{
  static double t = 0;

  double v1,v2,r;

  if( t == 0 ){
    do{
      v1 = 2.0*drand48() - 1.0;
      v2 = 2.0*drand48() - 1.0;
      r = v1*v1+v2*v2;
    }  while (r >= 1);
    r = sqrt((-2.0*log(r))/r);
    t = v2*r;
    return  a+v1*r*d;
  }
  else {
    t = 0;
    return a+t*d;
  }
}

double CartPole::generalizationTest(Network *net)
{
  int i,j,k,m, success = 0, score;
  double testMax = 1000;
  double intervals[5] = { 0.05, 0.25, 0.5, 0.75, 0.95 };
  double tmp;
 
  tmp = maxFitness;
  maxFitness = testMax;
  
  for(i = 0; i < 5; ++i)
    for(j = 0; j < 5; ++j)
      for(k = 0; k < 5; ++k)
	for(m = 0; m < 5; ++m){
	  reset = true; //make sure state is not reset to 'eval' initial state
	  state[0] = intervals[i] * 4.32 - 2.16;
	  state[1] = intervals[j] * 2.70 - 1.35;
	  state[2] = intervals[k] * 0.12566304 - 0.06283152;
	  /* 0.03141576; 3.6 degrees */
	  state[3] = intervals[m] * 0.30019504 - 0.15009752; /* 0.07504876;  8.6 degrees */
	  state[4] = 0.0;
	  state[5] = 0.0;
	  printf("%f %f %f %f ", state[0], state[1], state[2], state[3]);	  
	  score = (int) evalNet(net);

	  printf(" %d\n", score);
	  if(score >= testMax){
	    ++success;
	    //  printf(".");
	    //fflush(stdout);
	  }
	}
  maxFitness = tmp;
  printf("Number of successfull trials : %d\n", success);
  return (double) success;
} 


//// MODEL STUFF
void feed_forward( std::vector<double> &inputs, std::vector<double> &outputs )
{
  int i,j;
  network *net;

  net = &MODEL;
  
  for(i=0;i < NUM_UNITS; ++i){
    net->first_layer_activation[i] = 0.0;
    for(j=0; j < MOD_INPUTS+1; ++j){
      if(j == 0)
	net->first_layer_activation[i] += net->first_layer[i][j] * 1.0;
      else
	net->first_layer_activation[i] += net->first_layer[i][j] * inputs[j-1];
      
    }
    net->first_layer_activation[i] = 
      1 /(1 + exp( -net->first_layer_activation[i] ));
  }
  
  for(i=0;i < MOD_OUTPUTS; ++i){
    net->outputs[i] = 0.0;		       
    for(j=0;j < NUM_UNITS+1; ++j)
      if(j == 0)
	net->outputs[i] += 1.0 * net->second_layer[i][j];
      else
	net->outputs[i] += net->first_layer_activation[j-1] * 
	  net->second_layer[i][j];
    net->outputs[i] = tanh(net->outputs[i]);
    outputs[i] = net->outputs[i];
  }
}
void testModel()
{
  int j;
  FILE *fptr;
  char space;
  std::vector<double> in(7), out(6), tar(6);
  if ((fptr = fopen("/u/inaki/GANN/ESP/MODEL/tr_2.ex.unfilt","r")) == NULL) {
    printf("\n Error - cannot open (in Network::load)\n");
    exit(1);
  } 
  printf("\n\n\nINPUTS");
  for(int i = 0; i < 50 ; ++i){
    for(j=0;j<MOD_INPUTS;++j) {
      fscanf(fptr, "%lf%c", &in[j], &space);
      printf("%f ", in[j]);
    }
    printf("\nTARGETS ");
    for(j=0;j<MOD_OUTPUTS;++j) {
      fscanf(fptr, "%lf%c", &tar[j], &space);
    }

    feed_forward(in, out);
    for(j=0;j<MOD_OUTPUTS;++j) 
      printf("%f ", tar[j]);
    printf("\nOUTPUTS ");
    for(j=0;j<MOD_OUTPUTS;++j) 
      printf("%f ", out[j]);
    printf("\n\n");
  }
}

void loadModel(char *filename)
{
  int tmp,i,j;
  FILE *fptr;
  char space;

  if ((fptr = fopen(filename,"r")) == NULL) {
     printf("\n Error - cannot open %s (in Network::load)\n", filename);
     exit(1);
   }
  fscanf(fptr, "%d", &tmp);
  fscanf(fptr, "%d", &tmp);
  fscanf(fptr, "%d", &tmp);
  /*
  fscanf(fptr, "%f", &SCALE[0]);
  fscanf(fptr, "%f", &SCALE[1]);
  fscanf(fptr, "%f", &SCALE[2]);
  fscanf(fptr, "%f", &SCALE[3]);
  fscanf(fptr, "%f", &SCALE[4]);
  fscanf(fptr, "%f", &SCALE[5]);
  */ 
  for(i=0;i<NUM_UNITS;++i) {
    for(j=0;j<MOD_INPUTS+1;++j) {
      fscanf(fptr, "%lf%c", &MODEL.first_layer[i][j], &space);
      //printf("%f ", MODEL.first_layer[i][j]);
    }
    //printf("\n");
  }
  for(i=0;i<MOD_OUTPUTS;++i) {
    for(j=0;j<NUM_UNITS+1;++j) {
      fscanf(fptr, "%lf%c", &MODEL.second_layer[i][j], &space);
      //      printf("%f ", MODEL.second_layer[i][j]);
    }
    //printf("\n");
  }
  fclose(fptr);
  //testModel();
}
