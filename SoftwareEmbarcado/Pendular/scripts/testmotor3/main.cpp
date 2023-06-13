#include <Arduino.h>

#define SEN 22 
#define PWM 17
#define ENC 21

int64_t count_pulse = 0;
int count_isr = 0;
int pwm_per = 0;
int count_task = 0;
double u = 0;

class SecondOrderFilter{
    private:
        double y = 0; 
        double y2k  = 0;
        int64_t pasttime = esp_timer_get_time();
        double wc = 0.01;
        double swc = wc*wc;
        double raw = 0;
        double dtk = 1e-3;

    public:
    double get (double X){
        raw = X;
        double dt = (esp_timer_get_time()-pasttime)/1e6;

        double a = 1/(swc*dt*dt) + 1.414/(wc*dt) + 1;
        double b = (-1/swc)*(1/(dt*dt) + 1/(dtk*dt)) - 1.414/(wc*dt);
        double c = 1/(swc*dt*dtk);
        double temp = y;

        y = X/a - b/a*y - c/a*y2k;
        y2k = temp;
        pasttime = esp_timer_get_time();
        dtk = dt;

        return y;
    }
    double get (){
        return y;
    }
    double getRAW(){
        return raw;
    }
};

SecondOrderFilter count_per_sec1;
SecondOrderFilter count_per_sec2;

void pwmwrite(double VALUE){
    if (VALUE > 100) VALUE = 100;
    if (VALUE < -100) VALUE = -100;
    int pwm = 4095.0 - abs(VALUE)*40.95;
    digitalWrite(SEN, VALUE < 0);
    ledcWrite(0, pwm);
}

void task_change_speed(void *pv){
    delay(200);
    while(true){
        for (int i = -10; i < 11; i++){
            pwm_per = 10*i;
            pwmwrite(10*i);
            delay(5000);
        }  
        for (int i = 9; i > -10; i--){
            pwm_per = 10*i;
            pwmwrite(10*i);
            delay(5000);
        }  
    }
}

void interrupt(){
    static int64_t pasttime = esp_timer_get_time();
    
    int64_t dt = esp_timer_get_time() - pasttime;
    if (dt < 1000) return;
    pasttime = esp_timer_get_time();
    count_pulse++;
    count_isr++;
    count_task++;

    if (count_isr < 5) return;
    static int64_t pasttime_isr = esp_timer_get_time();
    count_isr = 0;
    double dtisr = (esp_timer_get_time() - pasttime_isr)/1e6;
    pasttime_isr = esp_timer_get_time();
    count_per_sec1.get(5.0/dtisr);
}

void task_update_filter(void *pv){
    delay(200);
    while (true) {
        static int64_t pasttime = esp_timer_get_time();
        double dt = double(esp_timer_get_time() - pasttime)/1e6;
        count_per_sec2.get(double(count_task)/dt);
        //count_per_sec1.get(count_task/dt);
        pasttime = esp_timer_get_time();
        count_task =0;
        delay(20);
    }
    
}

void setup(){
    Serial.begin(115200);
    pinMode(PWM, OUTPUT);
    pinMode(SEN, OUTPUT),
    pinMode(ENC, INPUT_PULLUP);

    ledcSetup(0, 5000, 12);
    ledcAttachPin(PWM, 0);
    
    pwmwrite(0);

    xTaskCreate(task_change_speed, "speed", 10000, NULL, 1, NULL);
    xTaskCreate(task_update_filter, "task", 10000, NULL, 1, NULL);
    attachInterrupt(ENC, interrupt, FALLING);
}

void loop(){
    //Serial.printf("\n%d \t %.0f \t %.3f", pwm_per, double(count_pulse), count_per_sec.get());
    Serial.printf("\n%d \t %.3f \t %.3f", pwm_per, count_per_sec1.get(), count_per_sec1.getRAW());
    delay(10);
}