//FINAL CODE
//RED LED - indicate 2 mote communicate
//GREEN LED - indicate send receive message
//YELLOW LED - indicate photo sensor gathering data

//local header
#include "MoteToMote.h"

module MoteToLightC 
{
  uses //general interface
  {
    interface Boot;
    interface Leds;
    interface Timer<TMilli>; 
  }

  uses //Radio
  {
  	interface Packet; //data to be extract
  	interface AMPacket; //special packet use by active message
  	interface AMSend; //allow send active message type
  	interface SplitControl as AMControl; //to control basic data extraction
  	interface Receive; //allow receive something - radio packet
  }
  
  uses //sensor
  {
  	interface Read<uint16_t>;
  }
  
}

implementation
{
	//now implement logic of radio communication
	//need variable to store data of radio
	bool _radioBusy = FALSE; //if radio is busy wait until it free again
	message_t _packet; //top layer of message packet - packet holder

	task void readSensor();
	task void sendBuffer();	

	event void Boot.booted() //what happen when mote boot
	{
	    call AMControl.start(); //start AMControl 
	}	

	//when splitcontrol started-can check if it started success or not
	event void AMControl.startDone(error_t error)
	{
		// to detect any problem that occuring
		if(error == SUCCESS) //SUCCESS value = 0 mean no error
		{
    		call Leds.led1On();
    		if(_radioBusy == FALSE)
    		{
     			MoteToMoteMsg* msg = (MoteToMoteMsg*)(call Packet.getPayload(&_packet, sizeof(MoteToMoteMsg)));
      			if (msg == NULL) 
      				{
					return;
      				}
      			msg->nodeid = TOS_NODE_ID;
      			call Timer.startPeriodic(64);      			
      			if (call AMSend.send(AM_BROADCAST_ADDR, &_packet, sizeof(MoteToMoteMsg)) == SUCCESS)
      				{
        			_radioBusy = TRUE;
      				}
    		}	
		}
		else
		{
			call AMControl.start();
		}
	}

	event void Timer.fired()
	{
		post readSensor();
	}
	
	task void readSensor()
	{
		if(call Read.read() != SUCCESS) 
			post readSensor();
			call Leds.led2Toggle();
	}
	
	event void Read.readDone(error_t result, uint16_t val)
	{
		MoteToMoteMsg * payload = (MoteToMoteMsg *)call Packet.getPayload(&_packet, sizeof(MoteToMoteMsg)); 
		payload->lastReading = val; 
		post sendBuffer(); 
	}
	
	task void sendBuffer()
	{
		if(call AMSend.send(AM_BROADCAST_ADDR, &_packet, sizeof(MoteToMoteMsg)) != SUCCESS) 
			post sendBuffer(); 
	}

	//to trigger something or set indicate anything if message done send
	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		if(error != SUCCESS)
		{
			call Leds.led1Off();
			post sendBuffer();
		}

		// set radio is busy false again
		if( &_packet == msg )
		{
			_radioBusy = FALSE;
		}
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		//check the packet is what I looking for
		//if(len == sizeof(MoteToMoteMsg))
		//{
			MoteToMoteMsg * incomingmsg = (MoteToMoteMsg*) payload;
			
			//incomingPacket->nodeid == 2; //to set control over specific id
			
			//uint8_t data = incomingmsg->data;
			
			//if(data == 1) //mean another mote is on and ready send data
			//{
			//	call Leds.led0On();
			//}
			//if(data == 0) //mean another mote is not ready
			//{
			//	call Leds.led0Off();
			//}
		//}
		call Leds.led0On();
		//need return value
		return msg;
	}
	
	//when start the radio can check it start or not
	event void AMControl.stopDone(error_t error)
	{
		// Do nothing here to stop the radio
	}
}
