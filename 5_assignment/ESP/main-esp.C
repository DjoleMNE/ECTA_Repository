#include <unistd.h>
#include <argp.h>
#include <time.h>
#include <stdio.h>
#include <fstream>
#include "signal-handler.h"
#include "CartPole.h"

#include "ESP.h"
#include "Network.h"
#include "FeedForwardNetwork.h"
#include "FullyRecurrentNetwork.h"
#include "SimpleRecurrentNetwork.h"
#include "SecondOrderRecurrentNetwork.h"
#include "TestNets.h"

clock_t START_TIME;
clock_t FINISH_TIME;

static int maxGenerations = 5000;

void reseed(int val);



bool TEST;
char *NETFILE;


////////////////////////////////////////////////////////////////////
// Parse arguments

#define OPT_STAG 1
#define OPT_MIN 2
#define OPT_GROW 3
#define OPT_TEST 4
#define OPT_VERB 5
#define OPT_SEEDNET 6
#define OPT_POP 7
#define OPT_SAVE 8
#define NUM_ESP_OPTS 8

static struct espArgs espargs;

const char *argp_program_version = "ESP 3.0";
const char *argp_program_bud_address = "<inaki@cs/utexas/edu>";

static char doc[] =
"Enforced Sub Populations neuroevolution system.";
static char args_doc[] = "ARG1";

static struct argp_option options[] = {
  {"numpops"    , 'z'          , "Z"        , 0, "Number of subpopulations"},
  {"popsize"    , 'n'          , "N"        , 0, "Size of subpopulations"},
  {"nettype"    , 't'          , "FF,SRN,FR", 0, "Type of network"},
  {"seed"       , 's'          , "S"        , 0, "Random seed"},
  {"mutation"   , 'm'          , "M"        , 0, "Mutation rate"},
  {"generations", 'g'          , "G"        , 0, "Max number of generations"},
  {"dar"        ,  OPT_GROW    ,  0         , 0, "Disable adding/removing of subpops"},
  {"stag"       ,  OPT_STAG    , "S"        , 0, "Stagnation criteria"},
  {"min"        ,  OPT_MIN     ,  0         , 0, "Minimize instead of maximize fitness"},
  {"test"       ,  OPT_TEST    , "netfile"  , 0, "File of network to be tested"},
  {"verbose"    ,  OPT_VERB    ,  0         , 0, "Print individual fitnesses"},
  {"seednet"    ,  OPT_SEEDNET , "netfile"  , 0, "Evolve around a network"},
  {"pop"        ,  OPT_POP     , "popfile"  , 0, "Load population file"},
  {"save"       ,  OPT_SAVE    , 0          , 0, "Save networks?"},
  { 0 }
};


static error_t
parse_opt (int key, char *arg, struct argp_state *state)
{
  //struct espArgs *arguments = (struct espArgs *) state->input;
  
  switch(key)
    {
    case 'g':
        maxGenerations = atoi(arg);
      break;
    case 'z':
      if(atoi(arg) == 0){ //if -z is 0 chose random num of subpops.
	reseed(time(NULL));
	espargs.numpops = (lrand48() % 9) + 1;
      }
      else 
	espargs.numpops = atoi(arg);
      break;
    case 'n':
      espargs.popsize = atoi(arg);
      break;
    case 't':
      espargs.net = genNet( atoi(arg) );
      break;
    case 's':
      espargs.seed = atoi(arg);
      break;
    case 'm':
      espargs.mutation = atof(arg);
      break;
    case OPT_STAG:
      espargs.stagnation = atoi(arg);;
      break;
    case OPT_MIN:
      espargs.minimize = true;
      break;
    case OPT_GROW:
      espargs.grownets = false;
      break;
    case OPT_TEST:
      TEST = true;
      NETFILE = arg;
      printf("%s\n", NETFILE);
      break;
    case OPT_VERB:
      espargs.verbose = true;
      break;
    case OPT_SEEDNET:
      espargs.seednet = true;
      NETFILE = arg;
      break;
    case OPT_POP:
      espargs.popfile = arg;
      break;
    case OPT_SAVE:
      espargs.savenets = true;
      break;
    default:
      return ARGP_ERR_UNKNOWN;
    }
  return 0;
}

/////////////////////////////////////////////////////////////////


