#include <LiquidCrystal.h>
#include <avr/pgmspace.h>
#include <ser_pkt.h>
//#include <avr/sleep.h>
#include "remote_xbee.h"

void setup() {
	pinMode(lcd_backlight_pin, OUTPUT);
	digitalWrite(lcd_backlight_pin,0); //start with backlight off.
	delay(1);
	lcd.begin(16, 2);
	lcd.print("tim o'brien");
	lcd.clear();
	//pinMode(ledRight, OUTPUT);
	//pinMode(ledLeft, OUTPUT);
	Serial.begin(115200);
	readSettings();
	for(byte i=0;i<(display_brightness);i++){ //fade in the display
		analogWrite(lcd_backlight_pin, i);
		delay(3);
	}
	delay(400);
}

unsigned long last_lcd_update = 0, last_button = 0, last_packet_sent = 0;
byte mode = STANDBY;
void loop(){
	unsigned long current_time = millis();
	Sticks Values = getControls();      //get the analog stick positions
 
	/*------------------------*/
	/*---- button control ----*/
	/*------------------------*/
	byte pushbutton_read = digitalRead(transmit_button);
	if (pushbutton_read && !last_button){ //leading edge triggered
		last_button = current_time;
	}
	else if (pushbutton_read && ((current_time - last_button) > 2000)){ //hold-state
		runCalibration();
	}
	else if (pushbutton_read && ((current_time - last_button) > 500)){ //hold-state
		mode = MENU;
	}
	else if (!pushbutton_read && last_button){ //falling edge
		if ((current_time - last_button) < 500){
			if (mode == TRANSMITTING) {
				mode = STANDBY;
				send_byte_packet(SETTINGS_COMM,(uint8_t) 'X');//send kill signal
				send_byte_packet(SETTINGS_COMM,(uint8_t) 'X');//send kill signal
			}
			else if (mode == STANDBY) { mode = TRANSMITTING; }
			else { mode = STANDBY; }
		}
		last_button = 0;
	}

	/*----------------------*/
	/*---- mode actions ----*/
	/*----------------------*/
	if (mode == TRANSMITTING){
		if ((current_time - last_packet_sent) > transmit_rate){
			last_packet_sent = current_time;
			//sendPacket( &Values );
			send_int16_packet( USER_CONTROL, FULL_REMOTE, Values.x, Values.y, Values.ya, Values.th );

		}
		if ((current_time - last_lcd_update) > 200){
			last_lcd_update = current_time;
			print_flying_display( Values );
		}
		//analogWrite(lcd_backlight_pin, ((current_time/10/100)%2)?(millis()/10)%100+155:(255-(millis()/10)%100));
	}
	else if ((mode == MENU) && ((current_time - last_lcd_update)) > 200){
		last_lcd_update = current_time;
		print_menu_display( Values );
	}
	else if ((mode == STANDBY) && ((current_time - last_lcd_update)) > 200){
		last_lcd_update = current_time;
		print_standby_display( Values );
		
	}
	if ((mode != TRANSMITTING) && (current_time%5000 == 0)){
		send_byte_packet(SETTINGS_COMM,(uint8_t) 'm',0);
		send_byte_packet(SETTINGS_COMM,(uint8_t) 'X');//send kill signal
	}

	readSerialCommand();
	
	delay(1);
}
