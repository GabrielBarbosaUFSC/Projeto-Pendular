#ifndef LINESENSORS
#define LINESENSORS

#include "Arduino.h"
#include "Pinout.h"

class LineSensors{
    private:
        IR_Pins IR; //List of pins, the list must be passed from left to right
    public:
        /**
         @brief Constructor of the class
         @param PINS List of pins, the list must be passed from left to right 
        */
        LineSensors(IR_Pins PINS);

        /**
         @brief Initialize the pins as INPUT PULLDOWN
        */
        void begin();

        /**
         @brief Get a bit mask of the sensors values. The most significant bit is the left sensor value. Black equals HIGH.  
        */
        uint8_t get();

        /**
         @brief Get the sensor values as a byte array. The index 0 is the left sensor value. Black equals HIGH.
         @param buffer Array what will receive the sensors data, it lenght must be 8 bytes
         @param len Array lenght 
        */
        void get(uint8_t buffer[], int len);
};

#endif