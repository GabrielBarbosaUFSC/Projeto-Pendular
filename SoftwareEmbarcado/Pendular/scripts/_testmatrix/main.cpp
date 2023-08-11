#include "Arduino.h"

double f_theta[25] = {
    3.0214209019982325, -3.0253489482258216,1.0039304503035837, -2.404075994685112e-6,  4.4418180550765696e-17,
    6.103635318805991, -8.136922097704282, 3.033294042623751,  -7.263725460289371e-6,  1.3420601914481484e-16,
    10.304729232710784,-15.432332649479932,6.127618090372296,  -1.4673603150119488e-5, 2.7111237560675483e-16,
    15.70259164366464, -25.047783655561155,10.34521678524869,  -2.4773352179818818e-5, 4.577173235853009e-16,
    22.39635495214997, -37.160602328331706,15.764285126405353, -3.775022362441948e-5,  6.974805507432406e-16,
};

void shift_array(double array[], double new_value, int len){
    for(int i = len-1; i >=1; i--){
        array[i] = array[i-1];
    }
    array[0] = new_value;
}

void mul_matrix(double A[], int Ar, int Ac, double B[], double C[]){
    for (int i = 0; i < Ar; i++){
        double sum = 0;
        for (int j = 0; j < Ac; j++){
            if (i == 0)
                Serial.println(A[i*Ac +j]*B[j], 10);
            sum +=  A[i*Ac +j]*B[j];
        }
        C[i] = sum;
    }
}

void sum_matrix(double A[], double B[], double C[], int len){
    for (int i = 0; i < len; i++)
        C[i] = A[i] + B[i];
}

void print_matrix(double A[], int len){
    for (int i = 0; i < len; i++){
        Serial.printf("\t%.6f", A[i]);
    }
    Serial.printf("\n");
}


double theta[5] = {-0.012202,-0.012207,-0.012186,-0.012191,-0.012193};

double f[5];


void setup(){
    Serial.begin(115200);

    mul_matrix(f_theta, 5, 5, theta, f);
    print_matrix(f, 5);
}

void loop(){

}