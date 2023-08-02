#include "Motor.h"


SecondOrderFilter::SecondOrderFilter(double WC):wc(WC), swc(WC*WC){
    pasttime = esp_timer_get_time();
}

void SecondOrderFilter::set(SecondOrderFilter &Filter){
    wc = Filter.wc;
    swc = Filter.swc;
    y = Filter.y;
    yk2 = Filter.yk2;
    dtk1 = Filter.dtk1;
    pasttime = Filter.pasttime;
}
double SecondOrderFilter::get(double X){
    double dt = (esp_timer_get_time()-pasttime)/1e6;
    pasttime = esp_timer_get_time();
    double a = 1/(swc*dt*dt) + 1.414/(wc*dt)+1;
    double b = (-1/swc)*(1/(dt*dt) + 1/(dtk1*dt)) - 1.414/(wc*dt);
    double c = 1/(swc*dt*dtk1);

    double tempy = y; 
    y = X/a - b/a*y - c/a*yk2;

    yk2 = tempy;
    dtk1 = dt;

    return y;
}
double SecondOrderFilter::get(){
    return y;
}
void SecondOrderFilter::print(){
    Serial.printf("\n%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%d\t", wc, swc, y, yk2, dtk1, pasttime);
}
double SecondOrderFilter::get_past_time(){
    return pasttime;
}

EncoderFilter::EncoderFilter(double WC, double TIMEOUT): filter(WC), timeout_filter(WC), timeout(TIMEOUT){}
void EncoderFilter::update_timer(){
    if ((esp_timer_get_time() - pasttime)/1e6 < timeout) 
        return;
    if (!flag)
        timeout_filter.set(filter);
    flag = true;
    timeout_filter.get(0);
    pasttime = esp_timer_get_time();
}
void EncoderFilter::update_isr(){
    if (((esp_timer_get_time() - pasttime)/1e6) < ignore_time) 
        return;
    pasttime = esp_timer_get_time();
    flag = false;
    double dt = (pasttime - filter.get_past_time())/1e6;
    double speed = rad_per_tick/dt;
    filter.get(speed);
    counts++;
    counts_with += wise;
}
double EncoderFilter::get(){
    if (flag)
        return timeout_filter.get();
    return filter.get();
}
int64_t EncoderFilter::get_counter(){
    return counts;
}
void EncoderFilter::set_wise(int WISE){
    wise = WISE;
}

int64_t EncoderFilter::get_wise_counter(){
    return counts_with;
}

double EncoderFilter::get_angle(){
    return counts_with*rad_per_tick;
}

Motor::Motor(int SEN, int PWM, int ENC, int INV, int CHANNEL): 
    sen(SEN), pwm(PWM), enc(ENC), invert(INV), channel(CHANNEL){}
void Motor::begin(void ISR()){
    pinMode(sen, OUTPUT);
    pinMode(pwm, OUTPUT);
    pinMode(enc, INPUT_PULLUP);
    
    ledcSetup(channel, 20000, 11);
    ledcAttachPin(pwm, channel);
    ledcWrite(channel, 2047);

    attachInterrupt(enc, ISR, FALLING);

}

void Motor::isr(){
    filter.update_isr();
}
void Motor::timer(){
    filter.update_timer();
}

void Motor::set_pwm(double PWM){
    if (PWM != 0)
        filter.set_wise(-1+2*(PWM>0));

    int value = abs(PWM)*20.47;
    if (value > 2047) value = 2047;
    if (value < 0) value = 0;

    bool sent = PWM>0?false:true;
    if (invert) sent = !sent;

    
    digitalWrite(sen, sent);
    //Serial.println(2047-value);
    ledcWrite(channel, 2047 - value);
}
double Motor::get_speed(){
    return filter.get();
}
double Motor::get_speed_rpm(){
    return 30.0/PI*get_speed();
}
int64_t Motor::get_counter(){
    return filter.get_counter();
}

int64_t Motor::get_counter_wise(){
    return filter.get_wise_counter();
}

double Motor::get_angle(){
    return filter.get_angle();
}