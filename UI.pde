
prog_char str_standby_mode[] PROGMEM =		"Standby Mode    ";

void print_standby_display(Sticks Values){
	lcd.setCursor(0,0);
	printPGMStr(str_standby_mode);
	lcd.setCursor(0,1);
	lcd.print("t: ");
	lcd.print(Values.th);
	lcd.print("  ");
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

void print_flying_display(Sticks Values){
	lcd.setCursor(0,0);
	printPGMStr(str_transmit_mode);
	lcd.setCursor(0,1);
	lcd.print("ya: ");
	lcd.print(Values.ya);
	lcd.print("  ");
	/*
	if (!connectionEstablished){
		lcd.setCursor(0,0);
		printPGMStr(str_transmit_mode);
	}
	else {
		lcd.setCursor(0,0);
		lcd.print(telemetry.pitch);
		lcd.print(' ');
		lcd.print(telemetry.roll);
		lcd.print("   ");
		lcd.setCursor(14,1);
		lcd.print(telemetry.armed);
		lcd.print(telemetry.mode);
	}*/
}






