// #include "Arduino.h"
// #include "Wire.h"

// void setup() {
//   Serial.begin(115200);
//   Wire.begin();
// }

// void loop() {
//   byte error, address;
//   int nDevices = 0;

//   delay(5000);

//   Serial.println("Scanning for I2C devices ...");
//   for(address = 0x01; address < 0x7f; address++){
//     Wire.beginTransmission(address);
//     error = Wire.endTransmission();
//     if (error == 0){
//       Serial.printf("I2C device found at address 0x%02X\n", address);
//       nDevices++;
//     } else if(error != 2){
//       Serial.printf("Error %d at address 0x%02X\n", error, address);
//     }
//   }
//   if (nDevices == 0){
//     Serial.println("No I2C devices found");
//   }
// }

#include "Arduino.h"
#include "Wire.h"
#include "MPU9250.h"

MPU9250 IMU(Wire, 0x69);
int status;

void setup() {
  // serial to display data
  Serial.begin(115200);
  while(!Serial) {}

  // start communication with IMU 
  status = IMU.begin();
  if (status < 0) {
    Serial.println("IMU initialization unsuccessful");
    Serial.println("Check IMU wiring or try cycling power");
    Serial.print("Status: ");
    Serial.println(status);
    while(1) {}
  }
}

void loop(){}
// void loop() {
//   // read the sensor
//   IMU.readSensor();
//   // display the data
//   Serial.print(IMU.getAccelX_mss(),6);
//   Serial.print("\t");
//   Serial.print(IMU.getAccelY_mss(),6);
//   Serial.print("\t");
//   Serial.print(IMU.getAccelZ_mss(),6);
//   Serial.print("\t");
//   Serial.print(IMU.getGyroX_rads(),6);
//   Serial.print("\t");
//   Serial.print(IMU.getGyroY_rads(),6);
//   Serial.print("\t");
//   Serial.print(IMU.getGyroZ_rads(),6);
//   Serial.print("\t");
//   Serial.print(IMU.getMagX_uT(),6);
//   Serial.print("\t");
//   Serial.print(IMU.getMagY_uT(),6);
//   Serial.print("\t");
//   Serial.print(IMU.getMagZ_uT(),6);
//   Serial.print("\t");
//   Serial.println(IMU.getTemperature_C(),6);
//   delay(100);
// }