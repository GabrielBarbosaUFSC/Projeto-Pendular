#include <Arduino.h>

#define PWMPIN 27
#define SENPIN 26
#define ENCPIN 25

//fc = 1000hz
class SecondOrderFilter{
    private:
        double y = 0; 
        double y2k  = 0;
        int64_t pasttime = esp_timer_get_time();
    public:
    double get (double X){
        double dt = (esp_timer_get_time()-pasttime)/1e6;
        double a = 1/(dt*dt*1e6) + 2/(dt*1e3) + 1;
        double b = 2/(dt*dt*1e6) + 2/(dt*1e3);
        double c = 1/(dt*dt*1e6);
        double temp = y;
        y = b/a*y + c/a*y2k + X/a; 
        y2k = temp;
        pasttime = esp_timer_get_time();
        return y;
    }
    double get (){
        return y;
    }
};

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