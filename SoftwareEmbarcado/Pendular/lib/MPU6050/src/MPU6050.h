#ifndef MPU6050_h
#define MPU6050_h

#include <Wire.h>

struct Dados {
  int16_t X;
  int16_t Y;
  int16_t Z;
};

class MPU6050 {
  private:
    const int MPU_addr = 0x68; //I2C address
    Dados acc; //accel read
    Dados gyr; //gyr read
    int16_t Tmp; //temp read

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
