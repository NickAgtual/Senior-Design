#define enable  10
#define in1  4
#define in2  5


void setup() {
  pinMode(enable, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);

  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);

  Serial.begin(9600);

}

void loop() {
  analogWrite(enable, 255);
  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);
  delay(10);
}
