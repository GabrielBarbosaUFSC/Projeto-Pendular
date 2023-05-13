#include "LineSensors.h"

LineSensors::LineSensors(IR_Pins PINS):IR(PINS){}
void LineSensors::begin(){
    for (int i = 0; i < 8; i++){
        pinMode(IR.pins[i], INPUT_PULLDOWN);
    }
}

uint8_t LineSensors::get(){
    uint8_t sum = 0;
    for (int i = 0; i < 8; i++){
        sum += digitalRead(IR.pins[i])<<(7-i);
    }
    return sum;
}

void LineSensors::get(uint8_t buffer[], int len){
    for (int i = 0; i < 8; i++){
        buffer[i] = digitalRead(IR.pins[i]);
    }
}