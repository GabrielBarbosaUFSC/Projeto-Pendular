#include <Arduino.h>

#define INTERRUPCAO 22    // Porta que recebe o sinal do encoder
#define SINAL_LIMPA 25    // Porta que recebe o sinal para limpar contador
#define BOTAO 26          // Porta que recebe o sinal do botao para ligar o motor
#define CONTROL_MOTOR 32  // Porta que comanda o motor

int contador_ticks = 0;
unsigned long tempo_ciclo = 0; 

void IRAM_ATTR conta_ticks(){
  // Função conta o número de sinais do encoder
  contador_ticks++;
}

void IRAM_ATTR limpa_conta(){
  // Função limpa contador do encoder
  contador_ticks = 0;
}

void setup() {
  //Definindo pinos
  pinMode(INTERRUPCAO, INPUT_PULLDOWN);
  pinMode(SINAL_LIMPA, INPUT);
  pinMode(BOTAO, INPUT);
  pinMode(CONTROL_MOTOR,OUTPUT);

  // Definindo interrupções
  attachInterrupt(INTERRUPCAO, conta_ticks, RISING);
  attachInterrupt(SINAL_LIMPA, limpa_conta, HIGH);

  Serial.begin(115200);
}

void loop() {
  // Lógica de controle do motor
  if(digitalRead(BOTAO)==HIGH){
    digitalWrite(CONTROL_MOTOR,LOW);
  }else{
    digitalWrite(CONTROL_MOTOR,HIGH);
  }

  // Print da quantidade de ticks do Encoder
  if((millis() - tempo_ciclo) >= 1000){
    tempo_ciclo = millis();
    Serial.print("Quantidade sinais Encoder: ");
    Serial.println(contador_ticks);
  }
}

