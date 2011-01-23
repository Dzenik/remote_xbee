#include <ser_pkt.h>
//#include <math.h>


void readSerialCommand(OSHANDLES * osHandles){
	// Check for serial message
	if (Serial.available()) {
		uint8_t* packet = getSerialPacket();
		if (packet != NULL){
						
			if (packet[2] == SETTINGS_COMM){			
				switch (packet[3])
				{
					case SEND_PIDS: //recieve the PID values sent by the quad.
					{
						decode_some_int16s( packet+5, osHandles->Telemetry.pid_values, 9);
						osHandles->Telemetry.just_updated = PIDs_ARE_CURRENT;
						break;
					}
					
				}	
			}
		}
	} //if (Serial.available())
	//else PORTB &= ~(1<<5); //digitalWrite(LEDPIN, LOW);
}

