int ldr1;
int ldr2;
int ldr3;
int ldr4;
 
void setup() {
  
  Serial.begin(9600); 
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(13, OUTPUT);
  
}

void loop() {
  // put your main code here, to run repeatedly:
  ldr1 = analogRead(A0); // 0 - 1023

  if(ldr1 > 600)
  {
    digitalWrite(10, HIGH);
  }
  else
  {
    digitalWrite(10, LOW);
  }
   ldr2 = analogRead(A1); // 0 - 1023

  if(ldr2 > 600)
  {
    digitalWrite(11, HIGH);
  }
  else
  {
    digitalWrite(11, LOW);
  }
   ldr3 = analogRead(A2); // 0 - 1023

  if(ldr3 > 600)
  {
    digitalWrite(12, HIGH);
  }
  else
  {
    digitalWrite(12, LOW);
  }
   ldr4 = analogRead(A3); // 0 - 1023

  if(ldr4 > 600)
  {
    digitalWrite(13, HIGH);
  }
  else
  {
    digitalWrite(13, LOW);
  }

}
