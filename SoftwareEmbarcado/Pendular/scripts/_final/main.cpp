#include "Arduino.h"
#include "Declaration.h"
#include "CtrlLED.h"
#include "Voltimeter.h"
#include "Motor.h"
#include "MPU9250_asukiaaa.h"


//Voltimeters voltimeters(5.7, PIN_BAT, PIN_SWT);
CtrlLED leds(PIN_LED_R, PIN_LED_G);

Motor m1(PIN_M1_SEN, PIN_M1_PWM, PIN_M1_ENC, 1, 0);
Motor m2(PIN_M2_SEN, PIN_M2_PWM, PIN_M2_ENC, 0, 1);

MPU9250_asukiaaa accel_base(MPU9250_ADDRESS_AD0_HIGH);

void m1_isr(){m1.isr();}
void m2_isr(){m2.isr();}
void speed_task(void *Pv){
    delay(200);
    while (true) {
        //Serial.printf("M1: %d %f\t M2: %d %f\n",
             //m1.get_counter_wise(), m1.get_speed_rpm(), m2.get_counter_wise(), m2.get_speed_rpm());
        m1.set_pwm(100);
        m2.set_pwm(100);
        leds.setcolor("R", 100);
        delay(2000);
        leds.setcolor("G", 100);
        m1.set_pwm(0);
        m2.set_pwm(0);
        delay(5000);
    }
    
}



void setup(){
    Serial.begin(115200);

    Serial.println("Started");
    Wire.begin(SDA_PIN, SCL_PIN);
    accel_base.setWire(&Wire);
    accel_base.beginAccel();
    accel_base.beginMag();


    m1.begin(m1_isr);
    m2.begin(m2_isr);
    xTaskCreate(
        speed_task,
        "print",
        10000,
        NULL,
        1,
        NULL
    );

    // //voltimeters.begin();
    leds.begin();
    //leds.setcolor("RG", 200);
    m1.set_pwm(100);
    m2.set_pwm(100);
}
void loop() {
    accel_base.accelUpdate();

    double ax = accel_base.accelX();
    double ay = accel_base.accelY();
    double az = accel_base.accelZ();
    Serial.printf("ax:%f,ay:%f,az:%f\n", ax, ay, az);
    delay(10);
    m1.timer();
    m2.timer();
    //Serial.printf("BAT: %f \t SWT: %f \n", voltimeters.get_bat(), voltimeters.get_swt());
    //delay(200);
    //Serial.println(leds.get_charging());
    //delay(200);

}

