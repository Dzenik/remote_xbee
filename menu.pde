int menuSelection = 0;
int menuSecondState = 0;
int menuSecondStateSelector = 0;
int maxSecondNav = 1000, minSecondNav = 0;

// main menu (Flash based string table. otherwise the strings will take up ram.)
prog_char menu_0[] PROGMEM =   " -quad-config   ";
prog_char menu_1[] PROGMEM =   " -set ranges    ";
prog_char menu_2[] PROGMEM =   " -transmit mode ";
prog_char menu_3[] PROGMEM =   " -transmit rate ";
prog_char menu_4[] PROGMEM =   " -leds on/off   ";
prog_char menu_5[] PROGMEM =   " -exit menu     ";
prog_char menu_6[] PROGMEM =   " -TURN OFF      ";
prog_char menu_7[] PROGMEM =   " -write defaults";
PGM_P PROGMEM menuStrings[] = {menu_0, menu_1, menu_2, menu_3, menu_4, menu_5, menu_6, menu_7 };
byte n_choices = sizeof(menuStrings) / sizeof(char *) - 1;

//quadcopter adjust menu
prog_char quadMenu_0[] PROGMEM =   " -set quad level";
prog_char quadMenu_1[] PROGMEM =   " -flight mode   ";
prog_char quadMenu_2[] PROGMEM =   " -pulse a motor ";
prog_char quadMenu_3[] PROGMEM =   " -set pid values";
PGM_P PROGMEM quadStrings[] = {	quadMenu_0,quadMenu_1,quadMenu_2 };
byte numOfQuadStrings = sizeof(quadStrings) / sizeof(char *) - 1;

prog_char calibStr0[] PROGMEM =		"both lower left ";
prog_char calibStr1[] PROGMEM =		"now upper right ";
prog_char strConfigMenu[] PROGMEM =	"Config menu     ";
prog_char strQuadMenu[] PROGMEM =	"Quad Config menu";
prog_char strWhatRate[] PROGMEM =	"What rate?      ";
prog_char strGoodbye[] PROGMEM =	"goodbye";
prog_char strSaved[] PROGMEM =		"saved";

