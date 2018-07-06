/* 
  File: signal-handler.h
  Author: Anthony R. Cassandra
  July, 1998

  *****
  Copyright 1994-1997, Brown University
  Copyright 1998, Anthony R. Cassandra

                           All Rights Reserved
                           
  Permission to use, copy, modify, and distribute this software and its
  documentation for any purpose other than its incorporation into a
  commercial product is hereby granted without fee, provided that the
  above copyright notice appear in all copies and that both that
  copyright notice and this permission notice appear in supporting
  documentation.
  
  ANTHONY CASSANDRA DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
  INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR ANY
  PARTICULAR PURPOSE.  IN NO EVENT SHALL ANTHONY CASSANDRA BE LIABLE FOR
  ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  *****
*/
#ifndef SIGNAL_HANDLER_H
#define SIGNAL_HANDLER_H

#include "signal.h"

/*******************************************************************/
/**************             CONSTANTS               ****************/
/*******************************************************************/

/* Defining this constant turns off the memory limit stuff */
#define DISABLE_MEMORY_LIMIT


/*******************************************************************/
/**************       EXTERNAL VARIABLES            ****************/
/*******************************************************************/

extern bool gInterrupt;

/*******************************************************************/
/**************       EXTERNAL FUNCTIONS            ****************/
/*******************************************************************/

/* If the -brief option is specified, then we set a timer for the
   maximum number of seconds we will allow the program to run for.  */
extern void setUpIntervalTimer( int secs );

/* Sets the hard virtual memory size limit.  If process exceeds this
   limit, then the SIGSEGV signal will be generated.  We also try to
   catch this signal, but we are carefull not to assume that every
   SIGSEGV is due to resource limitations.  */
extern void setMemoryLimit( int mem_size_limit );

/* Registers the signal handler for the SIGINT signal which is
  generated by pressing CRTL-C.  */
extern void setUpCtrlC(  );

/* Sets the parameter context so that when interrupts are received we
  can look there for information about where the soluton process
  stoppped.  */
//extern void setInterruptParamContext( PomdpSolveParams param );
      
#endif
