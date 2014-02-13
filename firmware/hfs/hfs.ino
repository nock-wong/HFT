#define COMMAND_BUTTON_STATES 'A'
#define COMMAND_GAME_LIGHTS 'B'
#define COMMAND_WON_OR_LOSE 'C'
#define COMMAND_END_CHAR 'X'
#define COMMAND_CONNECT 'F'
#define COMMAND_START 'D'
#define COMMAND_READY 'E'
#define COMMAND_GAME_END 'G'

#define LED0 8
#define LED1 9
#define LED2 10
#define LED3 11
#define LED4 12
#define LEDLOSE 2
#define LEDWIN 3
#define BUZZER 13
#define BUTTON0 A4
#define BUTTON1 A3
#define BUTTON2 A2
#define BUTTON3 A1
#define BUTTON4 A0

#define NOT_READY 0
#define READY 1

#define LOSE 0
#define WIN 1
#define NEUTRAL 2

#define BAUD 9600
#define LED_COUNT 5
#define BUTTON_COUNT 5
#define COMMAND_SIZE 20

const int g_leds_pins[LED_COUNT] = {LED0, LED1,LED2, LED3, LED4};
const int g_buttons_pins[BUTTON_COUNT] = {BUTTON0, BUTTON1, BUTTON2, BUTTON3, BUTTON4};

int g_command_ready = false;
int g_command_index = 0;
int g_command_in[COMMAND_SIZE];

int g_buttons_changed = false;
int g_leds_states[] = {0, 0, 0, 0, 0};
int g_buttons[] = {0, 0, 0, 0, 0};

int g_connected = false;
int g_start = false;
int g_end = false;

int g_won = NEUTRAL;

