#include <Arduino.h>
#include "FirstOrderFilter.h"
#include "Voltimeter.h"


Voltimeter rodolfo(1, 36);

void setup(){
    Serial.begin(115200);
    rodolfo.begin();
}

void loop(){
    Serial.println(rodolfo.get());
    delay(2000);
}

