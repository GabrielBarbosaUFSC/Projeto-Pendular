
#include "Voltimeter.h"

Voltimeter::Voltimeter(double G_, double PIN):G(G_), pin(PIN), filter(5, 0){}
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
            double cleber =0;
            for(int i = 0; i<20; i++) 
                cleber += analogRead(pin);
            cleber /= 20.0;
            cleber *= 3.3 / 4095.0;
            return cleber * G;
        }

        void Voltimeter::update(void *pV) { //tiramos o static pq tava dando erro :)
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