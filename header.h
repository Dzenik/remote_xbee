typedef uint8_t byte;  //would be redundant.. if this weren't a header file.

// very important structure decleration for remote stick/gimble position data
typedef struct  {
	unsigned int th;
	unsigned int ya;
	unsigned int x;
	unsigned int y;
} Sticks;

#define LOWERLIMIT 1000
#define UPPERLIMIT 2000

//scale max/min range by a percentage
// minimum is 0, max is 100 (%)
int ScaleRange(float scaleFactor){
	return (int)((UPPERLIMIT-LOWERLIMIT)*(scaleFactor/100)+LOWERLIMIT);
}

typedef struct  {
	float roll;
	float pitch;
	int x;
	int y;
	int ya;
	int th;
	char armed;
	char mode;
	int r;  //for rover
	int l;	//for rover
	int bright; //for rover
} Telemetry;
Telemetry telemetry = {0,0,0,0,0,0,'?','?',0,0,0};
typedef struct  {
	float roll;
	float pitch;
	float other;
} PidGains;
PidGains pidGains = {0,0};


//ajustable prefrences for high/low ranges for map function
Sticks CalibLow;
Sticks CalibHigh;

//controller pin setup
LiquidCrystal lcd(2,3,4,5,6,7);
const int lcdPower = 8;
const int ledRight =  10;
const int ledLeft =  11;
const int thAnalogPin = 2;
const int yaAnalogPin = 3;
const int yAnalogPin = 0;
const int xAnalogPin = 1;

//are the leds off or on? set in the menu
byte ledsOn;

//transmition mode, set in the menu.
byte transmitMode;
#define CARmode 0
#define QUADmode 1

unsigned int transmitRate;

//controller mode declerations
#define STANDBY 0
#define TRANSMITTING 1
#define MENU 2
byte mode = STANDBY;

byte connectionEstablished = 0;


long packetsSent = 0;

// needs it's own declaration so legnth is optional
void printPGMStr(const prog_char* thisStr, byte n = 16);
