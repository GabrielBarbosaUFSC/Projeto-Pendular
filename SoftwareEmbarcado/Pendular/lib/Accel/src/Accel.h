#ifndef _accel_my
#define _accel_my

#include "Arduino.h"
#include "Kalman.h"
#include "MPU9250_asukiaaa.h"

struct ThetaInfo{
    double theta;
    int64_t time;
};

#define BUFFER_SIZE 25

class Accel{
    private:
        MPU9250_asukiaaa accelunit;
        int64_t pasttime = esp_timer_get_time();
        Kalman filter;
        double theta;
        double raw_theta;
        double raw_gyro;

        double past_rate;
        
        ThetaInfo theta_ = {0, esp_timer_get_time()};

        ThetaInfo buffer[BUFFER_SIZE];
        int index_ = 0;

        void add_to_buffer(ThetaInfo add);

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
        double filtered(bool raw = false);

        ThetaInfo get_thetainfo();

        ThetaInfo get_theta_delay(int64_t time);

};

#endif