# include <Arduino.h>
#include <SPI.h>
#include <Wire.h>
unsigned long rpmtime;
float rpmfloat;
unsigned int rpm;
bool tooslow = 1;

void setup() {
  Serial.begin(9600);
  TCCR1A = 0;
  TCCR1B = 0;
  TCCR1B |= (1 << CS12); //Prescaler 256
  TIMSK1 |= (1 << TOIE1); //enable timer overflow
  pinMode(3, INPUT);
  attachInterrupt(0, RPM, FALLING);
}

ISR(TIMER1_OVF_vect) {
  tooslow = 1;
}

void loop() {
  delay(1000);
  if (tooslow == 1) {
    Serial.println("Too Slow");
  }
  else {
    rpmfloat = 120 / (rpmtime/ 31250.00);
    rpm = round(rpmfloat);
    Serial.println(rpm);
  }
}

void RPM () {
  rpmtime = TCNT1;
  TCNT1 = 0;
  tooslow = 0;
}
