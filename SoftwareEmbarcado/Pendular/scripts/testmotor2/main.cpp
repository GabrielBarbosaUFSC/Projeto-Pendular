#include <Arduino.h>

#define PWMPIN 27
#define SENPIN 26
#define ENCPIN 25

//fc = 1000hz


SecondOrderFilter counts_per_second;
int64_t counts = 0;

void interrupt(){
    static int64_t pasttime = esp_timer_get_time();
    static int64_t pastcounter = counts;
    counts ++;

    if (abs(pastcounter) < (abs(counts) + 10)) return;
    double dt = (esp_timer_get_time() - pasttime);
    counts_per_second.get(double(counts-pastcounter)/dt);
    pasttime = esp_timer_get_time();
    pastcounter = counts;
}


void setup(){

}
void loop(){

}