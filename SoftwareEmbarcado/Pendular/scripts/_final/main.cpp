#include "Arduino.h"
#include "Declaration.h"
#include "CtrlLED.h"
#include "Voltimeter.h"
#include "Motor.h"
#include "Accel.h"
//#define CONTROL_DELAY
#include "GPC.cpp"

CtrlLED leds(PIN_LED_R, PIN_LED_G);
Motor m1(PIN_M1_SEN, PIN_M1_PWM, PIN_M1_ENC, 1, 1);
Motor m2(PIN_M2_SEN, PIN_M2_PWM, PIN_M2_ENC, 0, 0);
Accel accel(MPU9250_ADDRESS_AD0_HIGH);
Voltimeters voltimeters(5.7, PIN_BAT, PIN_SWT);

const int n_rows_free = 8;
double theta_bias = 0.016;
double free_response_du[n_rows_free];
double free_response_theta[n_rows_free];
double free_response[n_rows_free];

double du[3] = {0, 0, 0};
double theta[5];
double dU[1] = {0};
double U = 0;

hw_timer_t *control_timer = NULL;
bool debug_flag = false;
int time_control = 10000;


//#define DEBUG_CONTROL
#define DEBUG_DATA
//#define DEBUG_APPLY
//#define DEBUG_ACCEL 
//#define DEBUG_THETA
//#define DISABLE_MOTOR

#ifdef DEBUG_ACCEL
    struct Data {
        double time;
        double raw_accel;
        double raw_gyro;
        double kalman_accel; 
    };

    Data data[2000];
    int index_data = 0;
    
#endif

#ifdef DEBUG_DATA
    struct Data{
        int64_t time;
        double theta;
        double dU_theta;
        double dU_u;
        double dU;
        double U;
        double battery_voltage;
        double PWM;
        int64_t compute_control;
        int64_t time_accel;
    };

    Data data[500];
    int index_data = 0;
#endif

struct apply_return{
    double battery;
    double PWM;
    double apllied_U;
};

apply_return apply_voltage(double U){
    double V0 = 3.47;
    double bat_voltage = voltimeters.get_swt();
    if (bat_voltage < 7.0){
        leds.change_state(OFF);
        return apply_return{bat_voltage, 0.0, 0.0};
    }
    double abs_pwm = 0;
    if (abs(U) > 0.1)
        abs_pwm = (abs(U) + V0)/bat_voltage;

    #ifdef DEBUG_APPLY 
        double abs_pwm2 = abs_pwm; 
    #endif

    if (abs_pwm >= 1.0){
        abs_pwm = 1;
        leds.change_state(SATURATED);
    } else
        leds.change_state(WORKING);

    double pwm = 0;
    if (U > 0)
        pwm = abs_pwm*100.0;
    else
        pwm = -abs_pwm*100.0;
 
    #ifdef DEBUG_APPLY 
        Serial.printf("\n%f\t%f\t%f\t%f\t%f", U, bat_voltage, abs_pwm2, abs_pwm, pwm);
    #endif

    #ifndef DISABLE_MOTOR
        m1.set_pwm(pwm);
        m2.set_pwm(pwm);
    #endif
    if(abs_pwm == 1){
        if (U > 0) 
            U = bat_voltage - V0;
        else if (U < 0)
            U = -bat_voltage+V0;
    }
    return apply_return{bat_voltage, pwm, U};
}

void init_theta(){
    accel.update(theta_bias) ;
    for (int i = 0; i < 5; i++)
        theta[i] = accel.filtered();

    for(int i = 0; i < 10; i++){
        for (int j = 0; j < 20; j++){
            accel.update(theta_bias);
        }
        shift_array(theta, accel.filtered(), 5);
    }
}

