#include "osHandles.h"
#include "EepromPgm.h"

unsigned short menu_x_nav = 0, last_menu_x_nav = 0;
signed short menu_y_nav[3] = {0};
const unsigned short max_menu_x_nav = 3;
signed int max_y_nav = 1000, min_y_nav = 0;

// main menu (Flash based string table. otherwise the strings will take up ram.)
prog_char menu_0[] PROGMEM =   " -Setting adjust";
prog_char menu_1[] PROGMEM =   " -SETs profile";
prog_char menu_2[] PROGMEM =   " -zero sensors";
prog_char menu_3[] PROGMEM =   " -fancy startup";
prog_char menu_4[] PROGMEM =   " -reset eeprom";
prog_char menu_5[] PROGMEM =   " -quad telem mode";
prog_char menu_6[] PROGMEM =   " -transmit rate";
prog_char menu_7[] PROGMEM =   " -lcd brightness";
PGM_P PROGMEM menuStrings[] = {menu_0, menu_1, menu_2, menu_3, menu_4, menu_5, menu_6,menu_7 };
const byte n_choices = sizeof(menuStrings) / sizeof(char *) - 1;

//quadcopter adjust menu
prog_char pam_0[] PROGMEM =   "  -p pitch";
prog_char pam_1[] PROGMEM =   "  -i pitch";
prog_char pam_2[] PROGMEM =   "  -d pitch";
prog_char pam_3[] PROGMEM =   "  -p roll";
prog_char pam_4[] PROGMEM =   "  -i roll";
prog_char pam_5[] PROGMEM =   "  -d roll";
prog_char pam_6[] PROGMEM =   "  -p yaw";
prog_char pam_7[] PROGMEM =   "  -i yaw";
prog_char pam_8[] PROGMEM =   "  -d yaw";
prog_char pam_9[] PROGMEM =   "  -tx scale xy";
prog_char pam_10[] PROGMEM =  "  -tx scale yaw";
prog_char pam_11[] PROGMEM =   "  -mode X:0, +:1";
prog_char pam_12[] PROGMEM =  "  -LED mode";
PGM_P PROGMEM setting_adj_strings[] = 
		{ pam_0,pam_1,pam_2,pam_3,pam_4,pam_5,pam_6,pam_7,pam_8,pam_9,pam_10,pam_11,pam_12 };
const byte num_of_setting_adj_strings = sizeof(setting_adj_strings) / sizeof(char *) - 1;

prog_char strConfigMenu[] PROGMEM =		"Config menu";
prog_char strWhatRate[] PROGMEM =		"What rate?";
prog_char str_what_bright[] PROGMEM =	"What brightness?";
prog_char strAreYouSure[] PROGMEM =		"are you sure?";
prog_char strSaved[] PROGMEM =			"saved";