void 
setup (void) 
{
  pinMode(LED0, OUTPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  pinMode(LEDWIN, OUTPUT);
  pinMode(LEDLOSE, OUTPUT);
  
  pinMode(BUTTON0, INPUT);
  pinMode(BUTTON1, INPUT);
  pinMode(BUTTON2, INPUT);
  pinMode(BUTTON3, INPUT);
  pinMode(BUTTON4, INPUT);

  pinMode(BUZZER, OUTPUT);
  Serial.begin(BAUD);
}

void
loop (void)
{ 
  // Wait for connection to game
  while(g_connected == false)
  {
    send_connect();
    read_command();
    delay(500);
  }
  // Wait for game to start
  while(g_start == false)
  {
    read_command();
  }
  // Game start
  while(g_start == true && g_end == false)
  {
    g_won = NEUTRAL;
    read_command();
    update_display();
    read_buttons();
    if (g_buttons_changed == true)
    {
      send_buttons_states();
    }
  }
  // Game end
  g_connected = false;
  g_start = false;
  g_end = false;
}

void send_connect()
{
  Serial.print(COMMAND_CONNECT);
  Serial.print(COMMAND_END_CHAR);
}

void read_command() 
{
  while (Serial.available())
  {
    int r = Serial.read();
    g_command_in[g_command_index] = r;
    g_command_index++;
    if (r == COMMAND_END_CHAR)
    {
      process_command();
    }
  }
  return;
}

void process_command()
{
  // Confirm connect
  if (g_command_in[0] == COMMAND_CONNECT)
  {
    g_connected = true;
  }
  // Start game
  if (g_command_in[0] == COMMAND_START)
  {
    g_start = true;
    start_sequence();
    send_ready();
  }
  // Sets the game lights
  if (g_command_in[0] == COMMAND_GAME_LIGHTS)
  {
    for (int i = 0; i < LED_COUNT; i++)
    {
      int state = LOW;
      switch(g_command_in[i+1])
      {
        case '0':
          state = LOW;
          break;
        case '1':
          state = HIGH;
          break;
        default:
          state = LOW;
          break;
      }
      g_leds_states[i] = state;
    }
  }
  // Sets the WIN/LOSE lights
  else if (g_command_in[0] == COMMAND_WON_OR_LOSE)
  {
    int state = LOSE;
    if (g_command_in[1] == '0')
    {
      state = LOSE;
    }
    else if (g_command_in[1] == '1')
    {
      state = WIN;
    }
    else if (g_command_in[1] == '2')
    {
      state = NEUTRAL;
    }
    g_won = state;
   }
  // Sets the end game
  else if (g_command_in[0] == COMMAND_GAME_END)
  {
    g_end = true;
    if (g_command_in[1] == '1')
    {
      digitalWrite(LEDLOSE, LOW);      
      digitalWrite(LEDWIN, HIGH);
      win();
    }
    else if (g_command_in[1] == '0')
    {
      digitalWrite(LEDLOSE, HIGH);      
      digitalWrite(LEDWIN, LOW);
      lose();
    } 
  }
  clear_command_in();
}

void start_sequence()
{
  /*
  for(int i = 0; i < LED_COUNT; i++)
  {
    digitalWrite(g_leds_pins[i], HIGH);
  }
  */
  digitalWrite(LEDLOSE, HIGH);
  playMelody("c", 1000);
  digitalWrite(LEDLOSE, LOW);
  delay(100);
  
  digitalWrite(LEDLOSE, HIGH);
  playMelody("c", 1000);
  digitalWrite(LEDLOSE, LOW);
  delay(100);
  
  digitalWrite(LEDLOSE, HIGH);
  playMelody("c", 1000);
  digitalWrite(LEDLOSE, LOW);
  delay(100);

  digitalWrite(LEDWIN, HIGH);
  playMelody("z", 1000);  
  /*
  for (int j = 0; j < 3; j++)
  {
    for(int i = 0; i < LED_COUNT; i++)
    {
      digitalWrite(g_leds_pins[i], HIGH);
    }
    delay(500);
    for(int i = 0; i < LED_COUNT; i++)
    {
      digitalWrite(g_leds_pins[i], LOW);
    }
    delay(500);
  }
  */
  return;
}

void send_ready()
{
  Serial.print(COMMAND_READY);
  Serial.print(COMMAND_END_CHAR);
  return;
}

void update_display() 
{
  for (int i = 0; i < 5; i++)
  {
    digitalWrite(g_leds_pins[i], g_leds_states[i]);
  }
  switch (g_won)
  {
    case WIN:
      digitalWrite(LEDWIN, HIGH);
      digitalWrite(LEDLOSE, LOW);
      correct();
      break;
    case LOSE:
      digitalWrite(LEDWIN, LOW);
      digitalWrite(LEDLOSE, HIGH);
      incorrect();
      break;
    case NEUTRAL:
      digitalWrite(LEDWIN, LOW);
      digitalWrite(LEDLOSE, LOW);
      break;
  }
  return;
}

void clear_command_in ()
{
  for (int i = 0; i < COMMAND_SIZE; i++)
  {
    g_command_in[i] = 0;
  }
  g_command_index = 0;
  g_command_ready = false;
  return;
}

void send_buttons_states()
{
  Serial.print(COMMAND_BUTTON_STATES);
  for (int i = 0; i < BUTTON_COUNT; i++)
  {
    Serial.print(g_buttons[i]);
  }
  Serial.print(COMMAND_END_CHAR);
}

void read_buttons (void)
{
  g_buttons_changed = false;
  int buttons_readings[BUTTON_COUNT];
  // Read buttons
  for (int i = 0; i < BUTTON_COUNT; i++)
  {
    buttons_readings[i] = !digitalRead(g_buttons_pins[i]);
  }
  // Compare current to previous
  boolean buttons_different = false;
  for (int i = 0; i < BUTTON_COUNT; i++) 
  {
    if (g_buttons[i] != buttons_readings[i])
    {
      g_buttons[i] = buttons_readings[i];
      buttons_different = true;
    }
  }
  // Check that buttons aren't all 0
  boolean buttons_all_zero = true;
  for (int i = 0; i < BUTTON_COUNT; i++) 
  {
    if (g_buttons[i] != 0)
    {
      buttons_all_zero = false;
    }
  }
  g_buttons_changed = buttons_different && !buttons_all_zero;
}


/* Sound */
int length(char *n)
{
  int i;
  for(i = 0; n[i] != '\0'; i++);
  return i;
}

void playNote(char c)
{
  tone(BUZZER, note(c), 500);
}

void playMelody(char *melody, int nduration)
{
  int l = length(melody);
  for(int n = 0; n < l; n++) {
    playNote(melody[n]);
    delay(nduration);
  }
}

void playProgression(char *prog, int nduration)
{
  int l = length(prog);
  for(int t = 0; t < l; t++)
    playMelody(triad(prog[t]), nduration);
}

int note(char c)
{
  switch(c) {
    case 'c' : return 262;
    case 'C' : return 277;
    case 'd' : return 294;
    case 'D' : return 311;
    case 'e' : return 330;
    case 'f' : return 349;
    case 'F' : return 370;
    case 'g' : return 392;
    case 'G' : return 415;
    case 'a' : return 440;
    case 'A' : return 466;
    case 'b' : return 494;
    case 'z' : return 524;
  }
}

char *triad(char c)
{
  switch(c) {
     case 'c' : return "cDg";
     case 'C' : return "ceg";
     case 'd' : return "dfa";
     case 'D' : return "dFa";
     case 'e' : return "egb";
     case 'E' : return "eGb";
     case 'f' : return "fGz";
     case 'F' : return "faz";
     case 'G' : return "dgb";
     case 'a' : return "cea";
     case 'A' : return "Cea";
     case 'b' : return "dFb";
     case 'B' : return "DFb";
     case 'z' : return "zgDc";
     case 'Z' : return "zgec";
     default  : return "ccc";
  }
}

void correct()
{
  playMelody("cegz", 20);
}

void incorrect()
{
  playMelody("cDFA", 20);
}

void win()
{
  playProgression("CFdGZ", 100);
}

void lose()
{
  playMelody("zbAaG", 300);
}

