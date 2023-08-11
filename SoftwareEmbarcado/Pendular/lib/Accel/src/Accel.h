#ifndef _accel_my
#define _accel_my

#include "Arduino.h"
#include "Kalman.h"
#include "MPU9250_asukiaaa.h"

class Accel{
    private:
        MPU9250_asukiaaa accelunit;
        int64_t pasttime = esp_timer_get_time();
        Kalman filter;
        double theta;
        double raw_theta;
        double raw_gyro;
    public:
        /**
         @brief Class Constructor
         @param I2cAddress I2C address 
        */
        Accel(int I2cAddress);

        /**
         @brief Starts the accel 
        */
        void begin();

        /**
         @brief Update the Kalman Filter
         @param bias add bias offset, in rad 
        */
        double update(double bias);

        /**
         @brief Get raw theta angle by accel values
        */
        double get_rawtheta();

        /**
         @brief Get raw theta, in rad
        */
        double raw();

        /**
         @brief Get raw gyro, in degree per second
        */
        double get_raw_gyro();

        /**
         @brief Get filtered theta
        */
        double filtered();
};

#endif