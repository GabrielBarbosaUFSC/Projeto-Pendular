#include "Arduino.h"

class SecondOrdemFilter{
    private:
        double wc;
        double swc;
        double y;
        double yk2;
        double dtk1 = 10e-3; 
        int64_t pasttime;

    public:
        SecondOrdemFilter(double WC):wc(WC), swc(WC*WC){
            pasttime = esp_timer_get_time();
        }

        void set(SecondOrdemFilter &Filter){
            wc = Filter.wc;
            swc = Filter.swc;
            y = Filter.y;
            yk2 = Filter.yk2;
            dtk1 = Filter.dtk1;
            pasttime = Filter.pasttime;
        }
        double get(double X){
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
        double get(){
            return y;
        }
        void print(){
            Serial.printf("\n%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%d\t", wc, swc, y, yk2, dtk1, pasttime);
        }
        double get_past_time(){
            return pasttime;
        }
};
class EncoderFilter{
    private:
        SecondOrdemFilter filter;
        SecondOrdemFilter timeout_filter;
        double timeout;
        bool flag = false;
        int64_t pasttime = 0;
        int64_t counts = 0;
        double ignore_time = 500e-6;
        double rad_per_tick = 2*PI/691.0;

    public:
        EncoderFilter(double WC = 60, double TIMEOUT = 30e-3): filter(WC), timeout_filter(WC), timeout(TIMEOUT){}
        void update_timer(){
            if ((esp_timer_get_time() - pasttime)/1e6 < timeout) 
                return;
            if (!flag)
                timeout_filter.set(filter);
            flag = true;
            timeout_filter.get(0);
            pasttime = esp_timer_get_time();
        }
        void update_isr(){
            if (((esp_timer_get_time() - pasttime)/1e6) < ignore_time) 
                return;
            pasttime = esp_timer_get_time();
            flag = false;
            double dt = (pasttime - filter.get_past_time())/1e6;
            double speed = rad_per_tick/dt;
            filter.get(speed);
            counts++;
        }
        double get(){
            if (flag)
                return timeout_filter.get();
            return filter.get();
        }
        int64_t get_counter(){
            return counts;
        }

};
class Motor{
    private:
        const int sen;
        const int pwm;
        const int enc;
        const int invert;
        const int channel;

    public:
        EncoderFilter filter;

        Motor(int SEN, int PWM, int ENC, int INV, int CHANNEL): 
            sen(SEN), pwm(PWM), enc(ENC), invert(INV), channel(CHANNEL){}
        void begin(void ISR()){
            pinMode(sen, OUTPUT);
            pinMode(pwm, OUTPUT);
            pinMode(enc, INPUT_PULLUP);
            
            ledcSetup(channel, 20000, 11);
            ledcAttachPin(pwm, channel);
            ledcWrite(channel, 2047);

            attachInterrupt(enc, ISR, FALLING);

        }

        void isr(){
            filter.update_isr();
        }
        void timer(){
            filter.update_timer();
        }

        void set_pwm(double PWM){
            int value = abs(PWM)*20.47;
            if (value > 2047) value = 2047;
            if (value < 0) value = 0;

            bool sent = PWM>0?false:true;
            if (invert) sent = !sent;
            digitalWrite(sen, sent);
            Serial.println(2047-value);
            ledcWrite(channel, 2047 - value);
        }
        double get_speed(){
            return filter.get();
        }
        double get_speed_rpm(){
            return 30.0/PI*get_speed();
        }
        int64_t get_counter(){
            return filter.get_counter();
        }
};

int SENTIDO = 27;
int PWM = 26;
int ENCODER = 25; 
Motor motor(SENTIDO, PWM, ENCODER, 0, 0);

int index___ = 0;
uint64_t pasttime = esp_timer_get_time();
uint64_t dtimes[10000];
bool record = false;

double value_pwm;

void motor_isr(){
    motor.isr();
    if (!record) return;
    uint64_t tosave = esp_timer_get_time() - pasttime;
    if (tosave > 65535) tosave = 65535;
    dtimes[index___] = tosave;
    index___++;
    pasttime = esp_timer_get_time();
}

void loop1(void *pv){
    delay(200);
    int64_t pasttime = esp_timer_get_time();
    int64_t pastticks = motor.get_counter();
    while (true){
        delay(1000);
        double ticks = motor.get_counter() - pastticks;
        if (ticks < 700) 
            continue;
        double dt = (esp_timer_get_time() - pasttime)/1e6;
        pasttime = esp_timer_get_time();
        pastticks = motor.get_counter();
        double speed = ticks/(691.0*dt)*60;
        Serial.printf("\n%f\t%f", speed, value_pwm);
        
    }
}

void loop3(void *pv){
    delay(200);
    while (true){
        motor.filter.update_timer();
        delay(10);
    }
    
}

void loop4(void *pv){
    delay(200);
    while (true){
        Serial.print("\nOn");
        motor.set_pwm(100);
        delay(1000);
        Serial.print("\nOff");
        motor.set_pwm(0);
        delay(3000);
    }
}

void printdtimes(){
    Serial.printf("\n\n\ntick,time[us]");
    for (int i = 0; i < (index___-1); i++)
        Serial.printf("\n%d,%.0f", i, double(dtimes[i]));
        delay(10);
}


void setup(){
    Serial.begin(115200);
    motor.begin(motor_isr);
    motor.set_pwm(100);
    Serial.println("TEST Motor");
    delay(2000);
    record = true;
    delay(100);
    motor.set_pwm(10);
    delay(3000);
    record = false;
    printdtimes();
    delay(1000000);

    //pinMode(36, INPUT);
    //xTaskCreatePinnedToCore(loop1, "loop1", 10000, NULL, 1, NULL, 0);
    //xTaskCreatePinnedToCore(loop3, "loop3", 10000, NULL, 2, NULL, 1);
    //xTaskCreatePinnedToCore(loop4, "loop4", 10000, NULL, 2, NULL, 0);
}


void loop(){
    double read = analogRead(36);
    read = int(read/4095*20);
    read = (read - 10)*10;
    if (read != value_pwm) 
        Serial.printf("\n- %.0f -", read);
    value_pwm = read;
    //motor.set_pwm(read);
    delay(25);
    
    // motor.set_pwm(100);
    // delay(1000);
    // motor.set_pwm(0);
    // delay(2000);

    // motor.set_pwm(-100);
    // delay(5000);
    // motor.set_pwm(0);
    // delay(5000);
}