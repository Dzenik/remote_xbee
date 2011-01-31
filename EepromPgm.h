
#ifndef EEPROM-PGM_H
#define PGM_H

#include "osHandles.h"

#define FANCY_STARTUP_ADDR 45		//45
#define DISPLAY_BRIGHT_ADDR 46		//46
#define PID_PROFILE_ADDRESS 47				//47
#define TRANS_RATE_ADDR 48			//48-49

#define ANALOG_CALIB_L_START 50		//50-57
#define ANALOG_CALIB_H_START 58		//58-65
#define PROFILE_0_START_ADDR 70		//70-89 //mini w/small props
#define PROFILE_1_START_ADDR 90		//90-109 //mini w/big props
#define PROFILE_2_START_ADDR 110	//110-129 //big quad


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
void store_setting_to_eeprom(uint8_t which_pid, int16_t what_value);
int16_t get_setting_from_eeprom(uint8_t which_pid );
uint8_t compare_quad_settings_to_eeprom(int16_t * recived_pids);
uint8_t get_setting_profile( void );

#endif