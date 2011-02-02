
#ifndef EEPROM-PGM_H
#define PGM_H

#include "osHandles.h"

/*------ EEPROM space allocatin ------*/
#define FANCY_STARTUP_ADDR 0		//0
#define DISPLAY_BRIGHT_ADDR 1		//1
#define PID_PROFILE_ADDRESS 2		//2
#define TRANS_RATE_ADDR 3			//3-4
	/*--some extra space--*/
#define ANALOG_CALIB_L_START 8		//8-15
#define ANALOG_CALIB_H_START 16		//16-24
#define PROFILE_0_START_ADDR 25		//25-54			//mini w/small props
#define PROFILE_1_START_ADDR 55		//55-84			//mini w/big props
#define PROFILE_2_START_ADDR 85		//85-114		//big quad

/*-- for PID storage --*/
#define NUM_SETTING_VALUES 13 //how many PID int16_t's there are


//This function will write a 2 byte integer to the eeprom at the specified address and address + 1
void EEPROMWriteInt(int p_address, int p_value);
//This function will read a 2 byte integer from the eeprom at the specified address and address + 1
unsigned int EEPROMReadInt(int p_address);


void storeCalibratedAnalogs(OSHANDLES * osHandles);
void readSettings(OSHANDLES * osHandles);
void reset_eeprom(OSHANDLES * osHandles);

void store_int16_array_eeprom(int16_t * arry, uint8_t length, uint8_t beginning_address);
void retrive_int16_array_eeprom(int16_t * arry, uint8_t length, uint8_t beginning_address);


/*-------- quad settings area ---------*/

void set_quad_setting_profile(uint8_t profile_number);
void send_quadcopter_settings();
void store_setting_to_eeprom(uint8_t which_setting, int16_t what_value);
int16_t get_setting_from_eeprom(uint8_t which_setting );
uint8_t compare_quad_settings_to_eeprom(int16_t * recived_settings);
uint8_t get_setting_profile( void );

#endif