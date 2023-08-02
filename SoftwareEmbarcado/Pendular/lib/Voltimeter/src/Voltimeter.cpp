#include "Voltimeter.h"

Voltimeter::Voltimeter(double G_, double PIN):G(G_), pin(PIN){}
void Voltimeter::begin(bool create_task){
    pinMode(pin, INPUT);
    voltage = media();
    if(!create_task) return;
    xTaskCreate(
        update,
        "loop2",
        5000,
        this,
        1, 
        NULL
    );
}
                
double Voltimeter::media() {
    double sum =0;
    for(int i = 0; i<20; i++) 
        sum += analogRead(pin);
    sum /= 20.0;
    sum = apply_ajust(sum);
    return sum * G;
}

double Voltimeter::apply_ajust(double RAW){
    if (RAW < 270) return 0;
    if (RAW > 3890) return 3.3; 
    double read = 0;
    double x = 1;
    for (int i = 4; i >=0; i--){
        read += ajust[i]*x;
        x *= RAW;
    }
    return read;
}

void Voltimeter::update(void *pV) {
    vTaskDelay(pdMS_TO_TICKS(200));
    Voltimeter* obj = (Voltimeter*)pV;
    TickType_t begin = xTaskGetTickCount();
    while (true){
        obj->voltage = obj->media();
        vTaskDelayUntil(&begin, pdMS_TO_TICKS(100));
    }   
}

double Voltimeter::get(){
    return voltage;
}
void Voltimeter::update(){
    voltage = media();
}

Voltimeters::Voltimeters(double G, int PIN_bat, int PIN_swt):
    bat(G, PIN_bat), swt(G, PIN_swt){}

void Voltimeters::begin(){
    bat.begin(false);
    swt.begin(false);
    xTaskCreate(
        update,
        "voltimeters",
        5000,
        this, 
        1,
        NULL
    );
}

void Voltimeters::update(void *pV){
    vTaskDelay(pdMS_TO_TICKS(500));
    Voltimeters* obj = (Voltimeters*)pV;
    TickType_t begin = xTaskGetTickCount();
    while (true){
        obj->bat.update();
        obj->swt.update();
        vTaskDelayUntil(&begin, pdMS_TO_TICKS(100));
    }  
}

double Voltimeters::get_bat(){
    return bat.get();
}
double Voltimeters::get_swt(){
    return swt.get();
}