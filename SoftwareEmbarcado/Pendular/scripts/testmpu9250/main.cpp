#include "Arduino.h"
#include "MPU9250_asukiaaa.h"
 
#ifdef _ESP32_HAL_I2C_H_
#define SDA_PIN 21
#define SCL_PIN 22
#endif
 
MPU9250_asukiaaa mySensor;
 
void setup() { 
Serial.begin(115200);
Serial.println("started");
 
#ifdef _ESP32_HAL_I2C_H_
// for esp32
Wire.begin(SDA_PIN, SCL_PIN); //sda, scl
#else
Wire.begin();
#endif
 
mySensor.setWire(&Wire);
 
mySensor.beginAccel();
mySensor.beginMag();
 
// you can set your own offset for mag values
// mySensor.magXOffset = -50;
// mySensor.magYOffset = -55;
// mySensor.magZOffset = -10;
}
 
void loop() {
mySensor.accelUpdate();

double ax = mySensor.accelX();
double ay = mySensor.accelY();
double az = mySensor.accelZ();
Serial.printf("ax:%f,ay:%f,az:%f\n", ax, ay, az);
delay(10);

// Serial.println("print accel values");
// Serial.println("accelX: " + String(mySensor.accelX()));
// Serial.println("accelY: " + String(mySensor.accelY()));
// Serial.println("accelZ: " + String(mySensor.accelZ()));
// Serial.println("accelSqrt: " + String(mySensor.accelSqrt()));
 
// mySensor.magUpdate();
// Serial.println("print mag values");
// Serial.println("magX: " + String(mySensor.magX()));
// Serial.println("maxY: " + String(mySensor.magY()));
// Serial.println("magZ: " + String(mySensor.magZ()));
// Serial.println("horizontal direction: " + String(mySensor.magHorizDirection()));
 
// Serial.println("at " + String(millis()) + "ms");
// delay(500);
}