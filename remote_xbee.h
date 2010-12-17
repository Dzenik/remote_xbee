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

typedef struct {
	int16_t pid_values[9];
	uint8_t just_updated;
} Telemetry;
Telemetry telemetry = {0};


//ajustable prefrences for high/low ranges for map function
Sticks CalibLow;
Sticks CalibHigh;

//controller pin setup
LiquidCrystal lcd(5, 4, 9, 10, 11, 12);

#define lcd_backlight_pin 3
#define transmit_button 2
#define ledRight 10
#define ledLeft 11
#define thAnalogPin 1
#define yaAnalogPin 0
#define yAnalogPin 3
#define xAnalogPin 2

unsigned int transmit_rate;
uint8_t display_brightness;

//controller mode declerations
#define STANDBY 0
#define TRANSMITTING 1
#define MENU 2

// needs it's own declaration so legnth is optional
void printPGMStr(const prog_char* thisStr, byte n = 16);
