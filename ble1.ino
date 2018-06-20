#include <SoftwareSerial.h>

// Creamos una instancia de comunicación serial Bluetooth con los pines de comunicación en el shield Bluetooth
SoftwareSerial ble(2, 3); // RX, TX

// variables para convertir a char los datos a enviar
String str;
char cstr[20];

// variables numéricas que enviaremos
int valor1=0;
int valor2=0;
int valor3=0;
int valor4=0;

int senal1=0;
int senal2=0;
int senal3=0;
int senal4=0;
int senal5=0;

// contador de ciclos para generador de pulsos
int cuenta=0;

// variables de control para funciones trigonométricas sin, cos
float x1=0;
float x2=0;
const float pi=3.14;
float v1=0;
float v2=0;

// inicializamos el Arduino
void setup() {
  // Abrimos puerto serial a 9600 bauds
  Serial.begin(9600);
  
  // Inicializamos bluetooth y su comunicación serial a 9600 bauds
  ble.begin(9600);
}

// Ahora el loop
void loop() {
  /* 
   Leemos los pines analógicos del Arduino
   En ellos podemos conectar cualquier voltaje entre 0 y 5 voltios
   Estas señales son las que se graficaran en el Osciloscopio
  */

  int modo=analogRead(A15); // leamos el pin15, si está cerrado entonces simularemos las señales, de lo contrario serán reales

  if(modo>1000) // simularemos las señales
  {
    senal1=analogRead(A0);
    senal2=analogRead(A1);
    senal3=analogRead(A2);
    senal4=analogRead(A3);
    senal5=analogRead(A4);
  
    /*
     * Las siguientes líneas simulan sinusoidales 
     */
    v1=x1*pi/180; // convertimos grados a radianes
    x1=x1+senal2/20; // incrementamos el ángulo en función del potenciómetro 2
  
    v2=x2*pi/180; // convertimos grados a radianes
    x2=x2+senal4/20; // incrementamos el ángulo en función del potenciómetro 4
  
    // Simularemos señales sin y cos
    valor1=sin(v1)*senal1;   // calculamos seno
    valor2=cos(v2)*senal3;   // calculamos coseno
  
    valor3=senal5;
    
    //  Simulamos un pulso
    if(cuenta==3)
    {
      if(valor4==-800)
        valor4=800;
      else valor4=-800;
      cuenta=0;
    }
    cuenta++;
  }
  else // no simulado
  {
    valor1=analogRead(A0);
    valor2=analogRead(A1);
    valor3=analogRead(A2);
    valor4=analogRead(A3);
  }

  // Metemos a un string los 4 valores a enviar por Bluetooth
  str = String(valor1)+' '+String(valor2)+' '+String(valor3)+' '+String(valor4);
  // convertimos el string a char
  str.toCharArray(cstr,20);
  // enviamos el char a Bluetooth
  ble.write(cstr);

  // esperamos 10 milisegundos
  delay(10);
  
}
