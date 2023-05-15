#ifndef VOLTIMETER
#define VOLTIMETER

#include "Arduino.h"
#include "FirstOrderFilter.h"

class Voltimeter {
    private:
        const double G;
        const int pin;
        FirstOrderFilter filter;
    public:
        Voltimeter(double G_, double PIN);
        void begin();
        double media();
        static void update(void *pV);
        double get();
};

#endif