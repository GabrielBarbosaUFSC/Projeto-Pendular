#ifndef FIRSTORDERFILTER
#define FIRSTORDERFILTER

#include "Arduino.h"

class FirstOrderFilter {
    private:
        double y; //Output Variable
        const double tau; //Filter Time Constant
        int64_t tpast =0 ; //Past time, used to compute delta time
    public:
        /**
         @brief Constructor Method
         @param TAU Filter Time Constant
         @param Y0 Initial Value of Output Variable 
        */
        FirstOrderFilter(double TAU=1, double Y0=0);

        /**
         @brief Get output variable
         @param X Filter Input 
        */
        double get(double X);

        /**
         @brief Get output variable, it does not update variable value
        */
        double get();

        /**
         @brief Set output variable
        */
        void set(double Y);
};

#endif