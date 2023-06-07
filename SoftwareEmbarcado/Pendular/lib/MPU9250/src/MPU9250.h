#ifndef MPU6050_h
#define MPU6050_h

#include <Wire.h>

struct Dados
{
  int16_t X;
  int16_t Y;
  int16_t Z;
};

class MPU6050
{
private:
  const int MPU_addr = 0x68; // I2C address
  const int conf_accel = 0;  // Configuração para ±2g = 0; para ±4g = 1; para ±8g = 2; para ±16g = 3;
  const int conf_gyro = 0;   // Configuração para ±250°/s = 0; para ±500/s = 1; para ±1000/s = 2; para ±2000/s = 3;
  Dados acc;                 // accel read
  Dados gyr;                 // gyr read
  int16_t Tmp;               // temp read

public:
  /**
   @brief Set and config the I2C communucation and MPU6050
  */
  void begin();

  /**
   @brief Get gyr and accel data from MPU6050
  */
  void readData();

  /**
   @brief Get accel data
  */
  Dados getAcceleration();

  /**
   @brief get gyro data
  */
  Dados getGyroscope();
};

#endif
