
#include "WProgram.h"
#include <EEPROM.h> //Needed to access the eeprom read write functions
#include <avr/pgmspace.h>
#include "EepromPgm.h"
#include "osHandles.h"
#include <ser_pkt.h>

typedef uint8_t byte;  //would be redundant.. if this weren't a header file.

/*----- variables just within scope for this library -----*/
uint8_t quad_settings_starting_location; //stores what memory address we start saving PIDs at.


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


prog_char tim_obrien[] PROGMEM =		"  tim o'brien   ";

void readSettings(OSHANDLES * osHandles){
	retrive_int16_array_eeprom( osHandles->calib_low_vals,  4, ANALOG_CALIB_L_START);
	retrive_int16_array_eeprom( osHandles->calib_high_vals, 4, ANALOG_CALIB_H_START);
	
	//retrive_int16_array_eeprom( osHandles->Telemetry.pid_values, NUM_SETTING_VALUES, PID_0_VALS_START_ADDR);

	osHandles->transmit_rate = EEPROMReadInt(TRANS_RATE_ADDR);
	osHandles->mode = STANDBY;
	
	set_quad_setting_profile( EEPROM.read(PID_PROFILE_ADDRESS) );
	
	//lcd startup//
	pinMode(lcd_backlight_pin, OUTPUT);
	delay(10);
	if (EEPROM.read(FANCY_STARTUP_ADDR)) { //fancy startup mode. (fades in nicely)
		digitalWrite(lcd_backlight_pin,0); //start with backlight off.
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
	EEPROMWriteInt(TRANS_RATE_ADDR, osHandles->transmit_rate);  //save it
	
	EEPROM.write(PID_PROFILE_ADDRESS,0);
	set_quad_setting_profile(0);
	
	int16_t default_settings[NUM_SETTING_VALUES] = {400,5,0, 400,5,0, 840,1,0, 20,20, 0, 7};
	store_int16_array_eeprom( default_settings, NUM_SETTING_VALUES, PROFILE_0_START_ADDR );
	store_int16_array_eeprom( default_settings, NUM_SETTING_VALUES, PROFILE_1_START_ADDR );
	store_int16_array_eeprom( default_settings, NUM_SETTING_VALUES, PROFILE_2_START_ADDR );
}




/*-------- quad settings area ---------*/

void set_quad_setting_profile(uint8_t profile_number){
	uint8_t profile_locations[] = {PROFILE_0_START_ADDR, PROFILE_1_START_ADDR, PROFILE_2_START_ADDR};
	if (profile_number > sizeof(profile_locations)) return; //error checking.
	quad_settings_starting_location = profile_locations[profile_number];
	EEPROM.write(PID_PROFILE_ADDRESS, profile_number);
}

void send_quadcopter_settings(){
	int16_t quad_settings[NUM_SETTING_VALUES] = {0};
		
	retrive_int16_array_eeprom( quad_settings, NUM_SETTING_VALUES, quad_settings_starting_location );
	
	send_some_int16s(SETTINGS_COMM, REMOTE_2_QUAD_SETTINGS, quad_settings, NUM_SETTING_VALUES);
}

void store_setting_to_eeprom(uint8_t which_setting, int16_t what_value){
	uint8_t address = which_setting*2 + quad_settings_starting_location;			//get address to store to
	if (address > (NUM_SETTING_VALUES*2+quad_settings_starting_location)) return;	//error checking.
	EEPROMWriteInt(address, what_value);
}

int16_t get_setting_from_eeprom(uint8_t which_setting ){
	uint8_t address = which_setting*2 + quad_settings_starting_location;			//get address to store to
	if (address > (NUM_SETTING_VALUES*2+quad_settings_starting_location)) return 0;	//error checking.
	return EEPROMReadInt(address);
}

uint8_t get_setting_profile( void ){ return EEPROM.read(PID_PROFILE_ADDRESS); }

uint8_t compare_quad_settings_to_eeprom(int16_t * recived_settings) {
	uint8_t success = 1;
	for (uint8_t i = 0; i<NUM_SETTING_VALUES; i++){
		int16_t eeprom_val = get_setting_from_eeprom(i);
		
		//--debug serial output--
		Serial.print("recieved[");
		Serial.print(i);
		Serial.print("] = ");
		Serial.print(recived_settings[i]);
		Serial.print(" vs ");
		Serial.println(eeprom_val);
		
		if (recived_settings[i] != eeprom_val) success = 0;
	}
	return success;
}