void print_data(){
    m1.set_pwm(0);
    m2.set_pwm(0);
    leds.change_state(SATURATED);
    timerAlarmDisable(control_timer);
    delay(1000);
    
    #ifdef DEBUG_DATA
        delay(1000);
        Serial.println("Printing Data");
        Serial.print("n,time,theta,dUtheta,dUu,dU,U,battery_voltage,PWM,computetime,sensortime\n");
        for(int i = 0; i < 500; i++){
            Data sdata = data[i];
            Serial.printf("%d,%.0f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.0f,%.0f\n",
                i,
                double(sdata.time),
                sdata.theta,
                sdata.dU_theta,
                sdata.dU_u,
                sdata.dU,
                sdata.U,
                sdata.battery_voltage,
                sdata.PWM,
                double(sdata.compute_control),
                double(sdata.time_accel)
            );
        }
        Serial.println("End printing");
    #endif

    #ifdef DEBUG_ACCEL
        delay(1000);
        Serial.println("Printing Data");
        Serial.println("i,time,raw_accel,raw_gyro,kalman_accel");
        for (int i = 0; i < 2000; i++){
            Data sdata = data[i];
            Serial.printf("%d,%.0f,%.8f,%.8f,%.8f\n",
                i,
                sdata.time,
                sdata.raw_accel,
                sdata.raw_gyro,
                sdata.kalman_accel
            );
        }
        Serial.println("End printing");
    #endif

    while(true);
}

void IRAM_ATTR control(){
    int64_t pasttime = esp_timer_get_time();
    ThetaInfo thetainfo = accel.get_theta_delay(pasttime - 10000);
    // #ifdef DEBUG_CONTROL
    //     double theta_ = accel.filtered();
    // #else
    //     double theta_ = accel.filtered();
    // #endif

    double theta_ = thetainfo.theta;

    int64_t time_accel = pasttime - thetainfo.time;
    
    shift_array(theta, theta_, 5);
    mul_matrix(f_theta, n_rows_free, 5, theta, free_response_theta);
    mul_matrix(f_du, n_rows_free, 3, du, free_response_du);
    sum_matrix(free_response_du, free_response_theta, free_response, n_rows_free);
    mul_matrix(K1_theta, 1, n_rows_free, free_response, dU);
    
    double dU_theta = dU[0];
    double dU_u = K1_u[0]*(-U);
    dU[0] += K1_u[0]*(-U);
    
    apply_return data_ = apply_voltage(U + dU[0]);

    dU[0] = data_.apllied_U - U;
    U = data_.apllied_U;

    shift_array(du, dU[0], 3);

    #ifdef DEBUG_CONTROL
        Serial.printf("\ntheta:%f\tU:%f\tdu:%f\tduu:%f\tdutheta:%f",theta_, U, dU[0], dU_u, dU_theta);
    #endif

    #ifdef DEBUG_DATA
        Data step_info;
        step_info.battery_voltage = data_.battery;
        step_info.dU = dU[0];
        step_info.dU_theta = dU_theta;
        step_info.dU_u = dU_u;
        step_info.PWM = data_.PWM;
        step_info.theta = theta_;
        step_info.time = esp_timer_get_time();
        step_info.U = U;
        step_info.compute_control = step_info.time-pasttime;
        step_info.time_accel = time_accel;
        data[index_data] = step_info;
        if (index_data == 499)
            debug_flag = true;
        index_data ++;
    #endif
}

void update_theta(){

    accel.update(theta_bias);

    #ifdef DEBUG_THETA
        Serial.println(accel.filtered(), 10);
    #endif
    
    #ifdef DEBUG_ACCEL
        Data this_step;
        this_step.time = esp_timer_get_time();
        this_step.raw_accel = accel.raw()- theta_bias;
        this_step.raw_gyro = accel.get_raw_gyro();
        this_step.kalman_accel = accel.filtered();

        data[index_data] = this_step;
        if (index_data == 1999)
            debug_flag = true;
        else index_data++;
        
    #endif
}

void setup(){
    Serial.begin(115200);
    accel.begin();
    m1.begin();
    m2.begin();
    voltimeters.begin();
    leds.begin();
    m1.set_pwm(0);
    m2.set_pwm(0);

    control_timer = timerBegin(0, 20, true);
    timerAttachInterrupt(control_timer, &control, true);
    timerAlarmWrite(control_timer, 4*time_control, true);
    delay(3000);
    init_theta();
    timerAlarmEnable(control_timer);
}

void loop() {
    if (debug_flag)
        print_data();
    update_theta(); 
    delayMicroseconds(5);  
}