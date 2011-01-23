#include <LiquidCrystal.h>
#include <avr/pgmspace.h>
#include <EEPROM.h> //Needed to access the eeprom read write functions
#include <ser_pkt.h>
#include "EepromPgm.h"
//#include <avr/sleep.h>
#include "osHandles.h"

LiquidCrystal lcd(5, 4, 9, 10, 11, 12);

void setup() {
	Serial.begin(115200);
	lcd.begin(16, 2);	
}


unsigned long last_lcd_update = 0, last_button = 0, last_packet_sent = 0;
void loop(){
	
	OSHANDLES osHandles = {0};
	readSettings( &osHandles );
	
	while(1){
		unsigned long current_time = millis();
		osHandles.current_analogs = getControls(&osHandles);      //get the analog stick positions
	 
		/*------------------------*/
		/*---- button control ----*/
		/*------------------------*/
		byte pushbutton_read = digitalRead(transmit_button);
		osHandles.last_mode = osHandles.mode;
		if (pushbutton_read && !last_button){ //leading edge triggered
			last_button = current_time;
		}
		else if (pushbutton_read && ((current_time - last_button) > 2000)){ //hold-state
			//reset_eeprom(&osHandles); //resets to defaults
			runCalibration(&osHandles); //calibrate analog joysticks
		}
		else if (pushbutton_read && ((current_time - last_button) > 500)){ //hold-state
			osHandles.mode = MENU;
		}
		else if (!pushbutton_read && last_button){ //falling edge
			if ((current_time - last_button) < 500){
				if (osHandles.mode == TRANSMITTING) {
					osHandles.mode = STANDBY;
					lcd.clear();
					send_byte_packet(SETTINGS_COMM,(uint8_t) 'X');//send kill signal
					send_byte_packet(SETTINGS_COMM,(uint8_t) 'X');//send kill signal
				}
				else if (osHandles.mode == STANDBY) 
					{ osHandles.mode = TRANSMITTING; lcd.clear(); }
				else { osHandles.mode = STANDBY; lcd.clear(); }
			}
			last_button = 0;
		}
	
		/*----------------------*/
		/*---- mode actions ----*/
		/*----------------------*/
		if (osHandles.mode == TRANSMITTING){
			if ((current_time - last_packet_sent) > osHandles.transmit_rate){
				last_packet_sent = current_time;
				//sendPacket( &Values );
				send_int16_packet( USER_CONTROL, FULL_REMOTE, osHandles.current_analogs.x, osHandles.current_analogs.y, osHandles.current_analogs.ya, osHandles.current_analogs.th );
	
			}
			if ((current_time - last_lcd_update) > 200){
				last_lcd_update = current_time;
				print_flying_display( &osHandles );
			}
			//analogWrite(lcd_backlight_pin, ((current_time/10/100)%2)?(millis()/10)%100+155:(255-(millis()/10)%100));
		}
		else if ((osHandles.mode == MENU) && ((current_time - last_lcd_update)) > 200){
			last_lcd_update = current_time;
			print_menu_display( &osHandles );
		}
		else if ((osHandles.mode == STANDBY) && ((current_time - last_lcd_update)) > 300){
			last_lcd_update = current_time;
			print_standby_display( &osHandles );
		}
		if ((osHandles.mode != TRANSMITTING) && (current_time%5000 == 0)){
			send_byte_packet(SETTINGS_COMM,(uint8_t) 'm',0);
			send_byte_packet(SETTINGS_COMM,(uint8_t) 'X');//send kill signal
		}
	
		readSerialCommand(&osHandles);
		
		delay(1);
	}
}