void runConfigMenu(Sticks * Values, byte *mode){
	connectionEstablished = 0;	// just being sure we don't go back to transmit and think it is
	//// print header only in root menu ////
	if (menuSecondState == 0){
		lcd.setCursor(0,0);
		printPGMStr(strConfigMenu);
		lcd.setCursor(0,1);
		printPGMStr(menuStrings[menuSelection]);
	}

	//// not in root menu anymore ////
	if (menuSecondState){
		switch(menuSelection){
			case 0:{
				maxSecondNav = numOfQuadStrings;
				minSecondNav = 0;
				if(menuSecondState == 1){
					lcd.setCursor(0,0);
					printPGMStr(strQuadMenu);
					lcd.setCursor(0,1);
					printPGMStr(quadStrings[menuSecondStateSelector]);
				}
				else {
					switch (menuSecondStateSelector){
						case 0:{
							Serial.print('r');
							menuSecondState = 1;
							break;
							} //set quad level
						case 1:{
							Serial.print('$');
							menuSecondState = 1;
							break;
							} //set flight mode
						case 2:{
							Serial.print('m');
							byte whichMotor = millis()%4;
							Serial.print(whichMotor,DEC);
							Serial.println(',');
							lcd.clear();
							lcd.print("pulsed m");
							lcd.print(whichMotor,DEC);
							delay(500);
							menuSecondState = 1;
							menuSelection = 0;
							break;
							} //pulse a motor
						case 3:{
							Serial.print('B');
							pidGains.roll = readFloatSerial();
							pidGains.other = readFloatSerial();
							pidGains.other = readFloatSerial();
							pidGains.pitch = readFloatSerial();
							pidGains.other = readFloatSerial();
							pidGains.other = readFloatSerial();
							lcd.clear();
							lcd.print(pidGains.roll);
							lcd.print("  ");
							lcd.print(pidGains.pitch);
							delay(500);
							menuSecondState = 1;
							menuSelection = 0;
							break;
							} //set pid values
					}
				}
				break;
				} //quad configuration
			case 1:{
				runCalibration();
				*mode = STANDBY;
				lcd.clear();
				menuSecondState = 0;
				break;
				} //set ranges
			case 2:{
				EEPROM.write(41, toggle(&transmitMode));
				printPGMStr(strTransMode[ limit(transmitMode,0,1) ]);
				delay(500);
				menuSecondState = 0;
				break;
				} //transmit mode
			case 3:{
				maxSecondNav = 10000;
				minSecondNav = 0;
				if (menuSecondState == 1) {
					if (menuSecondStateSelector == 0)
						menuSecondStateSelector = transmitRate;
					lcd.setCursor(0,0);
					printPGMStr(strWhatRate);
					lcd.setCursor(0,1);
					lcd.print(menuSecondStateSelector);
					lcd.print(" 1/s   ");
				}
				else if (menuSecondState == 2){
					transmitRate = menuSecondStateSelector;
					EEPROMWriteInt(48, transmitRate);
					lcd.setCursor(0,0);
					printPGMStr(strSaved,5);
					delay(500);
					menuSecondState = 0;
					menuSecondStateSelector = 0;
				}
				break;
				} //transmit RATE
			case 4:{
				EEPROM.write(40, toggle(&ledsOn));
				printPGMStr(strLedMode[ limit(ledsOn,0,1) ]);
				delay(500);
				menuSecondState = 0;
				break;
				} //leds on/off
			case 5:{
				*mode = STANDBY;
				lcd.clear();
				menuSecondState = 0;
				menuSelection = 0;
				break;
				} //exit mrnu
			case 6:{
				if (menuSecondState == 1) {
					lcd.setCursor(0,0);
					lcd.print("sure?");
				}
				else if (menuSecondState == 2)
					sleepNow();
				break;
				} //TURN OFF
			case 7:{
				if (menuSecondState == 1) {
					lcd.setCursor(0,0);
					lcd.print("sure?");
				}
				else if (menuSecondState == 2)
					writeDefaultSettings();
				break;
				} //write default settings
		}  // end switch
	}


	//////// //////////////// ////////
	//////// menu nav-control ////////
	//////// //////////////// ////////
	if (menuSecondState == 0){
		if ((Values->y < ScaleRange(40) ) && (menuSelection < n_choices)){
			menuSelection++;
			delay(200);
		}
		else if ((Values->y > ScaleRange(60) ) && (menuSelection >0)){
			menuSelection--;
			delay(200);
		}
	}
	else {
		////fast secondary upward navigation
		if ((Values->y > ScaleRange(75) ) && (menuSelection < maxSecondNav)){
			menuSecondStateSelector += 10;
			delay(200);
		}
		else if ((Values->y < ScaleRange(25) ) && (menuSelection > minSecondNav)){
			menuSecondStateSelector -= 10;
			delay(200);
		}
		////slow secondary upward navigation
		else if ((Values->y > ScaleRange(60) ) && (menuSelection < maxSecondNav)){
			menuSecondStateSelector++;
			delay(200);
		}
		else if ((Values->y < ScaleRange(40) ) && (menuSelection > minSecondNav)){
			menuSecondStateSelector--;
			delay(200);
		}
	}
	if ((menuSecondStateSelector > maxSecondNav) || (menuSecondStateSelector < minSecondNav))
		menuSecondStateSelector = minSecondNav;
	if ((Values->x > ScaleRange(60) ) && (menuSecondState <2)){
		menuSecondState++;
		delay(200);
		lcd.clear();
	}
	if ((Values->x < ScaleRange(40) ) && (menuSecondState >0)){
		menuSecondState--;
		delay(200);
	}
}



void runCalibration(){
	lcd.clear();
	lcd.setCursor(0,0);
	printPGMStr(calibStr0);

	for (int i=3;i>=0;i--){
		lcd.setCursor(7,1);
		lcd.print(i);
		delay(1000);
	}
	CalibLow.th = analogRead(thAnalogPin);
	CalibLow.ya = analogRead(yaAnalogPin);
	CalibLow.x = analogRead(xAnalogPin);
	CalibLow.y = analogRead(yAnalogPin);

	lcd.setCursor(0,0);
	printPGMStr(calibStr1);
	for (int i=3;i>=0;i--){
		lcd.setCursor(7,1);
		lcd.print(i);
		delay(1000);
	}
	CalibHigh.th = analogRead(thAnalogPin);
	CalibHigh.ya = analogRead(yaAnalogPin);
	CalibHigh.x = analogRead(xAnalogPin);
	CalibHigh.y = analogRead(yAnalogPin);
	lcd.clear();
	delay(1000);
	storeCalibratedAnalogs();
}

void sleepNow(){         // here we put the arduino to sleep
	lcd.clear();
	printPGMStr(strGoodbye,7);
	delay(500);

	//turn everything off:
	digitalWrite(lcdPower,LOW );
	pinMode(lcdPower, INPUT);
	digitalWrite(ledRight,LOW );
	pinMode(ledRight, INPUT);
	digitalWrite(ledLeft,LOW );
	pinMode(ledLeft, INPUT);


	set_sleep_mode(SLEEP_MODE_PWR_DOWN);   // sleep mode is set here
	sleep_enable();          // enables the sleep bit in the mcucr register
	sleep_mode();            // here the device is actually put to sleep!!
	// THE PROGRAM CONTINUES FROM HERE AFTER WAKING UP

	sleep_disable();         // first thing after waking from sleep:
	// disable sleep...
}
	