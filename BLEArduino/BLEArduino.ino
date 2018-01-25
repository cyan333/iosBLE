//#include <SoftwareSerial.h>


void setup()
{
  Serial.begin(9600);
}

void loop()
{

  Serial.write("ECG");
  delay(1000);
  Serial.write("100");
  delay(1000);
  Serial.write("200");
  delay(1000);
  Serial.write("500");
  delay(1000);
  Serial.write("300");
  delay(1000);
  Serial.write("100");
  delay(1000);
  Serial.write("PPG");
  delay(1000);
  Serial.write("1000");
  delay(1000);
  Serial.write("1500");
  delay(1000);
  Serial.write("4000");
  delay(1000);
}
