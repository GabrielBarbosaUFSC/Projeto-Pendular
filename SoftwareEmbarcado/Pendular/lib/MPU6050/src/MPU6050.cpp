#include "MPU6050.h"

void MPU6050::begin() {
  Wire.begin();
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);
  Wire.write(0);
  Wire.endTransmission(true);
}

void MPU6050::readData() {
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_addr, 14, true);
  acc.X = Wire.read() << 8 | Wire.read();
  acc.Y = Wire.read() << 8 | Wire.read();
  acc.Z = Wire.read() << 8 | Wire.read();
  Tmp = Wire.read() << 8 | Wire.read();
  gyr.X = Wire.read() << 8 | Wire.read();
  gyr.Y = Wire.read() << 8 | Wire.read();
  gyr.Z = Wire.read() << 8 | Wire.read();
}

Dados MPU6050::getAcceleration() {
  return acc;
}

Dados MPU6050::getGyroscope() {
  return gyr;
}
