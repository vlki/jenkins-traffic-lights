/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */
 
int green = 8;
int yellow = 9;
int red = 10;

int data;

void setup() {            
  Serial.begin(9600);
  
  pinMode(green, OUTPUT);
  pinMode(yellow, OUTPUT);
  pinMode(red, OUTPUT);
  
  swing();
  delay(1000);
}  

void loop() {
  if (Serial.available()) {
    data = Serial.read();
    
    if (data & 0x1) {
      turn_on(green);
    } else {
      turn_off(green);
    }
    
    if ((data >> 1) & 0x1) {
      turn_on(yellow);
    } else {
      turn_off(yellow);
    }
    
    if ((data >> 2) & 0x1) {
      turn_on(red);
    } else {
      turn_off(red);
    }
  }
}

void turn_on(int color) {
  digitalWrite(color, LOW);
}

void turn_off(int color) {
  digitalWrite(color, HIGH);
}

void swing() {
  turn_off(green);
  turn_off(yellow);
  turn_off(red);
  
  turn_on(green);
  
  delay(500);
  
  turn_on(yellow);
  turn_off(green);
  
  delay(500);
  
  turn_on(red);
  turn_off(yellow);
  
  delay(500);
  
  turn_off(red);
}
