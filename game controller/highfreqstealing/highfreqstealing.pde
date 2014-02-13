import processing.serial.*;
import httprocessing.*;

PFont f;

String PLAYER1_COM = "COM30";
String PLAYER2_COM = "COM26";
String URL = "http://localhost:8080";
Serial player1_serial;
Serial player2_serial;

int ARRAY_SIZE = 100;
int ROUNDS = 40;
int PLAYER1 = 1;
char[] player1_input = new char[ARRAY_SIZE];
int player1_input_index = 0;
boolean player1_connected = false;
boolean player1_ready = false;

int PLAYER2= 2;
char[] player2_input = new char[ARRAY_SIZE];
int player2_input_index = 0;
boolean player2_connected = false;
boolean player2_ready = false;

char COMMAND_BUTTONS = 'A';
char COMMAND_GAME_LIGHTS = 'B';
char COMMAND_WON_OR_LOSE = 'C';
char COMMAND_END_CHAR = 'X';
char COMMAND_CONNECT = 'F';

boolean g_command_ready = false;

char[] g_field = new char[5];
char[] g_field_in = new char[5];
boolean g_round_over = true;

int player1_score = 0;
int player2_score = 0;

void setup() 
{

  player1_serial = new Serial(this, PLAYER1_COM, 9600);
  player2_serial = new Serial(this, PLAYER2_COM, 9600);
}

void draw() 
{
  //background(255); 
  wait_for_connect();
  start_game();
  game();
  end_game();
}

void wait_for_connect()
{
  println("Checking for connection...");
  player1_connected = false;
  player2_connected = false;
  while (player1_connected == false || player2_connected == false)
  {
    read_command(PLAYER1);
    read_command(PLAYER2);
  }
  println("BLACK connected");
  println("WHITE connected");
  println(" ");
}

void start_game()
{
println("  _    _ _       _                ______                                             _____ _             _ _");             
println(" | |  | (_)     | |              |  ____|                                           / ____| |           | (_)            ");
println(" | |__| |_  __ _| |__    ______  | |__ _ __ ___  __ _ _   _  ___ _ __   ___ _   _  | (___ | |_ ___  __ _| |_ _ __   __ _ ");
println(" |  __  | |/ _` | '_ \\  |______| |  __| '__/ _ \\/ _` | | | |/ _ \\ '_ \\ / __| | | |  \\___ \\| __/ _ \\/ _` | | | '_ \\ / _` |");
println(" | |  | | | (_| | | | |          | |  | | |  __/ (_| | |_| |  __/ | | | (__| |_| |  ____) | ||  __/ (_| | | | | | | (_| |");
println(" |_|  |_|_|\\__, |_| |_|          |_|  |_|  \\___|\\__, |\\__,_|\\___|_| |_|\\___|\\__, | |_____/ \\__\\___|\\__,_|_|_|_| |_|\\__, |");
println("            __/ |                                  | |                       __/ |                                  __/ |");
println("           |___/                                   |_|                      |___/                                  |___/ ");
  
  println("Start sequence and wait for ready...");
  send_start(PLAYER1);
  send_start(PLAYER2);
  player1_ready = false;
  player2_ready = false;
  while (player1_ready == false || player2_ready == false)
  {
    read_command(PLAYER1);
    read_command(PLAYER2);
  }
  println("BLACK ready");
  println("WHITE ready");
  println(" ");
  player1_score = 0;
  player2_score = 0;
}

void game ()
{
println("  ____             _       _ ");
println(" |  _ \\           (_)     | |");
println(" | |_) | ___  __ _ _ _ __ | |");
println(" |  _ < / _ \\/ _` | | '_ \\| |");
println(" | |_) |  __/ (_| | | | | |_|");
println(" |____/ \\___|\\__, |_|_| |_(_)");
println("              __/ |          ");
println("             |___/           ");
  
  int round_num = 0;
  while (round_num < ROUNDS)
  {
    if (g_round_over == true)
    {
      update_field();
      send_field(PLAYER1);
      send_field(PLAYER2);
      g_round_over = false;
      round_num++;
    }
    read_command(PLAYER1);
    read_command(PLAYER2);
  }
}

