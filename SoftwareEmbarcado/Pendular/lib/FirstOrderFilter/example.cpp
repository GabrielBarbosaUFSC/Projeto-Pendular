#include <Arduino.h>
#include "FirstOrderFilter.h"

#define POT_PIN 36 //Pino do potenciometro 

#define TAU 5.0 //Constante de tempo do filtro do multimetro
#define Y0 0.0 //Valor inicial da variavel filtrada

FirstOrderFilter filter(TAU, Y0);

void setup(){
    Serial.begin(115200);
    pinMode(POT_PIN, INPUT);
}

void loop(){
    filter.get(analogRead(POT_PIN));
    Serial.println(filter.get());
    delay(25);
}

