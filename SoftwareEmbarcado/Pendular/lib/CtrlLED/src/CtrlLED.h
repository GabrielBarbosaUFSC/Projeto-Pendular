#ifndef CTRLLED
#define CTRLLED

#include "Arduino.h"

class CtrlLED{
    private:
        const int pin_R; 
        const int pin_G; 
        bool stateR; 
        bool stateG;

        String color = ""; //Color sequence to change
        int seq_len = 0; //Lenght color sequence
        int seq_index = 0; //color sequence index
        int seq_timer = 0; //time control color sequence
        int64_t pasttime = esp_timer_get_time(); //time control color sequence

        bool charging = false; //Charging flag
        
        static void update(void *pV); //LED Task

        /**
         @brief Set color in the LED
         @param COLOR 'R' to RED, 'G' to GREEN, 'F' to off  
        */
        void set(char COLOR); //Set Color

        /**
         @brief Check if it is charging 
        */
        void check_charging();

    public:
        /**
         @brief CtrlLED Constructor
         @param PIN_R PIN LED R
         @param PIN_G PIN LED G
        */
        CtrlLED(int PIN_R, int PIN_G);

        /**
         @brief starts the object and creates its task
        */
        void begin();

        /**
         @brief Defines a color sequence that the ROBOT will follow
         @param COLOR Sequence color, eg COLOR = "RFG" -> RED - OFF - GREEN
         @param TIME Time to change
        */
        void setcolor(String COLOR, int TIME);

        /**
         @brief Get the charging flag
        */
        bool get_charging();
      
};

#endif