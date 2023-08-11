#include "CtrlLED.h"

CtrlLED::CtrlLED(int PIN_R, int PIN_G): pin_R(PIN_R), pin_G(PIN_G){}
void CtrlLED::begin(){
    check_charging();
    pinMode(pin_R, OUTPUT);
    pinMode(pin_G, OUTPUT);
    digitalWrite(pin_R, LOW);
    digitalWrite(pin_G, LOW);

    xTaskCreatePinnedToCore(
        update,
        "ledtask",
        5000,
        this,
        1,
        NULL,
        0
    );
}

void CtrlLED::check_charging(){
    digitalWrite(pin_R, LOW);
    digitalWrite(pin_G, LOW);
    pinMode(pin_R, INPUT);
    pinMode(pin_G, INPUT);
    charging = digitalRead(pin_G) || digitalRead(pin_R);
    pinMode(pin_R, OUTPUT);
    pinMode(pin_G, OUTPUT);
    digitalWrite(pin_R, stateR);
    digitalWrite(pin_G, stateG);
}

void CtrlLED::set(char COLOR){
    check_charging();
    stateR = COLOR == 'R';
    stateG = COLOR == 'G';
    digitalWrite(pin_R, stateR);
    digitalWrite(pin_G, stateG);
}

void CtrlLED::setcolor(String COLOR, int TIME){
    color = COLOR;
    seq_timer = TIME*1e3;
    seq_len = COLOR.length();
    if (seq_len == 0 ){
        seq_timer = 100000;
        set('F');
    } else if (seq_len == 1){
        seq_timer = 100000;
        set(COLOR[0]);
    } else{
        set(COLOR[0]);
        seq_index = 1;
        pasttime= esp_timer_get_time();
    }
}

void CtrlLED::update(void *pV){
    vTaskDelay(pdMS_TO_TICKS(200));
    CtrlLED* obj = (CtrlLED*)pV;
    TickType_t begin = xTaskGetTickCount();
    while (true){
        uint64_t dtime = esp_timer_get_time() - obj->pasttime;
        if ((obj->seq_len > 1) && (dtime > obj->seq_timer)){
            obj->pasttime = esp_timer_get_time();
            obj->set(obj->color[obj->seq_index]);
            obj->seq_index = (obj->seq_index + 1)%obj->seq_len;
        } else
            obj->check_charging();
        vTaskDelayUntil(&begin, pdMS_TO_TICKS(100));
    }
}

bool CtrlLED::get_charging(){
    return charging;
}

void CtrlLED::change_state(int COMMAND){
    static int past_state = 0;
    if (COMMAND == past_state) return;
    past_state = COMMAND;
    switch (past_state){
        case UNDEFINED: setcolor("F", 1000); break;
        case WORKING: setcolor("G", 1000); break;
        case SATURATED: setcolor("R", 1000); break;
        case OFF: setcolor("RG", 200); break;
        default: break;
    }
}