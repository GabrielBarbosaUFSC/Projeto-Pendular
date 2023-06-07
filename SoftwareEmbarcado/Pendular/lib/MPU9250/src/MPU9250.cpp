#include "MPU9250.h"

void MPU6050::begin()
{
  Wire.begin();
  Wire.beginTransmission(MPU_addr); // Endereço do MPU9250
  Wire.write(0x6B);                 // Registrador PWR_MGMT_1
  Wire.write(0x80);                 // Bit de reset
  // configuração acelerometro
  Wire.write(0x1C);       // Registrador ACCEL_CONFIG
  Wire.write(conf_accel); // Configuração para ±2g = 0x00; para ±4g = 0x01; para ±8g = 0x02; para ±16g = 0x03;
  // configuração giroscopio
  Wire.write(0x1B);      // Registrador GYRO_CONFIG
  Wire.write(conf_gyro); // Configuração para ±250°/s = 0x00; para ±500/s = 0x01; para ±1000/s = 0x02; para ±2000/s = 0x03;
  // configuração magnetometro
  Wire.write(0x37); // Registrador INT_PIN_CFG
  Wire.write(0x02); // Ativar bypass do I2C
  Wire.write(0x0A); // Registrador CNTL1
  Wire.write(0x16); // Configuração para taxa de medição de 100Hz e resolução de 16 bits

  Wire.endTransmission();
}

void MPU6050::readData()
{
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_addr, 14, true);
  acc.X = Wire.read() << 8 | Wire.read();
  acc.Y = Wire.read() << 8 | Wire.read();
  gyr.X = Wire.read() << 8 | Wire.read();
  gyr.Y = Wire.read() << 8 | Wire.read();
  gyr.Z = Wire.read() << 8 | Wire.read();
  mag.X = Wire.read() << 8 | Wire.read();
  mag.Y = Wire.read() << 8 | Wire.read();
  mag.Z = Wire.read() << 8 | Wire.read();
}

Dados MPU6050::getAcceleration()
{
  return acc;
}

Dados MPU6050::getGyroscope()
{
  return gyr;
}
