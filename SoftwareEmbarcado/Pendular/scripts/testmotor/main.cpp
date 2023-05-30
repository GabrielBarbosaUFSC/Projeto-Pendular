#include <Arduino.h>
#define ADC_PIN 36
#define PWM_PIN 26
#define CTRL_PIN 27

void setup(){
    pinMode(ADC_PIN, INPUT);
    pinMode(PWM_PIN, OUTPUT);
    pinMode(CTRL_PIN, OUTPUT);
    ledcSetup(0, 5000, 12);
    ledcAttachPin(PWM_PIN, 0);
}

double media(){
    double sum = 0;
    for(int i = 0; i < 100; i++) 
        sum += analogRead(ADC_PIN);
    return sum/100.0;
}

void loop(){
    // double signal = -4095 + 2*media();
    // if (signal >= 0){
    //     digitalWrite(CTRL_PIN, HIGH);
    //     ledcWrite(0, 4095- abs(signal));
    // } else {
    //    digitalWrite(CTRL_PIN, LOW);
    //     ledcWrite(0, 4095 - abs(signal)); 
    // }
    digitalWrite(CTRL_PIN, HIGH);
    delay(300);
    digitalWrite(CTRL_PIN, LOW);
    delay(300);

}