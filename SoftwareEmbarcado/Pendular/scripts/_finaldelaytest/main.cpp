#include "Arduino.h"
#include "Declaration.h"
#include "CtrlLED.h"
#include "Voltimeter.h"
#include "Motor.h"
#include "Accel.h"

#define CONTROL_DELAY
#include "GPC.cpp"

CtrlLED leds(PIN_LED_R, PIN_LED_G);
Motor m1(PIN_M1_SEN, PIN_M1_PWM, PIN_M1_ENC, 1, 1);
Motor m2(PIN_M2_SEN, PIN_M2_PWM, PIN_M2_ENC, 0, 0);
Accel accel(MPU9250_ADDRESS_AD0_HIGH);
Voltimeters voltimeters(5.7, PIN_BAT, PIN_SWT);

const int n_rows_free = 3;
const int n_theta = 5;
const int n_du = 4;

double theta_bias = -0.014; //0.016; 014
double gain_ajust = 0.9;  //1.02;
double bias_ajust = -2; //-2;

double free_response_du[n_rows_free];
double free_response_theta[n_rows_free];
double free_response[n_rows_free];

double du[n_du] = {0, 0, 0, 0};
double theta[n_theta];
double dU[1] = {0};
double U = 0;

hw_timer_t *control_timer = NULL;
bool debug_flag = false;
int time_control = 10000;

//#define DEBUG_CONTROL
//#define DEBUG_DATA
//#define DEBUG_APPLY
//#define DEBUG_ACCEL 
//#define DEBUG_THETA
//#define DISABLE_MOTOR
//#define DEBUG_MATRIX

#ifdef DEBUG_MATRIX
    struct Data {
        double time;
        double y0;
        double y1;
        double y2;
        double y3;
        double y4;
        double du1;
        double du2;
        double du3;
        double du4;
        double U1;
        double du;
        
    };
    Data data[500];
    int index_data = 0;
#endif

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
    //double V0 = 3.47;
    double V0 = 3.47 + bias_ajust;

    double bat_voltage = voltimeters.get_swt();
    if (bat_voltage < 7.0){
        leds.change_state(OFF);
        return apply_return{bat_voltage, 0.0, 0.0};
    }
    
    double abs_pwm = 0;
    double gain_U = U*gain_ajust;
    if (abs(gain_U) > 0.01)
        abs_pwm = (abs(gain_U) + V0)/bat_voltage;
    else{
        U = 0;
        gain_U = 0; 
    }
       

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

    #ifdef DEBUG_MATRIX
        delay(1000);
        Serial.println("Printing Data");
        Serial.println("i,time,y0,y1,y2,y3,y4,du1,du2,du3,du4,U1,du");
        for (int i = 0; i < 500; i++){
            Data sdata = data[i];
            Serial.printf("%d,%.0f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f\n",
                i,
                sdata.time,
                sdata.y0,
                sdata.y1,
                sdata.y2,
                sdata.y3,
                sdata.y4,
                sdata.du1,
                sdata.du2,
                sdata.du3,
                sdata.du4,
                sdata.U1,
                sdata.du
            );
        }
    #endif

    while(true);
}


int64_t pulsecounter = 0;
void IRAM_ATTR counter(){
    if(U > 0)
        pulsecounter++;
    else
        pulsecounter--;
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
    
    shift_array(theta, theta_, n_theta);
    mul_matrix(f_theta, n_rows_free, n_theta, theta, free_response_theta);
    mul_matrix(f_du, n_rows_free, n_du, du, free_response_du);
    sum_matrix(free_response_du, free_response_theta, free_response, n_rows_free);

    double thetamax = 0.005;
    double kp = thetamax/60.0;
    double err = 0.032*pulsecounter*kp;

    if(err > thetamax) err = thetamax;
    if(err < -thetamax) err = -thetamax;

    for (int i = 0; i < n_rows_free; i++){
        free_response[i]  += err;
    }

    mul_matrix(K1_theta, 1, n_rows_free, free_response, dU);
    
    double dU_theta = dU[0];
    double dU_u = K1_u[0]*(-U);
    dU[0] += K1_u[0]*(-U);

    if(pasttime < 3000000)
        return;
    
    double tempU = U;
    apply_return data_ = apply_voltage(U + dU[0]);

    //dU[0] = data_.apllied_U - U;
    U = data_.apllied_U;
    
    #ifdef DEBUG_MATRIX
        if (!debug_flag){
            data[index_data].time = pasttime;
            data[index_data].y0 = theta[0];
            data[index_data].y1 = theta[1];
            data[index_data].y2 = theta[2];
            data[index_data].y3 = theta[3];
            data[index_data].y4 = theta[4];
            data[index_data].du1 = du[0];
            data[index_data].du2 = du[1];
            data[index_data].du3 = du[2];
            data[index_data].du4 = du[3];
            data[index_data].du = dU[0];
            data[index_data].U1 = tempU;

            if (index_data == 499)
                debug_flag = true;
            else 
                index_data ++;
        }
    #endif

    dU[0] = U - tempU;
    shift_array(du, dU[0], n_du);

    #ifdef DEBUG_CONTROL
        Serial.printf("\ntheta:%f\tU:%f\tdu:%f\tduu:%f\tdutheta:%f",theta_, U, dU[0], dU_u, dU_theta);
    #endif

    #ifdef DEBUG_DATA
        if (debug_flag) return;
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
        if (esp_timer_get_time() < 5000000)
            return;
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
    timerAlarmEnable(control_timer);
    attachInterrupt(PIN_M1_ENC, counter, RISING);
}

void loop() {
    if (debug_flag)
        print_data();
    update_theta(); 
    delayMicroseconds(5);  
}