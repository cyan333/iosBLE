//#include <SoftwareSerial.h>
//
//const byte rxPin = 2;
//const byte txPin = 3;
//
//
//SoftwareSerial mySerial(rxPin, txPin);

void setup()
{
  Serial.begin(9600);
}

void loop()
{
//  Serial.print("Hello World");
  Serial.write(1);

  delay(1000);

  Serial.write(0);

  delay(1000);
}
