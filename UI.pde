prog_char strStandby[] PROGMEM =	":stby:";
prog_char strTransm[] PROGMEM =		":Trans:";
prog_char strWaiting[] PROGMEM =	"Waiting for data";
prog_char strTransMode_0[] PROGMEM =	"car mode        ";
prog_char strTransMode_1[] PROGMEM =	"quad mode       ";
PGM_P PROGMEM strTransMode[] = { strTransMode_0, strTransMode_1 };
prog_char strLedMode_0[] PROGMEM =	"LEDs off        ";
prog_char strLedMode_1[] PROGMEM =	"LEDs on         ";
PGM_P PROGMEM strLedMode[] = { strLedMode_0, strLedMode_1 };


//printContextualDisplay variables
unsigned long lastDisplayLoopUpdate = 0;
unsigned long lastModeSwitch = millis();
unsigned long initWaitingTime = 0;
int standbyDisplayState = 0;

void printContextualDisplay(Sticks * Values, byte *mode){
	if ((millis() - lastDisplayLoopUpdate) > 200){		// 5 frames/second
		lastDisplayLoopUpdate = millis();

		/////////////////////////////
		///////// MODE Menu /////////
		/////////////////////////////
		if (*mode == MENU)
			runConfigMenu( Values, mode );

		/////////////////////////////
		//////// STANDBY Menu ///////
		/////////////////////////////
		if (*mode == STANDBY){
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



			if ((millis() - lastModeSwitch) < 500){		// heds up display of mode change
				lcd.setCursor(0,0);
				printPGMStr(strStandby,6);
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

		}
		/////////////////////////////
		///// TRANSMITTING Menu /////
		/////////////////////////////
		if (*mode == TRANSMITTING){
			if (transmitMode == CARmode){
				if ((!connectionEstablished) && (millis()-initWaitingTime > 750)){
					lcd.setCursor(0,0);
					printPGMStr(strWaiting);
					Serial.print('?');
					initWaitingTime = millis();
				}
				else if (connectionEstablished){
					lcd.setCursor(0,0);
					lcd.print(telemetry.r);
					lcd.print(' ');
					lcd.print(telemetry.l);
					lcd.print("    ");
					lcd.setCursor(0,1);
					lcd.print(telemetry.bright);
					/*for (byte i=0;i <= telemetry.bright;i++)
						lcd.print('|');
					for (byte i=telemetry.bright;i <= 8;i++)
						lcd.print(' ');*/
				}
			}
			else if (transmitMode == QUADmode) {
				if (!connectionEstablished){
					lcd.setCursor(0,1);
					printPGMStr(strWaiting);
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
				}
			}
			if ((millis() - lastModeSwitch) < 500){
				lcd.setCursor(0,0);
				printPGMStr(strTransm,7);
				
			}
		}
	}
}






