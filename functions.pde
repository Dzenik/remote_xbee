
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


//osHandles->calib_low_vals replaces CalibLow
Sticks getControls(OSHANDLES * osHandles){
	Sticks NewAnalogReadings;
	NewAnalogReadings.th = limit(map(analogRead(thAnalogPin),osHandles->calib_low_vals[0],osHandles->calib_high_vals[0],LOWERLIMIT,UPPERLIMIT),LOWERLIMIT,UPPERLIMIT);  //throttle
	NewAnalogReadings.ya = limit(map(analogRead(yaAnalogPin),osHandles->calib_low_vals[1],osHandles->calib_high_vals[1],LOWERLIMIT,UPPERLIMIT),LOWERLIMIT,UPPERLIMIT);  //yaw
	NewAnalogReadings.y  = limit(map(analogRead(yAnalogPin),osHandles->calib_low_vals[3],osHandles->calib_high_vals[3],LOWERLIMIT,UPPERLIMIT),LOWERLIMIT,UPPERLIMIT);   //pitch
	NewAnalogReadings.x  = limit(map(analogRead(xAnalogPin),osHandles->calib_low_vals[2],osHandles->calib_high_vals[2],LOWERLIMIT,UPPERLIMIT),LOWERLIMIT,UPPERLIMIT);   //roll

	return NewAnalogReadings;
}

