#include "FirstOrderFilter.h"

FirstOrderFilter::FirstOrderFilter(double TAU, double Y0):tau(TAU), y(Y0){};
double FirstOrderFilter::get(double X){
    double dt = (esp_timer_get_time() - tpast) / 1e6;
    tpast = esp_timer_get_time();
    y = tau / (tau + dt) * y + dt /(tau + dt) * X;
    return y;
}
double FirstOrderFilter::get(){
    return y;
}



