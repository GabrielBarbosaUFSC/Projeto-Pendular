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
    int64_t t1omega = esp_timer_get_time();
    raw_gyro = (accelunit.gyroX() -  GX_bias);
    int64_t t1theta = esp_timer_get_time();
    raw_theta = get_rawtheta();
    int64_t t2theta = esp_timer_get_time();

    int64_t ttheta = (t1theta+t2theta)/2;
    int64_t tomega = (t1omega + t1theta)/2;

    double t1 = (tomega - theta_.time)/1e6;
    double t2 = (ttheta-tomega)/1e6;

    theta = filter.getAngle(raw_theta - bias*_RAD_TO_DEG, raw_gyro, past_rate, t1, t2)*_DEG_TO_RAD;
    past_rate = raw_gyro;

    theta_.theta = theta;
    theta_.time = ttheta;
    add_to_buffer(theta_);
    return theta;
}

double Accel::raw(){
    return raw_theta*_DEG_TO_RAD;
}

double Accel::filtered(bool raw){
    //if ((abs(theta) < 0.01) && (raw == false)) return 0;
    return theta;
}

double Accel::get_raw_gyro(){
    return raw_gyro;
}

ThetaInfo Accel::get_thetainfo(){
    return theta_;
}

void Accel::add_to_buffer(ThetaInfo add){
    buffer[index_] = add;
    index_ = (index_ + 1)%BUFFER_SIZE;
}
ThetaInfo Accel::get_theta_delay(int64_t time){
    int j = 0;
    for (int i = 0; i < BUFFER_SIZE; i++){
        j = (index_ + i)%BUFFER_SIZE;
        if (buffer[j].time > time)
            break;
        if (i == (BUFFER_SIZE -1)){
            ThetaInfo return_ = {0, 0};
            return return_;
        }
    }

    double dt = (buffer[j].time - buffer[j-1].time)/1e6;
    double dtheta = (buffer[j].theta - buffer[j-1].theta);
    double t = (time-buffer[j-1].time)/1e6;
    double theta = buffer[j-1].theta + dtheta/dt*t;
    ThetaInfo return_ = {theta, time};
    return return_;
}