/**
 * @file Empfänger.ino
 * @author Bastian Johannes Roth
 * @brief Code für einen Arduino Uno R4 Wifi, der Zeichen über Licht mit einer Photodiode empfangen kann
 * @version 1.0
 * @date 2023-12-16
 *
 */
#include <stdint.h>

#define PIN_02 2  // Input Pin für Photodiode
#define PIN_RX 10 // UART RX Pin zum Empfangen
#define PIN_TX 11 // UART TX Pin zum Senden
#define T_BIT 1   // Zeit in ms, in der ein Bit gesendet wird

uint8_t inputString[58] = {0}; // Char Array zum Speichern der Eingabe

uint8_t i, k; // Hilfsvariablen

/**
 * @brief Starten der Seriellen Kommunikation und Konfiguration der Pins
 *
 */
void setup()
{
  Serial.begin(9600);            // Starten der Kommunikation mit dem PC
  Serial1.begin(9600);           // Starten der Kommunikation mit Arduino 1
  pinMode(PIN_02, INPUT_PULLUP); // Konfig des Digitalen Pins 2 und Verbinden mit Pullup 20k onboard, ist jetzt immer HIGH
}
/**
 * @brief Einlesen der Empfangenen Bits und Ausgabe an PC
 *
 */
void loop()
{
  while (Serial1.available() >= 0)
  {
    uint8_t receivedData = Serial1.read(); // Einlesen des Startzeichens
    if (receivedData == 's') // Überprüfen des Startzeichens
    { 
      Serial.println("Start des Empfangens:");
      for (i = 0; i < 55; i++) // Start der Array-for-Schleife
      { 
        if (digitalRead(PIN_02)) // Einlesen Startbit
        { 
          delay(T_BIT);
        }
        for (k = 0; k < 8; k++) // Start der Einzel-Zeichen-for-Schleife
        { 
          if (!digitalRead(PIN_02)) // Überprüfen auf 1 oder 0
          {                            
            bitSet(inputString[i], k); // Schreiben des Bits
          }
          else
          {
            bitClear(inputString[i], k);
          }
          delay(T_BIT);
        }
        do
        {

        } while (!digitalRead(PIN_02)); // Polling bis Flankenwechsel
        if (i > 0)
        {
          Serial.print(char(inputString[i])); // Ausgabe des Zeichens am PC
        }
      }
    }
  }
}
