#include <SoftwareWire.h>
#include <MPU6050.h>

/*
 A estrutura "dados" foi criada na lib MPU6050
 é usada para armazenar os valores de aceleração e giroscópio nos eixos X, Y e Z.
 Cada campo da estrutura representa a leitura de 16 bits de um eixo específico.
 E tem o seguinte formato:

struct dados {
  int16_t X;
  int16_t Y;
  int16_t Z;
};
*/

MPU6050 mpu;

void setup()
{
  Serial.begin(9600);
  mpu.begin();
}

void loop()
{
  mpu.readData();
  dados accData = mpu.getAcceleration();
  dados gyrData = mpu.getGyroscope();

  Serial.print("Acceleration - X: ");
  Serial.print(accData.X);
  Serial.print(" Y: ");
  Serial.print(accData.Y);
  Serial.print(" Z: ");
  Serial.println(accData.Z);

  Serial.print("Gyroscope - X: ");
  Serial.print(gyrData.X);
  Serial.print(" Y: ");
  Serial.print(gyrData.Y);
  Serial.print(" Z: ");
  Serial.println(gyrData.Z);
}
