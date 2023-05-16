#ifndef VOLTIMETER
#define VOLTIMETER

#include "Arduino.h"
#include "FirstOrderFilter.h"

class Voltimeter {
    private:

        const double G; //Voltimeter Gain
        const int pin; //Voltimeter Pin
        FirstOrderFilter filter; //Filter related with analog read

        double media(); //Get the average of 20 measurements

        static void update(void *pV); //Task to be created, runs "media" every 100ms

    public:
        /**
         @brief Constructor Method
         @param G_ Voltimeter Gain
         @param PIN Voltimeter Pin
         @param TAU Time Constant of Voltimeter Filter, in seconds
        */
        Voltimeter(double G_, double PIN, double TAU = 5);

        /**
         @brief Start the pin and create a task to measure the voltage level
        */
        void begin();

        /**
         @brief Get voltage level, in Volts 
        */
        double get();
};

#endif