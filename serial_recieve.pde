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
					case QUAD_2_REMOTE_PIDS: //recieve the PID values sent by the quad.
					{
						int16_t recieved_pids[NUM_PID_VALUES] = {0};
						decode_some_int16s( packet+5, recieved_pids, NUM_PID_VALUES);
						if (compare_quad_PIDs_to_eeprom(recieved_pids))
							{ osHandles->quad_settings_status = CORRECT_SETTINGS; }
						else 
							{ osHandles->quad_settings_status = SETTINGS_MISMATCH; }
						
						break;
					}
					
				}	
			}
		}
	} //if (Serial.available())
	//else PORTB &= ~(1<<5); //digitalWrite(LEDPIN, LOW);
}

