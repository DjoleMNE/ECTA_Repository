######################################################################
#
#  ESP makefile
#
######################################################################

CC = /usr/bin/g++ #gcc
LD = /usr/bin/g++ #gcc

DIR = .
INCLUDES = #-I/usr/include/g++
CFLAGS =  $(PROFILE)  $(INCLUDES) -I. 
LDFLAGS = -L.# /usr/lib
ARCHIVES = -lm -lstdc++  # -lesp


DEPENDFLAGS = $(INCLUDES)

TARGET = esp
LIBNAME = libesp.a

DEBUG = 
PROFILE = 

GTK-FLAGS = `gtk-config --cflags` `gtk-config --libs`  

OBJECTS-NET = 	Network.o \
	     	FeedForwardNetwork.o \
		FullyRecurrentNetwork.o \
		SimpleRecurrentNetwork.o \
		SecondOrderRecurrentNetwork.o 

OBJECTS-AUX =   signal-handler.o \
		TestNets.o

OBJECTS-LIB = 	$(OBJECTS-NET) \
		NE.o Neuron.o \
		NetworkLevel.o \
		Environment.o \
		$(OBJECTS-AUX)

OBJECTS-ENV = 	CartPole.o 
OBJECTS-ESP = 	NE.o \
		ESP.o \
		Neuron.o \
		Environment.o \
		$(OBJECTS-NET)
 
OBJECTS = 	$(OBJECTS-ESP) \
		signal-handler.o \
		TestNets.o

######################################################################
######################################################################

# Implicit rules

%.o : %.C %.h Population.h Population.C
	$(CC) -c $(CFLAGS)  $< -o $@ 


######################################################################


main-esp.o: main-esp.C
	$(CC) -c $(CFLAGS) main-esp.C -o $@

main-cne-pole.o: main-cne.C
	$(CC) -c $(CFLAGS) main-cne.C -o $@ 

$(TARGET)-dpole: makefile  $(OBJECTS) main-esp.o CartPole.o 
	$(LD) main-esp.o CartPole.o  \
	$(LDFLAGS) $(OBJECTS)  $(ARCHIVES) -o $@

cne-dpole: makefile $(OBJECTS-CNE) \
	main-cne-pole.o CartPole.o 
	$(LD) main-cne-pole.o CartPole.o \
	$(OBJECTS-CNE) $(LDFLAGS) $(ARCHIVES) -o $@


lib: $(OBJECTS-LIB:%=OBJ/%) 
	ar ruv $(LIBNAME) $(OBJECTS-LIB:%=OBJ/%)


clean-dpole::	
	rm -f esp-dpole 
	rm -f *.o
	rm -f *~
	rm -f core

clean-cne::
	rm -f CNE.o
	rm -f cne-dpole


pure::  clean
	rm -f $(EXTRAPURE)
	rm -f $(LIBNAME)













