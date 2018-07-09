#ifndef _TEST_H_
#define _TEST_H_

class Environment;

Network* genNet(int type, int in=0, int hid=0, int out=0 );
void testNetwork(Environment *e, char *filename);
Network* loadNetwork(Environment *e, char *filename);

#endif
