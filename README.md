# Osciloscopio 
Proyecto para conectar un circuito arduino con un módulo HM10 a un smartphone iPhone con iOS 9/10

Se incluye programa en Arduino, circuito arduino y APP iOS.

Para operar al circuito Arduino se debe alimentar en los pines analógicos A0-A5 con señales de hasta 5 volts.

El circuito de ejemplo tiene 5 potenciómetros que permiten simular la señal. Un circuito real no debería tener potenciómetros, solo la alimentación en A0-A4

Contamos con un switch que permite cambiar entre señales reales y simuladas


# APP IOS

Esta es una app iOS 9/10 que permite comunicar con un Módulo Bluetooth UART HM10 (o HM11 o similar).

Este módulo deberá enviar strings con hasta 4 números enteros entre 0 y 1024 que serán graficados en 4 series diferentes en la APP

Ejemplos: 

132 123 182 190

432 892 123 123

La escala de la gráfica es 0 min y 1024 max

