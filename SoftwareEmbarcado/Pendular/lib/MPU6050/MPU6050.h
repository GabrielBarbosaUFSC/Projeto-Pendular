#ifndef MPU6050_h
#define MPU6050_h

#include <Wire.h>

struct dados {
  int16_t X;
  int16_t Y;
  int16_t Z;
};

class MPU6050 {
  private:
    const int MPU_addr = 0x68;
    dados acc;
    dados gyr;
    int16_t Tmp;

  public:
    void begin();
    void readData();
    dados getAcceleration();
    dados getGyroscope();
};

#endif
