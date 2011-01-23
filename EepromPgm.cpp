
#include "WProgram.h"
#include <EEPROM.h> //Needed to access the eeprom read write functions
#include <avr/pgmspace.h>
#include "EepromPgm.h"
#include "osHandles.h"

typedef uint8_t byte;  //would be redundant.. if this weren't a header file.


//This function will write a 2 byte integer to the eeprom at the specified address and address + 1
void EEPROMWriteInt(int p_address, int p_value){
	byte lowbyte = ((p_value >> 0) & 0xFF);
	byte highbyte = ((p_value >> 8) & 0xFF);
	
	EEPROM.write(p_address, lowbyte);
	EEPROM.write(p_address + 1, highbyte);
}

//This function will read a 2 byte integer from the eeprom at the specified address and address + 1
unsigned int EEPROMReadInt(int p_address){
	byte lowbyte = EEPROM.read(p_address);
	byte highbyte = EEPROM.read(p_address + 1);
	
	return ((lowbyte << 0) & 0xFF) + ((highbyte << 8) & 0xFF00);
}


void storeCalibratedAnalogs(OSHANDLES * osHandles){
	store_int16_array_eeprom( osHandles->calib_low_vals,  4, ANALOG_CALIB_L_START);
	store_int16_array_eeprom( osHandles->calib_high_vals, 4, ANALOG_CALIB_H_START);
}


void readSettings(OSHANDLES * osHandles){
	retrive_int16_array_eeprom( osHandles->calib_low_vals,  4, ANALOG_CALIB_L_START);
	retrive_int16_array_eeprom( osHandles->calib_high_vals, 4, ANALOG_CALIB_H_START);
	
	retrive_int16_array_eeprom( osHandles->Telemetry.pid_values, NUM_PID_VALUES, PID_VALS_START_ADDR);

	osHandles->transmit_rate = EEPROMReadInt(TRANS_RATE_ADDR);
	osHandles->mode = STANDBY;
	
	//lcd startup//
	pinMode(lcd_backlight_pin, OUTPUT);
	delay(10);
	if (EEPROM.read(FANCY_STARTUP_ADDR)) { //fancy startup mode. (fades in nicely)
		digitalWrite(lcd_backlight_pin,0); //start with backlight off.
		prog_char tim_obrien[] PROGMEM =		"  tim o'brien   ";
		printPGMStr(tim_obrien);
		delay(1);
		for ( uint8_t i = 0; i < EEPROM.read(DISPLAY_BRIGHT_ADDR); i++ ){ //fade in the display
			analogWrite(lcd_backlight_pin, i);
			delay(3);
		}
		delay(400);
	}
	else analogWrite(lcd_backlight_pin, EEPROM.read(DISPLAY_BRIGHT_ADDR)); //fast startup
}

void store_int16_array_eeprom(int16_t * arry, byte length, byte beginning_address) {
	for (uint8_t i = 0; i<length; i++) {
		EEPROMWriteInt( beginning_address + i*2, arry[i] );
	}
}

void retrive_int16_array_eeprom(int16_t * arry, byte length, byte beginning_address) {
	for (uint8_t i = 0; i<length; i++) {
		arry[i] = EEPROMReadInt(i*2 + beginning_address);
	}
}

void reset_eeprom(OSHANDLES * osHandles) {
	EEPROM.write(DISPLAY_BRIGHT_ADDR, 255);  //full LCD brightness
	analogWrite(lcd_backlight_pin, 255);  //write changes
	
	osHandles->transmit_rate = 100;  //default transmit rate
	EEPROMWriteInt(48, osHandles->transmit_rate);  //save it
	
	for (byte i = 0; i < NUM_PID_VALUES; i++) osHandles->Telemetry.pid_values[i] = 0; //clear stored PIDs
	osHandles->Telemetry.pid_values[0] = 300; // pitch.p = 3.0
	osHandles->Telemetry.pid_values[3] = 300; // roll.p  = 3.0
	osHandles->Telemetry.pid_values[6] = 700; // yaw.p   = 7.0
	store_int16_array_eeprom( osHandles->Telemetry.pid_values, NUM_PID_VALUES, PID_VALS_START_ADDR );
}