void print_winner()
{
  println(" __          _______ _   _ _   _ ______ _____");  
  println(" \\ \\        / /_   _| \\ | | \\ | |  ____|  __ \\"); 
  println("  \\ \\  /\\  / /  | | |  \\| |  \\| | |__  | |__) |");
  println("   \\ \\/  \\/ /   | | | . ` | . ` |  __| |  _  /");
  println("    \\  /\\  /   _| |_| |\\  | |\\  | |____| | \\ \\");
  println("     \\/  \\/   |_____|_| \\_|_| \\_|______|_|  \\_\\");                                   
}

void print_black()
{
println("  ____  _               _____ _  __");
println(" |  _ \\| |        /\\   / ____| |/ /");
println(" | |_) | |       /  \\ | |    | ' /"); 
println(" |  _ <| |      / /\\ \\| |    |  <");  
println(" | |_) | |____ / ____ \\ |____| . \\"); 
println(" |____/|______/_/    \\_\\_____|_|\\_\\");
                                   
                                     
}

void print_white()
{
println(" __          ___    _ _____ _______ ______");
println(" \\ \\        / / |  | |_   _|__   __|  ____|");
println("  \\ \\  /\\  / /| |__| | | |    | |  | |__");   
println("   \\ \\/  \\/ / |  __  | | |    | |  |  __|");  
println("    \\  /\\  /  | |  | |_| |_   | |  | |____"); 
println("     \\/  \\/   |_|  |_|_____|  |_|  |______|");                                            
}

void print_dollar_sign()
{
println("        $");
println("     ,$$$$$,");
println("   ,$$$'$`$$$");
println("   $$$  $   `");
println("   '$$$,$");
println("     '$$$$,");
println("       '$$$$,");
println("        $ $$$,");
println("    ,   $  $$$");
println("    $$$,$.$$$'");
println("     '$$$$$'");
println("        $");
}


void end_game()
{
  if (player1_score > player2_score)
  {
    send_end_game(PLAYER1, true);
    send_end_game(PLAYER2, false);
    httpRequest(PLAYER1, player1_score - player2_score);
/*
    print("WINNER: ");
    print("BLACK by ");
    */
    print_winner();
    print_black();
    print_dollar_sign();
    print("By ");    
    print(player1_score - player2_score);
    println(" points!");    
    println("CHA-CHING!");
    println(" ");
  }
  else if (player1_score < player2_score)
  {
    send_end_game(PLAYER1, false);
    send_end_game(PLAYER2, true);    
    httpRequest(PLAYER2, player2_score - player1_score);    
    print_winner();
    print_white();
    print_dollar_sign();
/*
    print("WINNER: ");
    print("WHITE by ");
*/
    print("By ");
    print(player2_score - player1_score);
    println(" points!");        
    println("CHA-CHING!");
    println(" ");    
  }
  else
  {
    send_end_game(PLAYER1, true);
    send_end_game(PLAYER2, true);    
    println("TIE GAME!");
//    httpRequest(player2_score, player2_score - player1_score);  
  }
  player1_score = 0;
  player2_score = 0;  
  delay(10000);
}

void send_end_game(int player, boolean winner)
{
  Serial player_serial = player1_serial;
  if (player == PLAYER1)
  {
    player_serial = player1_serial;
  }
  else if(player == PLAYER2)
  {
    player_serial = player2_serial;    
  }
  player_serial.write("G");
  if (winner == true)
  {
    player_serial.write("1");
  }
  else if (winner == false)
  {
    player_serial.write("0");
  }
  player_serial.write("X");
}

void update_field()
{
  clear_field();
  int index = int(random(5));
  //print(index);
  g_field[index] = '1';
  return;
}

void clear_field()
{
  for(int i = 0; i < 5; i++)
  {
    g_field[i] = '0';
  }
}

boolean compare_buttons_to_field (char[] field_in)
{
  boolean match = true;
  for (int i = 0; i < 5; i++)
  {
    if (field_in[i] != g_field[i]) {
      match = false;
    }
  }
  return match;
}

