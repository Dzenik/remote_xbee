
int limit(int val, int lower, int upper){
	if (val < lower)
		val = lower;
	if (val > upper)
		val = upper;
	return val;
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

