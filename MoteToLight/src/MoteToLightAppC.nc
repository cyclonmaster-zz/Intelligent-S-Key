#include "MoteToMote.h"

configuration MoteToLightAppC
{
	//Do nothing
}

implementation 
{
  	//General components
  	components MoteToLightC as App; //main module file
	components MainC; //Boot
  	components LedsC; //Leds
  	components new TimerMilliC();
  	
  	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer -> TimerMilliC;
  	
	//radio Communication
	components ActiveMessageC;
	components new AMSenderC(AM_BLINKTORADIO);
	components new AMReceiverC(AM_BLINKTORADIO);
	
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.AMSend -> AMSenderC;
	App.Receive -> AMReceiverC;
	
	//photo sensor
	components new DemoSensorC() as PhotoSensor;
	App.Read -> PhotoSensor;
	
}
