#include <Arduino.h>

#define PWM 17
#define ADC 38

void setup(){
    Serial.begin(115200)
    pinMode(PWM, OUTPUT);
    pinMode(ADC, INPUT);
    ledcSetup(0,5000,12);
    ledcAttachPin(PWM, 0);
}
void loop(){
    double mean = 0;
    for (int i = 0; i < 4095; i += 10) {
        ledcWrite (0, i) ; // Define um valor para o PWM
        delay (60) ; // Aguarda o regime permanente do filtro
        for (int j = 0; j < 100; j ++) {
            mean += analogRead (ADC) ;
            delay (0.05);
        }
        mean /= 100.0; // Faz a media de 100 amostras
        Serial.printf ("\n%f %f", i , mean ); // Printa o valor aplicado ao PWM e a media lida
    }
}
