
#ifndef OSHANDLES_H
#define OSHANDLES_H

#include <avr/pgmspace.h>

/*-- pin definitions --*/
#define lcd_backlight_pin 3
#define transmit_button 2
#define ledRight 10
#define ledLeft 11
#define thAnalogPin 1
#define yaAnalogPin 0
#define yAnalogPin 3
#define xAnalogPin 2


#define LOWERLIMIT 1000
#define UPPERLIMIT 2000

// very important structure decleration for remote stick/gimble position data
typedef struct  {
	uint16_t th;
	uint16_t ya;
	uint16_t x;
	uint16_t y;
} Sticks;

//for quad_settings_status
#define NO_COMM_YET 0
#define CORRECT_SETTINGS 1
#define SETTINGS_MISMATCH 2

//controller mode declerations
#define STANDBY 0
#define TRANSMITTING 1
#define MENU 2


typedef struct
{
	/*struct {
		int16_t pid_values[NUM_SETTING_VALUES];
		uint8_t just_updated;
	} Telemetry;*/
	uint8_t quad_settings_status;

	Sticks current_analogs;
	
	//ajustable prefrences for high/low ranges for map function
	int16_t calib_low_vals[4];
	int16_t calib_high_vals[4];
	
	uint16_t transmit_rate;
	
	uint8_t mode, last_mode;

}OSHANDLES;


uint8_t printPGMStr(const prog_char* thisStr); //declared here.. defined in menu.pde


#endif /* OSHANDLES_H */
