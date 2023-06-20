#include <Arduino.h>

#define INTERRUPCAO 22    // Porta que recebe o sinal do encoder
#define CONTROL_MOTOR 32  // Porta que comanda o motor
#define SENTIDO 26        // Porta que comanda o sentido do motor

uint16_t vetor[26000];
int64_t past_time=0;
int8_t vetorIndex[4];



hw_timer_t *My_timer = NULL; // Melhoria de timer

int contador_ticks = 0;
int contador_ticks_anterior = 0; 
unsigned long tempo_ciclo = 0; 
double tempo = 0;
int indice = 0;

// Tempo de amostragem
float tempo_amostragem = 0.005; // Em segundos (25 milissegundos)

//void IRAM_ATTR onTimer(){
//   velocidade =  (((2 *PI)/689)*(contador_ticks - contador_ticks_anterior))/tempo_amostragem ;
//   contador_ticks_anterior = contador_ticks;
//}

void IRAM_ATTR conta_ticks(){
  // Função conta o número de sinais do encoder
  if(digitalRead(SENTIDO)){
    contador_ticks--;
  }else{
    contador_ticks++;
  }
  int64_t dif_time = esp_timer_get_time()-past_time;
  if(dif_time> 65000){
    dif_time = 65000;
  }
  vetor[indice]= dif_time;
  past_time = esp_timer_get_time();
  indice++;
  
}

void setup(){
    pinMode(INTERRUPCAO, INPUT_PULLDOWN);
    pinMode(CONTROL_MOTOR,OUTPUT);
    pinMode(SENTIDO, OUTPUT);

    // Definindo interrupções
    attachInterrupt(INTERRUPCAO, conta_ticks, RISING);

    Serial.begin(115200);

}
void loop(){

    
    digitalWrite(SENTIDO, LOW);
    int64_t dif_time = esp_timer_get_time()-past_time;
    if(dif_time> 65000){
      dif_time = 65000;
    }
    vetor[indice]= dif_time;
    past_time = esp_timer_get_time();
    indice++;
    
    
    while(millis() < 3000){
        digitalWrite(CONTROL_MOTOR, HIGH);
    }
    dif_time = esp_timer_get_time()-past_time;
    if(dif_time> 65000){
      dif_time = 65000;
    }
    vetor[indice]= dif_time;
    past_time = esp_timer_get_time();
    vetorIndex[0]=indice;
    indice++;


    while(millis() < 7000){
        digitalWrite(CONTROL_MOTOR, LOW);
    }
    dif_time = esp_timer_get_time()-past_time;
    if(dif_time> 65000){
      dif_time = 65000;
    }
    vetor[indice]= dif_time;
    past_time = esp_timer_get_time();
    vetorIndex[1]=indice;
    indice++;
    digitalWrite(SENTIDO, HIGH);
    
    
    while(millis() < 11000){
        digitalWrite(CONTROL_MOTOR,LOW);
    }
    dif_time = esp_timer_get_time()-past_time;
    if(dif_time> 65000){
      dif_time = 65000;
    }
    vetor[indice]= dif_time;
    past_time = esp_timer_get_time();
    vetorIndex[2]=indice;
    indice++;
    
    
    while(millis() < 14000){
        digitalWrite(CONTROL_MOTOR, HIGH);
    }
    dif_time = esp_timer_get_time()-past_time;
    if(dif_time> 65000){
      dif_time = 65000;
    }
    vetor[indice]= dif_time;
    past_time = esp_timer_get_time();
    vetorIndex[3]=indice;
    indice++;


    // Print na serial
    for(int i=0;i<5;i++){
      for(int j=0;j<=indice;j++){
        if(vetorIndex[i]==j){
          break;
        }else{
          switch (i)
          {
          case 0:
            Serial.printf("\n%d,%d,%d",j,vetor[j],0);
            break;
          case 1:
            Serial.printf("\n%d,%d,%d",j,vetor[j],17);
            break;
          case 2:
            Serial.printf("\n%d,%d,%d",j,vetor[j],-17);
            break;
          case 3:
            Serial.printf("\n%d,%d,%d",j,vetor[j],0);
            break;
          }
        }
        
      }
        
    };
    delay(10000);
    
}