void read_command(int player)
{
  Serial player_serial = player1_serial;
  if (player == PLAYER1)
  {
    player_serial = player1_serial;
  }
  if (player == PLAYER2)
  {
    player_serial = player2_serial;
  }
  while (player_serial.available() > 0) 
  {
    char r = char(player_serial.read());
    if (player == PLAYER1)
    {
      player1_input[player1_input_index] = r;
      player1_input_index++;
    }
    if (player == PLAYER2)
    {
      player2_input[player2_input_index] = r;
      player2_input_index++;
    }
    if (r == COMMAND_END_CHAR)
    {
      char[] command = player1_input;
      if (player == PLAYER1)
      {
        command = player1_input;
      }
      if (player == PLAYER2)
      {
        command = player2_input;
      }
      process_command(player, command);
      if (player == PLAYER1)
      {
        player1_input_index = 0;
      }
      if (player == PLAYER2)
      {
        player2_input_index = 0;
      }
      break;
    }
  }  
}

void process_command(int player, char[] command)
{ 
  if (command[0] == COMMAND_BUTTONS)
  {
    if (g_round_over == false)   
    {
      char[] field_in = new char[5];
      for (int i = 0; i < 5; i++)
      {
        field_in[i] = command[1+i];
      }
      boolean win = compare_buttons_to_field(field_in);    
      if (player == PLAYER1)
      {
        send_win(PLAYER1, win);
        send_win(PLAYER2, !win);
        if (win == true)
        {
          player1_score = player1_score + 1;
        }
        else
        {
          player2_score = player2_score + 1;
        }
      }
      else if (player == PLAYER2)
      {
        send_win(PLAYER2, win);
        send_win(PLAYER1, !win);
        if (win == true)
        {
          player2_score = player2_score + 1;
        }
        else
        {
          player1_score = player1_score + 1;
        }
      }
      /*
      background(255);
      textFont(f,16);                 // STEP 4 Specify font to be used
      fill(0);                        // STEP 5 Specify font color 
      text(Integer.toString(player1_score),10,20);
      text(Integer.toString(player1_score),10,50);
      */
      print("BLACK: ");
      println(player1_score);
      print("WHITE: ");
      println(player2_score);
      println(" ");
      g_round_over = true;
      // SEND WINNER TO VENMO HERE
    }
  }
  else if (command[0] == COMMAND_CONNECT)
  {
    if (player == PLAYER1)
    {
      player1_connected = true;
      send_connect(PLAYER1);
    }
    if (player == PLAYER2)
    {
      player2_connected = true;
      send_connect(PLAYER2);
    }
  }
  else if (command[0] == 'E')
  {
    if (player == PLAYER1)
    {
      player1_ready = true;
    }
    if (player == PLAYER2)
    {
      player2_ready = true;
    }    
  }
  
//  g_command_ready = false;
//  player1_input_index = 0;
}

void send_win (int player, boolean win)
{
  Serial player_serial = player1_serial;
  if (player == PLAYER1)
  {
    player_serial = player1_serial;
  }
  else if(player == PLAYER2)
  {
    player_serial = player2_serial;    
  }
  
  player_serial.write("C");
  if (win == true)
  {
    player_serial.write("1");
  }
  else if (win == false)
  {
    player_serial.write("0");
  }
  else
  {
    player_serial.write("2");
  }
  player_serial.write("X");
} 

void send_connect (int player)
{
  Serial player_serial = player1_serial;
  if (player == PLAYER1)
  {
    player_serial = player1_serial;
  }
  else if(player == PLAYER2)
  {
    player_serial = player2_serial;    
  }
  player_serial.write('F');
  player_serial.write('X');
}

void send_start (int player)
{
  Serial player_serial = player1_serial;
  if (player == PLAYER1)
  {
    player_serial = player1_serial;
  }
  else if(player == PLAYER2)
  {
    player_serial = player2_serial;    
  }
  player_serial.write('D');
  player_serial.write('X');
}

void send_field (int player)
{
  Serial player_serial = player1_serial;
  if (player == PLAYER1)
  {
    player_serial = player1_serial;
  }
  else if(player == PLAYER2)
  {
    player_serial = player2_serial;    
  }
  player_serial.write("B");
  for (int i = 0; i < 5; i++)
  {
    player_serial.write(g_field[i]);
  }
  player_serial.write("X");
}

void httpRequest(int winner, int amount)
{
  //println("start");
  String request = URL + "/payment?winner=" + Integer.toString(winner) + "&amount=" + Integer.toString(amount);   
  GetRequest get = new GetRequest(request);
  //get.addData("winner",Integer.toString(winner));
  get.send();
  //println("end");
}
