#ifndef DECLARATIONSPIN
#define DECLARATIONSPIN

#define PIN_M1_ENC 16 
#define PIN_M1_PWM 26
#define PIN_M1_SEN 19

#define PIN_M2_ENC 17
#define PIN_M2_PWM 25
#define PIN_M2_SEN 18

#define PIN_LED_R 23
#define PIN_LED_G 13

#define PIN_BTN 14
#define PIN_BAT 36
#define PIN_SWT 34

#define SDA_PIN 21
#define SCL_PIN 22

#define AZ_bias 0.04
#define AZ_K -1.06
#define AY_bias 0
#define AY_K 1
#define GX_bias -1.5 
#define R_accel 0.18449

#define _RAD_TO_DEG 57.295779513
#define _DEG_TO_RAD 0.01745329252

void shift_array(double array[], double new_value, int len);
void mul_matrix(double A[], int Ar, int Ac, double B[], double C[]);
void sum_matrix(double A[], double B[], double C[], int len);


#endif