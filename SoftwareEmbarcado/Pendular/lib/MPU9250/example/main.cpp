#include <SoftwareWire.h>
#include <MPU9250.h>

/*
 A estrutura "dados" foi criada na lib MPU9250
 é usada para armazenar os valores de aceleração, giroscópio e magnetômetro nos eixos X, Y e Z.
 Cada campo da estrutura representa a leitura de 16 bits de um eixo específico.
 E tem o seguinte formato:
*/
struct Dados
{
  int16_t X;
  int16_t Y;
  int16_t Z;
};


/*
Este codigo demonstra como usar a biblioteca "MPU9250" para obter os valores de aceleração e giroscópio do sensor MPU9250 e exibi-los no monitor serial.

Funcionamento:
1. O código inclui a biblioteca "MPU9250.h" e cria um objeto da classe "MPU9250".
2. A função "setup()" é chamada para iniciar a comunicação serial e inicializar o sensor.
3. No loop principal, a função "readData()" é chamada para ler os valores de aceleração, giroscópio e magnetometro do sensor.
4. Os valores lidos são armazenados em variáveis e exibidos no monitor serial.
5. O loop se repete continuamente para obter e exibir os valores atualizados.
*/



MPU9250 mpu;

void setup()
{
  Serial.begin(9600);
  mpu.begin();
}

void loop()
{
  mpu.readData();
  Dados accData = mpu.getAcceleration();
  Dados gyrData = mpu.getGyroscope();
  Dados magData = mpu.getMagnetometer();

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

  Serial.print("Magnetometer - X: ");
  Serial.print(magData.X);
  Serial.print(" Y: ");
  Serial.print(magData.Y);
  Serial.print(" Z: ");
  Serial.println(magData.Z);
}
