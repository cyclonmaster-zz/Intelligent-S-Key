#ifndef DEMO_MESSAGE_H
#define DEMO_MESSAGE_H

enum 
{ 
	AM_DEMO_MSG = 231, 
};
typedef nx_struct demo_msg 
{ 
	nx_uint16_t lastReading; 
} demo_msg_t; 

#endif /* DEMO_MESSAGE_H */
