#ifndef MOTE_TO_MOTE_H
#define MOTE_TO_MOTE_H

enum
{
	AM_BLINKTORADIO = 6 //ActiveMessage - layer of communication
};

typedef nx_struct MoteToMoteMsg
{
	nx_uint16_t nodeid; //Id of the mote
	nx_uint8_t data;
	nx_uint16_t lastReading;
	
} MoteToMoteMsg;

#endif /* MOTE_TO_MOTE_H */
