
#ifndef EEPROM-PGM_H
#define PGM_H

#include "osHandles.h"

#define FANCY_STARTUP_ADDR 45
#define DISPLAY_BRIGHT_ADDR 46
#define TRANS_RATE_ADDR 48
#define TRANS_RATE_ADDR 48

#define ANALOG_CALIB_L_START 50 //50-57
#define ANALOG_CALIB_H_START 58 //58-65
#define PID_VALS_START_ADDR 70  //70-88


//This function will write a 2 byte integer to the eeprom at the specified address and address + 1
void EEPROMWriteInt(int p_address, int p_value);
//This function will read a 2 byte integer from the eeprom at the specified address and address + 1
unsigned int EEPROMReadInt(int p_address);


void storeCalibratedAnalogs(OSHANDLES * osHandles);
void readSettings(OSHANDLES * osHandles);
void reset_eeprom(OSHANDLES * osHandles);

void store_int16_array_eeprom(int16_t * arry, uint8_t length, uint8_t beginning_address);
void retrive_int16_array_eeprom(int16_t * arry, uint8_t length, uint8_t beginning_address);


#endif