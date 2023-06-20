#include <Arduino.h>

#define ENC 22
#define PWM 32
#define SEN 26

uint16_t data[26000];
int64_t pasttime = 0;

int index_ = 0;
int counter = 0;
int change[4] = {0, 0 ,0, 100000};
int voltage[4] = {0, 17, -17, 0};


void IRAM_ATTR interrupt(){
    int64_t dif_time = esp_timer_get_time() - pasttime;
    if (dif_time>65000) dif_time = 0;
    data[index_] = dif_time;
    pasttime = esp_timer_get_time();
    index_++;
}

void setup(){
    pinMode(ENC, INPUT_PULLUP);
    pinMode(PWM, OUTPUT);
    pinMode(SEN, OUTPUT);
    Serial.begin(115200);

    attachInterrupt(ENC, interrupt, RISING);
    pasttime = esp_timer_get_time();

    digitalWrite(SEN, LOW);
    digitalWrite(PWM, HIGH);
    while(millis() < 6000)  delay(1);
    
    digitalWrite(SEN, LOW);
    digitalWrite(PWM, LOW);
    change[counter] = index_;
    counter++; 
    while(millis() < 10000) delay(1);


    digitalWrite(SEN, HIGH);
    digitalWrite(PWM, LOW);
    change[counter] = index_;
    counter++; 
    while(millis() < 14000) delay(1);

    digitalWrite(SEN, HIGH);
    digitalWrite(PWM, HIGH);
    change[counter] = index_;
    counter++; 
    while(millis() < 17000) delay(1);

    counter = 0;
    for(int i = 0; i < index_; i++){
      if (i > change[counter]) counter++;
      Serial.printf("\n%d,%d,%d", i, voltage[counter] ,data[i]);
      delay(2);
    }  
}

void loop(){}