#ifndef MOTORLIB
#define MOTORLIB

#include "Arduino.h"

/**
 @brief Define a Butterworth Second Ordem Filter with non constant sample time
*/
class SecondOrderFilter{
    private:
        double wc; //cut frequency, in rad/s
        double swc; //square cut frequecy
        double y; //output
        double yk2; //output(k-2)
        double dtk1 = 10e-3; //dt(k-1)
        int64_t pasttime; 

    public:
        /**
         @brief Second Filter Order
         @param WC cut frequency 
        */
        SecondOrderFilter(double WC);

        /**
         @brief Copies the data from other filter
         @param Filter copies that filter
        */
        void set(SecondOrderFilter &Filter);

        /**
         @brief Get output value, updates the filter
        */
        double get(double X);

        /**
         @brief Get the output value
        */
        double get();

        /**
         @brief Print filter's data
        */
        void print();

        /**
         @brief get last iteration
        */
        double get_past_time();
};


class EncoderFilter{
    private:
        SecondOrderFilter filter; //Main Filter
        SecondOrderFilter timeout_filter; //Filter to be used in timeout
        double timeout; 
        bool flag = false; //timeout flag
        int64_t pasttime = 0;
        int64_t counts = 0;
        int64_t counts_with = 0;
        double ignore_time = 500e-6; //Ignore pulses that have dt < 500us
        double rad_per_tick = 2*PI/691.0; //COnvert ticks in rad
        int wise = 1;

    public:
        /**
         @brief Encoder Filter constructor
         @param WC cut frequency
         @param TIMEOUT timeout time 
        */
        EncoderFilter(double WC = 600, double TIMEOUT = 30e-3);

        /**
         @brief Update the filter using the timeout flag
        */
        void update_timer();

        /**
         @brief Update the filter inside ISR function
        */
        void update_isr();

        /**
         @brief Get output value
        */
        double get();

        /**
         @brief Get absolute counter
        */
        int64_t get_counter();

        /**
         @brief Set Wise
         @param WISE = 1 to clockwise, -1 to counter-clock
        */
        void set_wise(int WISE);

        /**
         @brief Get ticks according wise choosen 
        */
        int64_t get_wise_counter();

        /**
         @brief Convert ticks in a angle, in rads
        */
        double get_angle();

};
class Motor{
    private:
        const int sen; //Wise PIN
        const int pwm; //PWM PIN
        const int enc; //ENC PIN
        const int invert; //INVERT wise
        const int channel; // PWM channel

    public:
        EncoderFilter filter; //Encoder filter

        /**
         @brief Motor Constructor
         @param SEN WISE PIN
         @param PWM PWM PIN
         @param ENC ENC PIN
         @param INV true to invert wise
         @param CHANNEL PWM channel 
        */
        Motor(int SEN, int PWM, int ENC, int INV, int CHANNEL);

        /**
         @brief Starts the motor
         @param ISR ISR function with encoder functions
        */
        void begin(void ISR());

        /**
         @brief routine to be called inside a ISR function
        */
        void isr();

        /**
         @brief routine to be called inside a task
        */
        void timer();

        /**
         @brief Sets a PWM duty cycle, -100% to 100%
         @param PWM -100 -> 100
        */
        void set_pwm(double PWM);

        /**
         @brief Get speed in rad/s
        */
        double get_speed();

        /**
         @brief Get speed in rpm
        */
        double get_speed_rpm();

        /**
         @brief Get absolute counter
        */
        int64_t get_counter();

        int64_t get_counter_wise();

        double get_angle();
};

#endif 