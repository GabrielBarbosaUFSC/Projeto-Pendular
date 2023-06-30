#include <Arduino.h>


const int red = 25;
const int green = 26;
const int blue = 27;


int index1 = 0;


void setup(){
    pinMode(red, OUTPUT);
    pinMode(green, OUTPUT);
    pinMode(blue, OUTPUT);
    
}
void rgb(String estado_led, float tempo){
    index1 = (index1+1)%estado_led.length();
    if(estado_led[index1]=='R'){
        digitalWrite(red,1);
        digitalWrite(green,0);
        digitalWrite(blue,0);
        delay(tempo*1000);
        index1++;
    }else if(estado_led[index1]=='G'){
        digitalWrite(red,0);
        digitalWrite(green,1);
        digitalWrite(blue,0);
        delay(tempo*1000);
        index1++;
    }else if(estado_led[index1]=='B'){
        digitalWrite(red,0);
        digitalWrite(green,0);
        digitalWrite(blue,1);
        delay(tempo*1000);
        index1++;
    }
    if(index1>2){
        index1=0;
    }

}

void loop(){
    rgb("RGB",0.5);
}



    
