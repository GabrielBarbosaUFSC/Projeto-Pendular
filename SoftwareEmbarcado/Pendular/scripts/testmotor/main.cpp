#include <Arduino.h>

#define INTERRUPCAO 22    // Porta que recebe o sinal do encoder
#define SINAL_LIMPA 25    // Porta que recebe o sinal para limpar contador
#define BOTAO 26          // Porta que recebe o sinal do botao para ligar o motor
#define CONTROL_MOTOR 32  // Porta que comanda o motor

hw_timer_t *My_timer = NULL;


int contador_ticks = 0;
unsigned long tempo_ciclo = 0; 
double tempo = 0;
int contador_ticks_total = 0;
double velocidade = 0;
double angulo = 0;
int pwm = 0;


float tempo_amostragem = 0.025; // Em segundos (25 milissegundos)

void IRAM_ATTR onTimer(){
   velocidade =  (((2 *PI)/689)*contador_ticks)/tempo_amostragem ;
   contador_ticks = 0;
}

void IRAM_ATTR conta_ticks(){
  // Função conta o número de sinais do encoder
  contador_ticks++;
  contador_ticks_total++;
}

void IRAM_ATTR limpa_conta(){
  // Função limpa contador do encoder
  contador_ticks_total = 0;
}


void serial(void*a){
  while(true){
    delay(400);
    // Print da quantidade de ticks do Encoder
    angulo = (((2 *PI)/689)*contador_ticks_total);
    tempo_ciclo = millis();
    Serial.printf("\n%d,%.4f,%d",esp_timer_get_time(),velocidade,pwm);

  }

}

void montanhaRussa(void*b){
  while(true){
    for(int i =4094; i>0;i = i-150){
      ledcWrite(0,i);
      pwm = i;
      delay(2000);
    }
  }
}

void setup() {
  //Definindo pinos
  pinMode(INTERRUPCAO, INPUT_PULLDOWN);
  // pinMode(SINAL_LIMPA, INPUT_PULLDOWN);
  // pinMode(BOTAO, INPUT_PULLDOWN);
  pinMode(CONTROL_MOTOR,OUTPUT);

  // Definindo interrupções
  attachInterrupt(INTERRUPCAO, conta_ticks, RISING);
  // attachInterrupt(SINAL_LIMPA, limpa_conta, RISING);
  My_timer = timerBegin(0, 80, true);
  timerAttachInterrupt(My_timer, &onTimer, true);
  timerAlarmWrite(My_timer, 1000000*tempo_amostragem, true);
  timerAlarmEnable(My_timer);

  ledcSetup(0,5000,12);
  ledcAttachPin(CONTROL_MOTOR,0);
  ledcWrite(0,4095);

  Serial.begin(115200);

  xTaskCreate(serial,"serial",10000,NULL,1,NULL);
  xTaskCreate(montanhaRussa,"Montanha",10000,NULL,0,NULL);

}

void loop() {
  // Lógica de controle do motor
  // if(digitalRead(BOTAO)==HIGH){
  //   digitalWrite(CONTROL_MOTOR,LOW);
  // }else{
  //   digitalWrite(CONTROL_MOTOR,HIGH);
  // }
  }