#define OPT_NM     (NUM_ESP_OPTS + 1)
#define OPT_NPOLES (NUM_ESP_OPTS + 2)
#define OPT_PL     (NUM_ESP_OPTS + 3)
#define OPT_NOISE  (NUM_ESP_OPTS + 4)
#define OPT_ANGLE  (NUM_ESP_OPTS + 5)
//#define OPT_MODEL  (NUM_ESP_OPTS + 6)
#define OPT_TRAJ  (NUM_ESP_OPTS + 7)


static struct cartArgs cartargs;

static struct argp_option env_options[] = {
  {"nm"    , OPT_NM    ,  0   , 0, "Non-Markov"},
  {"poles" , OPT_NPOLES, "P"  , 0, "Number of poles"},
  {"pl"    , OPT_PL    , "L"  , 0, "Length of short pole"},
  {"pa"    , OPT_ANGLE , "A"  , 0, "Initial angle of long pole in degrees"},
  {"noise" , OPT_NOISE , "N"  , 0, "Sensor noise"},
  //  {"model" , OPT_MODEL , "Model file", 0, "Use NN model for Environment."}, 
  {"traj"  , OPT_TRAJ  , "T"  , 0, "Trajectory noise"},
  { 0 }
};


static error_t
parse_env_opt (int key, char *arg, struct argp_state *state)
{
  switch(key)
    {
    case OPT_NM:
      cartargs.markov = 0;
      break;
    case OPT_NPOLES:
      cartargs.numpoles = atoi(arg);
      break;
    case OPT_PL:
      cartargs.polelength = atof(arg);
      break;
    case OPT_NOISE:
      cartargs.noise = atof(arg);
      break;
    case OPT_ANGLE:
      cartargs.poleangle = atof(arg);
      break;
      //    case OPT_MODEL:
      //cartargs.model = true;
      //strcpy(cartargs.modelfile, arg);
      //break; 
    case OPT_TRAJ:
      cartargs.trajnoise = atof(arg);
      break;
    default:
      return ARGP_ERR_UNKNOWN;
    }
  return 0;
}

char header[] = "Cart Pole options:";


static struct argp env_argp = { env_options, parse_env_opt, 0, 0 };
static struct argp_child env_parser = { &env_argp, 0, header,0 };
static struct argp_child argp_children[2] = { env_parser };

static struct argp esp_parser = { options, parse_opt, args_doc, doc, 
				  argp_children};


//----------------------------------------------------------------------
// reseed random fns.
void reseed(int val)
{
  unsigned short seed[3];

  cout << "Random seed : " << val << "\n";
  seed[0] = val;
  seed[1] = val+1;
  seed[2] = val+2;
  seed48(seed);
  srand48(val);
}

//////////////////////////////////////////////////////////////////////
//
// main
//
//////////////////////////////////////////////////////////////////////

int main(int argc, char *argv[])
{
  // Parse command-line arguments.

  
  START_TIME = clock();
 
  //defaults
  espargs.numpops        = 5;
  espargs.popsize        = 40;
  espargs.net            = new FeedForwardNetwork(0,0,0); 
  espargs.grownets       = true; 
  espargs.seed           = time(NULL);
  espargs.mutation       = 0.4;
  espargs.stagnation     = 20;
  espargs.minimize       = false;
  TEST                   = false;
  espargs.verbose        = false;
  espargs.seednet        = false;
  espargs.popfile        = "";
  espargs.savenets       = false;

  //CartPole args
  cartargs.markov        = 1;
  cartargs.numpoles      = 2;
  cartargs.poleangle     = 4.0156035; //degrees
  cartargs.polelength    = 0.1;
  cartargs.noise         = 0.0;
  cartargs.trajnoise     = 0.0;
  cartargs.model         = false;

  argp_parse(&esp_parser, argc, argv, 0, 0, 0 );
  
  reseed(espargs.seed);
  
  
  CartPole env(&cartargs); 


  if(espargs.seednet)
    espargs.net = loadNetwork(&env, NETFILE);
  else if(espargs.popfile != ""){
    int type;
    ifstream in( espargs.popfile.c_str() );
    in >> type;
    cout << type << endl;
    espargs.net = genNet(type,0,0,0);
  }
    
  if(TEST){
    testNetwork(&env, NETFILE);
    exit(0);
  } 

  setUpCtrlC();
    
  Esp esp(&espargs, env, *espargs.net);
  esp.evolve(maxGenerations);       // evolve them.
}