void print_menu_display(OSHANDLES * osHandles){
	//// print header only in root menu ////
	if (menu_x_nav == 0){
		max_y_nav = n_choices;
		min_y_nav = 0;
		print_PGM_line(strConfigMenu, 0);
		print_PGM_line(menuStrings[menu_y_nav[0]], 1);
	}

	//// not in root menu anymore ////
	else {
		switch(menu_y_nav[0]){
			case 0: //adjust PID gains
			{
				if (menu_x_nav == 1){
					max_y_nav = num_of_setting_adj_strings;
					min_y_nav = 0;
					print_PGM_line(menu_0, 0);
					print_PGM_line(setting_adj_strings[menu_y_nav[1]], 1);
				}
				else if (menu_x_nav == 2){
					print_PGM_line(setting_adj_strings[menu_y_nav[1]], 0);
					lcd.setCursor(0,0);
					 //PID adjustment 
					max_y_nav = 10000;
					min_y_nav = 0;
					if (menu_y_nav[1] == 9 || menu_y_nav[1] == 10){ min_y_nav = -50; max_y_nav = 50; }
					if (menu_y_nav[1] == 11){ min_y_nav = 0; max_y_nav = 1; }  //X or + mode
					if (menu_y_nav[1] == 12){ min_y_nav = 0; max_y_nav = 7; }  //led mode
					if (last_menu_x_nav != menu_x_nav) {
						menu_y_nav[2] = get_setting_from_eeprom(menu_y_nav[1]);
					}
					lcd.setCursor(0,1);
					lcd.print(' ');
					if (menu_y_nav[1] < 9) { lcd_print_float_1(menu_y_nav[2]); } //float values for PIDs
					else { lcd.print(menu_y_nav[2]); lcd.print(' '); }  //regular integers
				}
				else if (menu_x_nav == 3){
					if (((menu_y_nav[1]==9)||(menu_y_nav[1]==10))&&(menu_y_nav[2]==0)) //TX scale factor == 0
						{menu_y_nav[2] = 1;} //don't divide by 0.
					store_setting_to_eeprom(menu_y_nav[1], menu_y_nav[2]);
					print_PGM_line(strSaved, 0);
					delay(1000);
					menu_y_nav[2] = 0;
					menu_x_nav = 1;
					return;					
				}
				
				break;
				}
			case 1:  //change PID profile
			{
				max_y_nav = 2;
				min_y_nav = 0;
				if (menu_x_nav == 1) {
					if (last_menu_x_nav != menu_x_nav){
						menu_y_nav[1] = get_setting_profile();
						lcd.clear();
					}
					lcd.setCursor(1,7);
					lcd.print(menu_y_nav[1]);
				}
				else if (menu_x_nav == 2){
					set_quad_setting_profile(menu_y_nav[1]);
					print_PGM_line(strSaved, 0);
					delay(500);
					menu_x_nav = 0; menu_y_nav[0] = 0; menu_y_nav[1] = 0;
				}
				break;
			}
			case 2:  //zero sensors
			{
				send_byte_packet(SETTINGS_COMM,(uint8_t) 'z');
				menu_x_nav = 0;
				break;
			}
			case 3:  //fancy startup
			{
				uint8_t current = EEPROM.read(45);
				EEPROM.write(45, !current);
				lcd.print((!current)? "on":"off");
				delay(500);
				menu_x_nav = 0;
				break;
			}
			case 4:  //reset eeprom
			{
				if (menu_x_nav == 1){
					print_PGM_line(strAreYouSure, 0);
				}
				else if (menu_x_nav == 2){
					reset_eeprom( osHandles );
					print_PGM_line(strSaved, 0);
					delay(1000);
					menu_x_nav = 0;
					osHandles->mode = STANDBY;
				}
				break;
			}
			case 5:  //toggle quad telem mode
			{
				send_byte_packet(SETTINGS_COMM,(uint8_t) 'r');
				menu_x_nav = 0;
				break;
			}
			case 6:  //adjust transmit rate
			{
				max_y_nav = 10000;
				min_y_nav = 0;
				if (menu_x_nav == 1) {
					if (last_menu_x_nav != menu_x_nav)
						menu_y_nav[1] = osHandles->transmit_rate;
					print_PGM_line(strWhatRate, 0);
					lcd.setCursor(0,1);
					lcd.print(menu_y_nav[1]);
					lcd.print(" 1/s   ");
				}
				else if (menu_x_nav == 2){
					osHandles->transmit_rate = menu_y_nav[1];
					EEPROMWriteInt(TRANS_RATE_ADDR, osHandles->transmit_rate);
					print_PGM_line(strSaved, 0);
					delay(500);
					menu_x_nav = 0;
					menu_y_nav[0] = 0;
					menu_y_nav[1] = 0;
				}
				break;
				}
			case 7:  //adjust display brightness
			{
				max_y_nav = 255/8;
				min_y_nav = 0;
				if (menu_x_nav == 1) {
					if (last_menu_x_nav != menu_x_nav)
						menu_y_nav[1] = EEPROM.read(46)/8;
					print_PGM_line(str_what_bright, 0);
					analogWrite(lcd_backlight_pin, menu_y_nav[1]*8);
					lcd.setCursor(0,1);
					lcd.print(map(menu_y_nav[1],0,31,0,100));
					lcd.print("%  ");
				}
				else if (menu_x_nav == 2){
					EEPROM.write(46, menu_y_nav[1]*8);
					lcd.setCursor(0,0);
					print_PGM_line(strSaved, 0);
					menu_x_nav = 0;
					menu_y_nav[0] = 0;
					menu_y_nav[1] = 0;
				}
				break;
				}
		}  // end switch
	}


	//////// //////////////// ////////
	//////// menu nav-control ////////
	//////// //////////////// ////////
	
	last_menu_x_nav = menu_x_nav;
	////fast secondary upward navigation
	if ((osHandles->current_analogs.y > 1950 ) && (menu_y_nav[menu_x_nav] < max_y_nav)){
		menu_y_nav[menu_x_nav] = limit( (menu_y_nav[menu_x_nav]+10), min_y_nav, max_y_nav);
		delay(50);
	}
	else if ((osHandles->current_analogs.y < 1050 ) && (menu_y_nav[menu_x_nav] > min_y_nav)){
		menu_y_nav[menu_x_nav] -= 10;
		delay(50);
	}
	////slow secondary upward navigation
	else if ((osHandles->current_analogs.y > 1700 ) && (menu_y_nav[menu_x_nav] < max_y_nav)){
		menu_y_nav[menu_x_nav]++;
		delay(50);
	}
	else if ((osHandles->current_analogs.y < 1300 ) && (menu_y_nav[menu_x_nav] > min_y_nav)){
		menu_y_nav[menu_x_nav]--;
		delay(50);
	}
	//x navigation
	if ((menu_y_nav[menu_x_nav] > max_y_nav) || (menu_y_nav[menu_x_nav] < min_y_nav))
		menu_y_nav[menu_x_nav] = min_y_nav;
	if ((osHandles->current_analogs.x > 1700 ) && (menu_x_nav < max_menu_x_nav)){
		menu_x_nav++;
		delay(200);
		lcd.clear();
	}
	if ((osHandles->current_analogs.x < 1300 ) && (menu_x_nav >0)){
		menu_x_nav--;
		delay(200);
	}
}


