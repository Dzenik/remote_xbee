#include <EEPROM.h> //Needed to access the eeprom read write functions

// prints 16 char long PGM strings (strings stored in program memmory)
void printPGMStr(const prog_char* thisStr, byte n) {
  for (int i=0;i<n ;i++)
    lcd.print( pgm_read_byte_near(thisStr + i) );
}


//This function will write a 2 byte integer to the eeprom at the specified address and address + 1
void EEPROMWriteInt(int p_address, int p_value){
  byte lowbyte = ((p_value >> 0) & 0xFF);
  byte highbyte = ((p_value >> 8) & 0xFF);

  EEPROM.write(p_address, lowbyte);
  EEPROM.write(p_address + 1, highbyte);
}

//This function will read a 2 byte integer from the eeprom at the specified address and address + 1
unsigned int EEPROMReadInt(int p_address){
  byte lowbyte = EEPROM.read(p_address);
  byte highbyte = EEPROM.read(p_address + 1);

  return ((lowbyte << 0) & 0xFF) + ((highbyte << 8) & 0xFF00);
}


void storeCalibratedAnalogs(){
  EEPROMWriteInt(50, CalibLow.th);
  EEPROMWriteInt(52, CalibLow.ya);
  EEPROMWriteInt(54, CalibLow.x);
  EEPROMWriteInt(56, CalibLow.y);
  EEPROMWriteInt(58, CalibHigh.th);
  EEPROMWriteInt(60, CalibHigh.ya);
  EEPROMWriteInt(62, CalibHigh.x);
  EEPROMWriteInt(64, CalibHigh.y);
}
void readSettings(){
  display_brightness = EEPROMReadInt(46);
  transmit_rate = EEPROMReadInt(48);

  CalibLow.th = EEPROMReadInt(50);
  CalibLow.ya = EEPROMReadInt(52);
  CalibLow.x = EEPROMReadInt(54);
  CalibLow.y = EEPROMReadInt(56);
  CalibHigh.th = EEPROMReadInt(58);
  CalibHigh.ya = EEPROMReadInt(60);
  CalibHigh.x = EEPROMReadInt(62);
  CalibHigh.y = EEPROMReadInt(64);
}

