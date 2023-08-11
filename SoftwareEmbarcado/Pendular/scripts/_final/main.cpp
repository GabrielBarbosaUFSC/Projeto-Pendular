#include "Arduino.h"
#include "Declaration.h"
#include "CtrlLED.h"
#include "Voltimeter.h"
#include "Motor.h"
#include "Accel.h"

double f_du[15] = {
    6.388787962426642e-10, 0.0007060192124511295,  0.004587120058253236,
    1.9303217488110554e-9, 0.0021331818445909697,  0.014565639636432806,
    3.899483185182982e-9,  0.004309285731194054,   0.030131289843748816,
    6.583473007800859e-9,  0.007275340716883785,   0.05157831588943017,
    1.0032052847194583e-8, 0.011086337969174805,   0.0793050138120975
};
double f_theta[25] = {
    3.0214209019982325, -3.0253489482258216,    1.0039304503035837,     -2.404075994685112e-6,      4.4418180550765696e-17,
    6.103635318805991,  -8.136922097704282,      3.033294042623751,     -7.263725460289371e-6,      1.3420601914481484e-16,
    10.304729232710784, -15.432332649479932,     6.127618090372296,     -1.4673603150119488e-5,     2.7111237560675483e-16,
    15.70259164366464,  -25.047783655561155,     10.34521678524869,     -2.4773352179818818e-5,     4.577173235853009e-16,
    22.39635495214997,  -37.160602328331706,     15.764285126405353,    -3.775022362441948e-5,      6.974805507432406e-16
};
double K1_theta[5] = {
    0.9936048061348501,
    1.7852607570945291,
    2.2925682891296297,
    2.6005101629797283,
    2.7668926270133376
};
double K1_u = -0.09650310779515792;

CtrlLED leds(PIN_LED_R, PIN_LED_G);
Motor m1(PIN_M1_SEN, PIN_M1_PWM, PIN_M1_ENC, 1, 1);
Motor m2(PIN_M2_SEN, PIN_M2_PWM, PIN_M2_ENC, 0, 0);
Accel accel(MPU9250_ADDRESS_AD0_HIGH);
Voltimeters voltimeters(5.7, PIN_BAT, PIN_SWT);

double theta_bias = 0.012048;
double free_response_du[5];
double free_response_theta[5];
double free_response[5];

double du[3] = {0, 0, 0};
double theta[5];
double dU[1] = {0};
double U = 0;
 
hw_timer_t *control_timer = NULL;

//#define DEBUG_CONTROL
#define DEBUG_DATA
//#define DEBUG_APPLY
//#define DEBUG_ACCEL 
//#define DEBUG_THETA
#define DISABLE_MOTOR

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
    };

    Data data[200];
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
        return apply_return{bat_voltage, 0.0};
    }

    double abs_pwm = 0;
    // if (abs(U) > 0.3)
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

    #ifdef DISABLE_MOTOR
        m1.set_pwm(pwm);
        m2.set_pwm(pwm);
    #endif

    if (abs_pwm == 1) U = bat_voltage - V0;
    if (abs_pwm ==-1) U = -bat_voltage + V0;

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
    #ifdef DEBUG_DATA
        delay(1000);
        Serial.println("Printing Data");
        Serial.println("n,time,theta,dUtheta,dUu,dU,U,battery_voltage,PWM");
        for(int i = 0; i < 200; i++){
            Data sdata = data[i];
            Serial.printf("%d,%.0f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f,%.8f\n",
            i,
            double(sdata.time),
            sdata.theta,
            sdata.dU_theta,
            sdata.dU_u,
            sdata.dU,
            sdata.U,
            sdata.battery_voltage,
            sdata.PWM
            );
        }
        Serial.println("End printing");
        while (true);
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
        while (true);
    #endif

}

void IRAM_ATTR control(){
    double theta_ = accel.filtered();
    if (abs(theta_) < 0.025) theta_ = 0;
    shift_array(theta, theta_, 5);

    mul_matrix(f_theta, 5, 5, theta, free_response_theta);
    mul_matrix(f_du, 5, 3, du, free_response_du);
    sum_matrix(free_response_du, free_response_theta, free_response, 5);
    mul_matrix(K1_theta, 1, 5, free_response, dU);

    double dU_theta = dU[0];
    double dU_u = K1_u*(U);
    dU[0] += K1_u*(U);
    U += dU[0];

    shift_array(du, dU[0], 3);

    #ifdef DEBUG_CONTROL
        Serial.printf("\ntheta:%f\tU:%f\tdu:%f",theta_, U, dU[0]);
    #endif

    apply_return data_ = apply_voltage(U);
    U = data_.apllied_U;

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
        data[index_data] = step_info;
        if (index_data == 199){
            m1.set_pwm(0);
            m2.set_pwm(0);
            timerAlarmDisable(control_timer);
            print_data();
        }
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
        if (index_data == 1999){
            m1.set_pwm(0);
            m2.set_pwm(0);
            timerAlarmDisable(control_timer);
            print_data();
        } else index_data++;
        
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

    control_timer = timerBegin(0, 80/4, true);
    timerAttachInterrupt(control_timer, &control, true);
    timerAlarmWrite(control_timer, 4*20000, true);

    delay(3000);

    init_theta();
    timerAlarmEnable(control_timer);
}

void loop() {
    update_theta(); 
    delayMicroseconds(5);  
}