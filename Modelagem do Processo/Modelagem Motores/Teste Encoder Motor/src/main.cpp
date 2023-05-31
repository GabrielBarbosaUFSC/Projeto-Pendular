#include <Arduino.h>

#define INTERRUPCAO 5
#define SINAL_LIMPA 25
#define BOTAO 26
#define CONTROL_MOTOR 27

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
  pinMode(INTERRUPCAO, INPUT);
  pinMode(SINAL_LIMPA, INPUT);
  pinMode(BOTAO, INPUT);
  pinMode(CONTROL_MOTOR,OUTPUT);

  // Definindo interrupções
  attachInterrupt(INTERRUPCAO, conta_ticks, RISING);
  attachInterrupt(SINAL_LIMPA, limpa_conta, RISING);

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
  if((millis() - tempo_ciclo) >= 500){
    tempo_ciclo = millis();
    Serial.print("Quantidade sinais Encoder: ");
    Serial.println(contador_ticks);
  }
}

