#include "osHandles.h"


prog_char str_standby_mode[] PROGMEM =		"Standby Mode    ";
uint8_t ui_x_nav = 0, max_ui_x_nav = 4;

void print_standby_display(OSHANDLES * osHandles){
	lcd.setCursor(0,0);
	printPGMStr(str_standby_mode);
	lcd.setCursor(0,1);
	switch (ui_x_nav){
		/*case 0:
		lcd.print("pch.P: ");
		lcd.print(osHandles->Telemetry.pid_values[0]/10);
		lcd.print("  ");
		break;
		case 1:
		lcd.print("rll.P: ");
		lcd.print(osHandles->Telemetry.pid_values[3]/10);
		lcd.print("  ");
		break;
		case 2:
		lcd.print("ya.P: ");
		lcd.print(osHandles->Telemetry.pid_values[4]/10);
		lcd.print("  ");
		break;*/
		default:
		case 3:
		lcd.print("t: ");
		lcd.print(osHandles->current_analogs.th);
		lcd.print("  ");
		break;
	}
	
	
	//x navigation
	if ((osHandles->current_analogs.x > 1700 ) && (ui_x_nav < max_ui_x_nav)){
		ui_x_nav++;
		delay(200);
		lcd.clear();
	}
	if ((osHandles->current_analogs.x < 1300 ) && (ui_x_nav >0)){
		ui_x_nav--;
		delay(200);
	}
}



prog_char str_transmit_mode[] PROGMEM =		"Transmit Mode   ";
prog_char str_sett_mismatch[] PROGMEM =		"  data mismatch ";
prog_char str_no_comm[] PROGMEM =			"  no comm       ";
prog_char str_settings_OK[] PROGMEM =		"   settings OK  ";

void print_flying_display(OSHANDLES * osHandles){
	lcd.setCursor(0,0);
	printPGMStr(str_transmit_mode);
	lcd.setCursor(0,1);
	
	if (osHandles->last_mode != TRANSMITTING) { //we just started transmitting then.
		osHandles->quad_settings_status = NO_COMM_YET;
		//send_quadcopter_settings();
		//delay(10);
		send_byte_packet(SETTINGS_COMM,(uint8_t) 'p'); //send request for pid values.
		return;
	}
	
	if (osHandles->quad_settings_status == CORRECT_SETTINGS) {
		//communication established, PIDs are correct
		printPGMStr(str_settings_OK);
	}
	else { 
		if (!((millis()/300)%4)) { //keep requesting values, not to often though.
			if (osHandles->quad_settings_status == SETTINGS_MISMATCH) {
				send_quadcopter_settings(); //send updated values.
				delay(10);
			}
			send_byte_packet(SETTINGS_COMM,(uint8_t) 'p'); //send request for pid values.
		}
		if (osHandles->quad_settings_status == SETTINGS_MISMATCH) printPGMStr(str_sett_mismatch);
		else printPGMStr(str_no_comm);
	}
}






