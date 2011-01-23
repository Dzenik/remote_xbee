
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

/*-- for PID storage --*/
#define NUM_PID_VALUES 9 //how many PID int16_t's there are
//just_updated meanings
#define NO_PIDs_RECIEVED 0
#define PIDs_ARE_CURRENT 1 //if quad and remote are in sync (should be at least)
#define PIDs_CHANGED 2     //used if PIDs are changed locally, not on quad yet.
// if just_updated is > PIDs_CHANGED then we're trying to send values to quad

//controller mode declerations
#define STANDBY 0
#define TRANSMITTING 1
#define MENU 2


typedef struct
{
	struct {
		int16_t pid_values[NUM_PID_VALUES];
		uint8_t just_updated;
	} Telemetry;

	Sticks current_analogs;
	
	//ajustable prefrences for high/low ranges for map function
	int16_t calib_low_vals[4];
	int16_t calib_high_vals[4];
	
	uint16_t transmit_rate;
	
	uint8_t mode;

}OSHANDLES;


// needs it's own declaration so legnth is optional
void printPGMStr(const prog_char* thisStr, uint8_t n = 16);


#endif /* OSHANDLES_H */
