#ifndef FIRSTORDERFILTER
#define FIRSTORDERFILTER

#include "Arduino.h"

class FirstOrderFilter {
    private:
        double y;
        const double tau;
        int64_t tpast =0 ;
    public:
        FirstOrderFilter(double TAU = 1, double Y0=0);
        double get(double X);
        double get();
};

#endif