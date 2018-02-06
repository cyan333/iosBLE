#include <SoftwareSerial.h>
SoftwareSerial BTserial(2, 3);

void setup()
{
  Serial.begin(9600);
  BTserial.begin(9600);
}

void loop()
{

  BTserial.print("ECG");
  delay(1000);
  BTserial.print("100");
  delay(1000);
  BTserial.print("200");
  delay(1000);
  BTserial.print("500");
  delay(1000);
  BTserial.print("300");
  delay(1000);
  BTserial.print("100");
  delay(1000);
  BTserial.print("PPGRED");
  delay(1000);
  BTserial.print("1020");
  delay(1000);
  BTserial.print("2020");
  delay(1000);
  BTserial.print("5100");
  delay(1000);
  BTserial.print("3100");
  delay(1000);
  BTserial.print("1040");
  delay(1000);
  BTserial.print("PPGIR");
  delay(1000);
  BTserial.print("2020");
  delay(1000);
  BTserial.print("1020");
  delay(1000);
  BTserial.print("900");
  delay(1000);
  BTserial.print("2100");
  delay(1000);
  BTserial.print("4040");
  delay(1000);
  BTserial.print("HRB");
  delay(1000);
  BTserial.print("100");
  delay(1000);
  BTserial.print("OXG");
  delay(1000);
  BTserial.print("13");
  delay(1000);
  BTserial.print("TEMP");
  delay(1000);
  BTserial.print("25");
  delay(1000);
}
