#include "Declaration.h"
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
            sum +=  A[i*Ac +j]*B[j];
        }
        C[i] = sum;
    }
}

void sum_matrix(double A[], double B[], double C[], int len){
    for (int i = 0; i < len; i++)
        C[i] = A[i] + B[i];
}
