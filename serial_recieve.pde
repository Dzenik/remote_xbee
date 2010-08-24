
void readSerialCommand() {
	// Check for serial message
	if (Serial.available()) {
		byte queryType = Serial.read();
		switch (queryType) {
			case 'i':	//initiate communication / recieve telemetry
				connectionEstablished = 1;
				telemetry.roll = readFloatSerial();
				telemetry.pitch = readFloatSerial();
				telemetry.x = readInt();//roll
				telemetry.y = readInt();//pitch
				telemetry.ya = readInt();//yaw
				telemetry.th = readInt();//throttle
				
				telemetry.armed = Serial.read();
				telemetry.mode = Serial.read();
				break;
			case 'r':	//initiate communication / recieve telemetry
				connectionEstablished = 1;
				telemetry.r = readInt();
				telemetry.l = readInt();
				telemetry.bright = readInt();
				break;
			case 's':	// set ranges
				runCalibration();
				Serial.println("done clb");
				break;
			case 'o':	//read eeprom values
				printCurrentValues();
				break;
			case 'p':	//reset eeprom values to defaults
				writeDefaultSettings();
				break;
		}
	}
}

void comma(){
	Serial.print(',');
}
void printCurrentValues(){
	Serial.print(EEPROM.read(40),DEC);	//ledsOn
	comma();
	Serial.print(EEPROM.read(41),DEC);	//transmitMode
	comma();
	Serial.print(EEPROMReadInt(48),DEC);	//transmitRate
	comma();
	comma();
	Serial.print(EEPROMReadInt(50));	//CalibLow.th
	comma();
	Serial.print(EEPROMReadInt(52));	//CalibLow.ya
	comma();
	Serial.print(EEPROMReadInt(54));	//CalibLow.x
	comma();
	Serial.print(EEPROMReadInt(56));	//CalibLow.y
	comma();
	Serial.print(EEPROMReadInt(58));	//CalibHigh.th
	comma();
	Serial.print(EEPROMReadInt(60));	//CalibHigh.ya
	comma();
	Serial.print(EEPROMReadInt(62));	//CalibHigh.x
	comma();
	Serial.print(EEPROMReadInt(64));	//CalibHigh.y
	comma();
}

float readFloatSerial() {
	byte index = 0;
	byte timeout = 0;
	char data[128] = "";
	
	do {
		if (Serial.available() == 0) {
			delay(10);
			timeout++;
		}
		else {
			data[index] = Serial.read();
			timeout = 0;
			index++;
		}
	}	while (((data[limit(index-1, 0, 128)] != ',')&&(data[limit(index-1, 0, 128)] != '\n')) && (timeout < 5) && (index < 128));
	return atof(data);
}

int readInt(){
	byte index = 0;
	byte timeout = 0;
	char data[128] = "";

	do {
		if (Serial.available() == 0) {
			delay(10);
			timeout++;
		}
		else {
			data[index] = Serial.read();
			timeout = 0;
			index++;
		}
	}	while ((data[limit(index-1, 0, 128)] != ',') && (timeout < 5) && (index < 128));
	return atoi(data);
}

