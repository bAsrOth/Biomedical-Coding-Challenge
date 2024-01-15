/**
 * @file Sender.ino
 * @author Bastian Johannes Roth
 * @brief Code für einen Arduino Uno R3, der
 * @version 0.1
 * @date 2023-12-16
 *
 */
#include <stdint.h>         //Library für bessere Darstellung der Datentypen
#include <SoftwareSerial.h> // Library für Erstellung der Virtuellen UART Pins

#define PIN_02 2  // Pin für die LED zur Lichtaussendung
#define PIN_RX 10 // UART RX Pin zum Empfangen
#define PIN_TX 11 // UART TX Pin zum Senden
#define T_BIT 1   // Zeit, die ein Bit zum Übertragen hat

SoftwareSerial virtualSerial(PIN_RX, PIN_TX); // Konfiguration der Digitalen Pins 10 und 11 als RX/TX Pins für UART Übertragung

uint8_t bit_k;                                                                      // Temp-Var
uint8_t teststring[] = "   BMC-Challenge 2023: Light-fast data transfer made easy"; // Char-Array mit Ausgabetext

/**
 * @brief Starten der Seriellen Kommunikation und Konfiguration der Pins
 * 
 */
void setup()
{
  Serial.begin(9600);        // Starten der Kommunikation mit dem PC
  virtualSerial.begin(9600); // Starten der Kommunikation mit Arduino 2
  pinMode(PIN_02, OUTPUT);   // Pin-Konfig
}

/**
 * @brief Senden der von 8 Datenbits, 1 Startbit und 1 Stoppbit
 *
 */
void loop()
{
  if (Serial.read() == 's')
  {                             // Warten auf Benutzereingabe
    virtualSerial.println('s'); // Senden an Arduino 2
    Serial.println("Start der Übertragung:");
    for (int i = 0; i < 57; i++)
    {
      digitalWrite(PIN_02, LOW); // Startbit auf low
      delay(T_BIT);
      for (int k = 0; k < 8; k++) // Durchlauf des Strings und dann der einzelnen Chars
      {
        if (bitRead(teststring[i], k) == 1)
        {
          digitalWrite(PIN_02, HIGH); // Umschalten der LED je nach Bit-Status
        }
        else
        {
          digitalWrite(PIN_02, LOW);
        }
        delay(T_BIT); // Zykluszeit als Delay
      }
      digitalWrite(PIN_02, HIGH); // Stoppbit auf High
      delay(T_BIT);

      if (i > 2)
      {
        Serial.print(char(teststring[i])); // Ausgabe an PC
      }
    }
    digitalWrite(PIN_02, LOW); // Nach vollem Durchlauf Pin wieder auf Low setzen
  }
}
