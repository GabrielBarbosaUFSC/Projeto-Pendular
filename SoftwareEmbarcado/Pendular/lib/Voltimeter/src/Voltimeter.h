#ifndef VOLTIMETER
#define VOLTIMETER

#include "Arduino.h"

class Voltimeter {
    private:

        const double G; //Voltimeter Gain
        const int pin; //Voltimeter Pin

        double ajust[5] = {
                        -1.1458622215428729e-14,
                        +7.402422341572887e-11,
                        -1.6375806348536795e-7,
                        +0.0009507345681822474,
                        +0.11440086869494298    
                        };

        double apply_ajust(double RAW);
        double media(); //Get the average of 20 measurements
        double voltage = 0; 
        static void update(void *pV); //Task to be created, runs "media" every 100ms

    public:
        /**
         @brief Constructor Method
         @param G_ Voltimeter Gain
         @param PIN Voltimeter Pin
         @param TAU Time Constant of Voltimeter Filter, in seconds
        */
        Voltimeter(double G_, double PIN);

        /**
         @brief Start the pin and create a task to measure the voltage level
         @param create_task If not, the task won't be created
        */
        void begin(bool create_task = true);

        /**
         @brief Get voltage level, in Volts 
        */
        double get();

        /**
         @brief Update function called inside task
        */
        void update();
};


class Voltimeters {
    private:
        Voltimeter bat; //Batery Voltmeter
        Voltimeter swt; //Switch Voltmeter

        static void update(void *pV);//One task to both voltimeters
    public:
        /**
         @brief Constructor of Voltmeters 
         @param G Gain of the VOltmeter
         @param PIN_bat Battery pin 
         @param PIN_swt Switch pin
        */
        Voltimeters(double G, int PIN_bat, int PIN_swt);

        /**
         @brief Starts both voltmeters and create tasks
        */
        void begin();

        /**
         @brief get battery voltimeter measure
        */
        double get_bat();

        /**
         @brief get switch voltimeter measure
        */
        double get_swt();
        
};

#endif