//#include <SoftwareSerial.h>


void setup()
{
  Serial.begin(9600);
}

void loop()
{
//  Serial.print("Hello World");
  Serial.write("ECG100");

  delay(1000);

  Serial.write("ECG200");

  delay(1000);
}
