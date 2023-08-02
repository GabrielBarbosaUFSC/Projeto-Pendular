#include "Arduino.h"



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