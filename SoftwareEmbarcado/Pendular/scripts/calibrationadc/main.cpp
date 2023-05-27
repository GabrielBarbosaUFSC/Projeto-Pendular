#include <Arduino.h>

#define PWM 17
#define ADC 36

void setup(){
    Serial.begin(115200);
    pinMode(PWM, OUTPUT);
    pinMode(ADC, INPUT);
    ledcSetup(0,5000,12);
    ledcAttachPin(PWM, 0);
}

void routine(int i){
    double mean = 0;
    ledcWrite (0, i);
    delay(60); 
    for (int j = 0; j < 100; j ++) {
        mean += analogRead(ADC) ;
        delayMicroseconds(50);
    }
    mean /= 100.0; 
    Serial.printf ("\n%d; %f", i , mean ); 
}

void loop(){
    for (int i = 0; i < 4095; i += 10)
        routine(i);
    ledcWrite(0, 4095);
    delay(10000);
    for (int i = 4095; i >= 0; i -= 10)
        routine(i);
    delay(100000);
}

//Pelo processamento dos dados , coeficientes de ajuste de curva
double coeffs[5] = {
    -1.2899367365664596e-14, 
    8.045726123336793e-11,
    -1.7149417262571565e-07,
    0.0009699709436244759,
    0.11228152405074186
};

//Funcao que corrige o valor do PWM
double read(double RAW){
    double voltage = coeffs[4];
    for (int i = 3; i >= 0; i--){
        voltage += coeffs[i]*RAW;
        RAW = RAW*RAW;
    }
    return voltage;
}