prog_char calibStr0[] PROGMEM =		"both lower left";
prog_char calibStr1[] PROGMEM =		"now upper right";

void runCalibration(OSHANDLES * osHandles){
	lcd.clear();
	print_PGM_line(calibStr0, 0);

	for (int8_t i=3;i>=0;i--){
		lcd.setCursor(7,1);
		lcd.print(i, DEC);
		delay(1000);
	}
	
	osHandles->calib_low_vals[0] = analogRead(thAnalogPin);
	osHandles->calib_low_vals[1] = analogRead(yaAnalogPin);
	osHandles->calib_low_vals[2] = analogRead(xAnalogPin);
	osHandles->calib_low_vals[3] = analogRead(yAnalogPin);

	lcd.setCursor(0,0);
	printPGMStr(calibStr1);
	for (int8_t i=3;i>=0;i--){
		lcd.setCursor(7,1);
		lcd.print(i, DEC);
		delay(1000);
	}
	osHandles->calib_high_vals[0] = analogRead(thAnalogPin);
	osHandles->calib_high_vals[1] = analogRead(yaAnalogPin);
	osHandles->calib_high_vals[2] = analogRead(xAnalogPin);
	osHandles->calib_high_vals[3] = analogRead(yAnalogPin);

	lcd.clear();
	delay(1000);
	storeCalibratedAnalogs(osHandles);
}


void lcd_print_float_1(int16_t val){
	lcd.print(val/10);
	lcd.print('.');
	lcd.print(val%10,DEC);
}

void print_PGM_line(const prog_char* thisStr, uint8_t line){
	lcd.setCursor(0,line);
	uint8_t printed = printPGMStr(thisStr);
	while((printed++)<16) { lcd.print(' '); } //finish the line off with spaces
}

// prints 16 char long PGM strings (strings stored in program memmory)
uint8_t printPGMStr(const prog_char* thisStr) {
	uint8_t i = 0;
	for (; i < 16;) { //16 is max.
		char this_char = pgm_read_byte_near(thisStr + i);
		if (this_char == NULL) break;  //reached the end of the string, return.
		lcd.print( this_char );
		i++;
	}
	return i; //returns how many characters printed.
}
