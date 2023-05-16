#include <Arduino.h>
#include "Voltimeter.h"

#define PIN 36 //Pino que o voltimetro esta ligado
#define GAIN 1.0 //Ganho do voltimetro
#define TAU 5.0 //Constante de tempo do filtro do multimetro

Voltimeter rodolfo(GAIN, PIN, TAU);

void setup(){
    Serial.begin(115200);
    rodolfo.begin();
}

void loop(){
    Serial.println(rodolfo.get());
    delay(2000);
}

