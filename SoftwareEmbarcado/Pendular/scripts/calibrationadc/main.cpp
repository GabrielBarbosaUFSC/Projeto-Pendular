#include <Arduino.h>

#define PWM 17
#define ADC 36

//Pelo processamento dos dados , coeficientes de ajuste de curva
double coeffs[5] = {
    - 1.1458622215428729e-14,
    + 7.402422341572887e-11,
    - 1.6375806348536795e-7,
    0.0009507345681822474,
    0.11440086869494298
};

//Funcao que corrige o valor do PWM
double read(double RAW){
    if (RAW < 270) return 0;
    if (RAW > 3890) return 3.3; 
    double voltage = coeffs[4];
    double raw_temp = RAW;
    for (int i = 3; i >= 0; i--){
        voltage += coeffs[i]*raw_temp;
        raw_temp = raw_temp*RAW;
    }
    return voltage;
}


void setup(){
    Serial.begin(115200);
    pinMode(PWM, OUTPUT);
    pinMode(ADC, INPUT);
    ledcSetup(0,5000,12);
    ledcAttachPin(PWM, 0);

    ledcWrite(0, 1000);
    delay(1000);
}

void routine(int i){
    double mean = 0;
    ledcWrite (0, i);
    delay(120); 
    for (int j = 0; j < 100; j ++) {
        mean += analogRead(ADC) ;
        delayMicroseconds(25);
    }
    mean /= 100.0; 
    Serial.printf ("\n%d; %f", i , mean ); 
}

// void loop(){
//     for (int i = 0; i < 4095; i += 5)
//         routine(i);
//     ledcWrite(0, 4095);
//     delay(10000);
//     for (int i = 4095; i >= 0; i -= 5)
//         routine(i);
//     delay(100000);
// }

void loop(){
    double sum = 0;
    for (int i = 0; i < 100; i++)
        sum += analogRead(ADC);
    sum /= 100.0;
    Serial.printf("\n%f\t %f", sum, read(sum));
    //Serial.println(sum);
    //Serial.println(read(sum));
    delay(50);
}
