
byte toggle(byte *val){
	if (*val) {
		*val = 0;
		return 0;
	}
	else {
		*val = 1;
		return 1;
	}
}

int limit(int val, int lower, int upper){
	if (val < lower)
		val = lower;
	if (val > upper)
		val = upper;
	return val;
}

byte ledStatus = 1;
int ledAnalogIndexR = 0,ledAnalogIndexL = 18;
byte mapedAnalogs[] = {
0,0,15,30,45,60,75,90,105,120,135,150,165,180,195,210,225,240,255,255,
255,255,240,225,210,195,180,165,150,135,120,105,90,75,60,45,30,15,0,0 };
long lastLEDUpdate = 0;
void led_status(int mode){
	if (ledsOn){
		//// flashing on/off
		if ((mode == STANDBY) && ((millis() - lastLEDUpdate) > 500)){
			lastLEDUpdate = millis();
			toggle(&ledStatus);
			digitalWrite(ledRight, ledStatus );
			digitalWrite(ledLeft, !ledStatus );
		}

		//// fading in/out
		else if ((mode == TRANSMITTING) && ((millis() - lastLEDUpdate) > 30)){
			lastLEDUpdate = millis();
			analogWrite(ledRight, mapedAnalogs[ledAnalogIndexR] );
			analogWrite(ledLeft, mapedAnalogs[ledAnalogIndexL] );
			ledAnalogIndexR++;
			if (ledAnalogIndexR > 39)
				ledAnalogIndexR = 0;
			ledAnalogIndexL++;
			if (ledAnalogIndexL > 39)
				ledAnalogIndexL = 0;
		}
		else if ((mode == MENU) && ((millis() - lastLEDUpdate) > 500)){
			lastLEDUpdate = millis();
			int thisTime = toggle(&ledStatus);
			digitalWrite(ledRight, thisTime );
			digitalWrite(ledLeft, thisTime );

		}
	}
}

char* statusBar(int num255,char * output,char block,char point, char backed){
	int num = limit(map(num255,0,255,0,7),0,7);
	if ((num <= 7)&&(num >= 0)){
		for (int i=0;i<=num; i++)
			output[i] = block;
		output[num] = point;
		for (int i=num+1;i<=7; i++)
			output[i] = backed;
	}
	return output;
}

Sticks getControls(){
	Sticks NewAnalogReadings;
	NewAnalogReadings.th = limit(map(analogRead(thAnalogPin),CalibLow.th,CalibHigh.th,LOWERLIMIT,UPPERLIMIT),LOWERLIMIT,UPPERLIMIT);  //throttle
	NewAnalogReadings.ya = limit(map(analogRead(yaAnalogPin),CalibLow.ya,CalibHigh.ya,LOWERLIMIT,UPPERLIMIT),LOWERLIMIT,UPPERLIMIT);  //yaw
	NewAnalogReadings.y  = limit(map(analogRead(yAnalogPin),CalibLow.y,CalibHigh.y,LOWERLIMIT,UPPERLIMIT),LOWERLIMIT,UPPERLIMIT);   //pitch
	NewAnalogReadings.x  = limit(map(analogRead(xAnalogPin),CalibLow.x,CalibHigh.x,LOWERLIMIT,UPPERLIMIT),LOWERLIMIT,UPPERLIMIT);   //roll

	return NewAnalogReadings;
}

void sendPacket(Sticks * AlgVals){
	packetsSent++;
	if (transmitMode == CARmode){
		Serial.print("c");
		//Serial.print( AlgVals->th, BYTE );
		Serial.print( map(AlgVals->x,1000,2000,0,255), DEC );
		comma();
		Serial.print( map(AlgVals->y,1000,2000,0,255), DEC );
		comma();
		Serial.print( map(AlgVals->th,1000,2000,0,255), DEC );
		Serial.println(',');
	}
	else if (transmitMode == QUADmode){
		// q1500,1500,1500,1000,
		Serial.print("q");
		Serial.print( AlgVals->x, DEC );
		comma();
		Serial.print( AlgVals->y, DEC );
		comma();
		Serial.print( AlgVals->ya, DEC );
		comma();
		Serial.print( AlgVals->th, DEC );
		comma();
		Serial.println("");
	}
}

void printValues(Sticks * AlgVals){
	lcd.setCursor(0,1);
	lcd.print( AlgVals->th );
	lcd.print( "  " );
	lcd.setCursor(8,1);
	lcd.print( AlgVals->ya );
	lcd.print( "  " );
	lcd.setCursor(0,0);
	lcd.print( AlgVals->y );
	lcd.print( "  " );
	lcd.setCursor(8,0);
	lcd.print( AlgVals->x );
	lcd.print( "  " );
}

void printGraphs(Sticks * AlgVals){
	char output[9] = "        ";
	lcd.setCursor(0,1);
	lcd.print( statusBar( AlgVals->th, output ,'-','|',' '));  //throttle

	lcd.setCursor(8,1);
	lcd.print( statusBar(AlgVals->ya, output ,' ','|','-'));  //yaw

	lcd.setCursor(0,0);
	lcd.print( statusBar(AlgVals->y, output ,'-','|',' '));  //pitch

	lcd.setCursor(8,0);
	lcd.print( statusBar(AlgVals->x, output ,' ','|','-'));  //roll
}

byte checkMode(Sticks * Values, byte oldMode){
	if ((Values->th < ScaleRange(5)) && (Values->ya < ScaleRange(5)) && (Values->x < ScaleRange(5)) && (Values->y < ScaleRange(5)) && (oldMode == STANDBY)){
		delay(100);
		return MENU;
	}
	if ((Values->th < ScaleRange(5)) && (Values->ya > ScaleRange(95)) && (oldMode == STANDBY)){
		lastModeSwitch = millis();
		lcd.clear();
		return TRANSMITTING;

	}
	if ((Values->th < ScaleRange(5)) && (Values->ya < ScaleRange(5)) && (oldMode == TRANSMITTING)){
		lastModeSwitch = millis();
		lcd.clear();
		if (transmitMode == QUADmode)
			Serial.print('X');
		return STANDBY;
	}
	if ((Values->th < ScaleRange(5)) && (Values->ya < ScaleRange(5)) && (Values->x < ScaleRange(95)) && (Values->y > 10) && (oldMode == MENU)){
		lastModeSwitch = millis();
		return STANDBY;
	}
	else
		return oldMode;
}

void testForCalibration(){
	int testValue = map(analogRead(yAnalogPin),CalibLow.th,CalibHigh.th,0,255);
	if ((testValue > 255)||(testValue < 0))
		runCalibration();
}

