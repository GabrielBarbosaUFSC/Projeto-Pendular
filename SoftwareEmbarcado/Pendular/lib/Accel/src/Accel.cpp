#include "Accel.h"
#include "Declaration.h"

Accel::Accel(int I2cAddress):accelunit(I2cAddress){}
void Accel::begin(){
    Wire.begin(SDA_PIN, SCL_PIN);
    accelunit.setWire(&Wire);
    accelunit.beginAccel();
    accelunit.beginGyro();
    pasttime = esp_timer_get_time();
    filter.setAngle(get_rawtheta());
}

double Accel::get_rawtheta(){
    accelunit.gyroUpdate();
    accelunit.accelUpdate();
    double az = (accelunit.accelZ() - AZ_bias)/(AZ_K);
    double ay = (accelunit.accelY() - AY_bias)/(AY_K);
    return atan2(ay, az)*_RAD_TO_DEG;
}

double Accel::update(double bias){
    double dt = (esp_timer_get_time() - pasttime)/(1e6);
    pasttime = esp_timer_get_time();
    raw_gyro = (accelunit.gyroX() -  GX_bias);
    raw_theta = get_rawtheta();
    //Serial.println(theta_raw, 10);
    theta = filter.getAngle(raw_theta, raw_gyro, dt)*_DEG_TO_RAD - bias;
    return theta;
}

double Accel::raw(){
    return raw_theta*_DEG_TO_RAD;
}

double Accel::filtered(){
    return theta;
}

double Accel::get_raw_gyro(){
    return raw_gyro;
}