#include "osHandles.h"


prog_char str_standby_mode[] PROGMEM =		"Standby Mode    ";
uint8_t ui_x_nav = 0, max_ui_x_nav = 4;

void print_standby_display(OSHANDLES * osHandles){
	lcd.setCursor(0,0);
	printPGMStr(str_standby_mode);
	lcd.setCursor(0,1);
	switch (ui_x_nav){
		case 0:
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
		break;
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

/*
	connectionEstablished = 0;	// just being sure we don't go back to transmit and think it is
	if (standbyDisplayState == 1)
		printValues( Values );
	else {
		lcd.setCursor(0,0);
		printPGMStr(strTransMode[ limit(transmitMode,0,1) ]);
		lcd.setCursor(0,1);
		lcd.print("sent:");
		lcd.print(packetsSent);

		lcd.print(" m:");
		lcd.print(standbyDisplayState);
	}

	//// horizontal navigation ////
	if ((Values->x > ScaleRange(60)) && (standbyDisplayState <2)){
		standbyDisplayState++;
		delay(200);
		lcd.clear();
	}
	if ((Values->x < ScaleRange(40)) && (standbyDisplayState >0)){
		standbyDisplayState--;
		delay(200);
	}
*/
}



prog_char str_transmit_mode[] PROGMEM =		"Transmit Mode   ";
prog_char str_trans_no_comm[] PROGMEM =		" comm !estblshd ";

void print_flying_display(OSHANDLES * osHandles){
	lcd.setCursor(0,0);
	printPGMStr(str_transmit_mode);
	lcd.setCursor(0,1);
	if (osHandles->Telemetry.just_updated == PIDs_ARE_CURRENT) {
		//communication established, PIDs are correct
		lcd.print( osHandles->Telemetry.pid_values[0]/10 );
		lcd.print( ' ' );
		lcd.print( osHandles->Telemetry.pid_values[3]/10 );
		lcd.print("      ");
	}
	else { 
		if (!((millis()/300)%4)) { //keep resending values, not to often though.
			send_some_int16s(SETTINGS_COMM,RECIEVE_PIDS,osHandles->Telemetry.pid_values,9);
			++osHandles->Telemetry.just_updated;
		}
		lcd.print(" !C -> [sent");
		lcd.print( (osHandles->Telemetry.just_updated)-PIDs_CHANGED );
		lcd.print("]");
	}
}






