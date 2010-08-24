#include <LiquidCrystal.h>
#include <avr/pgmspace.h>
#include <avr/sleep.h>
#include "header.h"

void setup() {
  pinMode(lcdPower, OUTPUT);
  digitalWrite(lcdPower,HIGH );
  delay(10);
  lcd.begin(16, 2);
  Serial.begin(115200);
  pinMode(ledRight, OUTPUT);
  pinMode(ledLeft, OUTPUT);
  readSettings();
}

unsigned long lastLoopUpdate = 0;
void loop(){
  if (lastLoopUpdate == 0)            //run calibration if values are funky 
    testForCalibration();             //   only runs first time through loop

  Sticks Values = getControls();      //get the analog stick positions
  mode = checkMode( &Values, mode );  //check mode from those positions


  if ((millis() - lastLoopUpdate) > transmitRate){
    lastLoopUpdate = millis();
    if (mode == TRANSMITTING)
      sendPacket( &Values );
  }

  led_status( mode );                       //does awesome stuff with the leds
  printContextualDisplay( &Values, &mode );  //prints display depending on context
  readSerialCommand();
  
  delay(5);
}
