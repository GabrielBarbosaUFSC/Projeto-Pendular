#include "Voltimeter.h"

Voltimeter::Voltimeter(double G_, double PIN, double TAU):G(G_), pin(PIN), filter(TAU, media()){}
void Voltimeter::begin(){
    pinMode(pin, INPUT);
        xTaskCreatePinnedToCore(
            update,
            "loop2",
            5000,
            this,
            1, 
            NULL,
            0
        );
}
                
double Voltimeter::media() {
    double sum =0;
    for(int i = 0; i<20; i++) 
        sum += analogRead(pin);
    sum /= 20.0;
    sum *= 3.3 / 4095.0;
    return sum * G;
}

void Voltimeter::update(void *pV) {
    vTaskDelay(pdMS_TO_TICKS(200));
    Voltimeter* obj = (Voltimeter*)pV;
    TickType_t begin = xTaskGetTickCount();
    while (true){
        obj->filter.get(obj->media());
        vTaskDelayUntil(&begin, pdMS_TO_TICKS(100));
    }   
}

double Voltimeter::get(){
    return filter.get();
}