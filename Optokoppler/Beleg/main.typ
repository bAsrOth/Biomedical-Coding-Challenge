#import "template.typ": *

#let codeRect(body) = {
  align(center)[#rect(fill: luma(242), width: 15cm)[#align(left)[#body]]]
}

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: [BMC-Challenge Teil 4 \ #text(size: 12pt)[Hardwarenahe Programmierung eines Mikrocontrollers]],
  authors: (
    "Bastian Johannes Roth",
  ),
  date: "15.12.2023",
)

= Einführung
Im dritten Teil der Biomedical Computing Challenge soll eine Zeichenkette zwischen zwei Arduinos übertragen werden. Dabei sollen eine LED und eine Photodiode als Datenübetragungsstrecke verwendet werden, auch bekannt als *Optokoppler*.
= Verschaltung Photodiode und LED <Schaltung>
In meiner Schaltung verwende ich eine LED, einen $330 ohm$ Widerstand und eine Photodiode, dazu noch einen Arduino Uno R4 WIFI und einen Arduino Uno R3. Der R4 dient hierbei als Empfänger und der R3 ist der Sender der Zeichenkette. 

Zum Senden der Bits auf dem R3 wird die LED mit dem Widerstand R1 auf dem Digital-Pin 2 verwendet.

Zum Empfangen auf dem R4 wird die Photodiode D1 in Sperrichtung mit dem Digital-Pin 2 verschalten. Dieser wird in der Software als Input-Pin konfiguriert und noch zusätzlich mit dem Pullup-Widerstand R2 verbunden<Pullup>. Der Digital-Pin liest also permanent auf seinem Eingang ein Pegel von 5V. Wenn D1 nun mit Licht angestrahlt wird, so wird der Pin auf Masse gezogen und es liegen 0V an, also Low. 

Pin 10 und Pin 11 am  R3 sind auch in der Software als virtuelle UART-Pins konfiguriert. Es findet nur eine kurze Datenübertragung zum synchronen Starten statt. Zudem sind beide Arduinos über Masse verbunden. 
#figure(caption: "Schaltung", image("Schaltung.svg", width: 50%))
#pagebreak()
= Code des Senders
#codeRect(```C
#include <stdint.h>          // Library für bessere Darstellung der Datentypen
#include <SoftwareSerial.h>  // Library für Erstellung der Virtuellen UART Pins

#define PIN_02  2   // Pin für die LED 
#define PIN_RX  10  // UART RX Pin zum Empfangen
#define PIN_TX  11  // UART TX Pin zum Senden
#define T_BIT   1   // Zeit in ms, die ein Bit zum Übertragen benötigt

SoftwareSerial virtualSerial(PIN_RX, PIN_TX);

uint8_t i, k;
uint8_t teststring[] = "   BMC-Challenge 2023: Light-fast data transfer made easy";

```)
Am Anfang der Datei werden die Bibliotheken inkludiert, welche für die Datentypen  und die virtuellen UART-Pins benötigt werden. Danach die Konstanten durch Makros definiert, welche dann durch den Präprozessor in den Code eingefügt werden. Pin 10 und 11 werden als RX und TX Pins konfiguriert, für die Kommunikation per UART. Die vorbestimmter Zeichenkette wird als 8-Bit Array definiert, mit 3 führenden Leerstellen, die als Puffer dienen sollen, da die Kommunikation  nicht direkt synchron startet. Die zwei Hilfsvariablen ```C i``` und ```C k``` werden auch deklariert.

#codeRect(```C
void setup() {
  Serial.begin(9600);         // Starten der Kommunikation mit dem PC
  virtualSerial.begin(9600);  // Starten der Kommunikation mit Arduino 2
  pinMode(PIN_02, OUTPUT);    // Pin-Konfig
}
```)
In der Setup-Funktion wird die serielle Kommunikation gestartet und mit einer Baudrate von $9600$ Bit/s gestartet. Der Digital Pin 2 wird auch als Ausgabe-Pin konfiguriert.
#codeRect(```C
void loop() {
  if (Serial.read() == 's') {    // Warten auf Benutzereingabe
    virtualSerial.println('s');  // Senden an Arduino 2
    Serial.println("Start der Übertragung:");
```)
In der Schleifenfunktion wird zuerst auf den Benutzer gewartet. Wenn ein 's' am Serial Monitor eingetippt wird und mit der Eingabetaste an den Arduino gesendet wird, wird über UART das Zeichen an den anderen Arduino gesendet und die Kommunikation startet. Der Benutzer wird auch auf seinem Bildschirm über den Start der Übertragung informiert.
#codeRect(
```C
    for (i = 0; i < 57; i++) {
      digitalWrite(PIN_02, LOW);
      delay(T_BIT);
      for (k = 0; k < 8; k++) { 
        if (bitRead(teststring[i], k)) {
          digitalWrite(PIN_02, HIGH); 
        } else {
          digitalWrite(PIN_02, LOW);
        }
        delay(T_BIT);      
      }
      digitalWrite(PIN_02, HIGH);
      delay(T_BIT);
```) 
Für die Datenübertragung habe ich mich am UART Protokoll orientiert, mit einem *Startbit*, *8 Datenbits* und *einem Stoppbit*. $t_("Frame")$ ist $10$ms und $t_("bit")$ ist $1$ ms.  
#figure(caption: [Frame von UART #footnote("Grafik aus dem Skript Mikrocomputertechnik bei Prof. Dr. Spindler")], image("Frame.png", width: 50%))
Die ```C for```-Schleife startet am ersten Zeichen des Arrays, die LED wird ausgeschalten, das Startbit wird gesendet. Danach startet die nächste ```C for```-Schleife. Die einzelnen Bits der Zahlen im Array werden nun mithilfe eines Makros ausgelesen. Die zu untersuchende Zahl wird um $k$ Bits nach links geschoben: ```C zahl >> k```, danach wird die Zahl noch mit 1 verundet. Steht auf dem Bit eine 1, so sind ```C 1 & 1``` = 1, steht auf dem Bit eine 0, sind ```C 0 & 1``` = 0. Bei einer 1 wird Pin 2 auf High geschalten und die LED leuchtet. Bei 0 wird er auf Masse geschalten und die LED bleibt aus. Nach jedem Vergleich und Schalten wird 1 ms gewartet. Nach 8 Wiederholungen, für 8 Bits, wird der Pin 2 wieder auf High geschalten und so das Stoppbit gesendet. 
#codeRect(
```C
      if (i > 2) {
        Serial.print(char(teststring[i]));
      }
    }
    digitalWrite(PIN_02, LOW);
  }
}
```
)
Danach wird auch noch das Zeichen aus der Zeichenkette am Serial Monitor ausgegeben. Hier wird erst beim 3 Zeichen angefangen, da die ersten 3 Puffer sind und keine Bedeutung haben.
= Code des Empfängers
#codeRect(
  ```C
#include <stdint.h>

#define PIN_02 2    // Input Pin für Photodiode
#define T_BIT 1     // Zeit in ms, die ein Bit gelesen wird

uint8_t inputString[58] = {0};  // Char Array zum Speichern der Eingabe
uint8_t i, k;
```
)
Der Anfang beider Dateien ähnelt sich stark, es werden wieder die benötigten Makro definiert und ein leeres 8-Bit Array und 2 Hilfsvariablen erstellt. 
#codeRect(```C
void setup() {
  Serial.begin(9600);             // Starten der Kommunikation mit dem PC
  Serial1.begin(9600);            // Starten der Kommunikation mit Arduino 2
  pinMode(PIN_02, INPUT_PULLUP); 
}
```)
Die Kommunikation mit dem PC wird auch vom zweiten Arduino aus gestartet und die mit dem anderen Arduino, die Baudrates sind exakt gleich. Der Digital-Pin 2 wird aus ```C INPUT_PULLUP``` konfiguriert, wie bereits in @Schaltung erläutert. 

#codeRect(```C
void loop() {
  while (Serial1.available() >= 0) {
    uint8_t receivedData = Serial1.read();
    if (receivedData == 's') {
      Serial.println("Start des Empfangens:");
      for (i = 0; i < 55; i++) {
        if (digitalRead(PIN_02)){
          delay(T_BIT);
        }
        for (k = 0; k < 8; k++) {
          if (!digitalRead(PIN_02)) {
            bitSet(inputString[i], k);
          }
          else {
            bitClear(inputString[i], k);
          }
          delay(T_BIT);
        }
        do {
          
        } while(!digitalRead(PIN_02));
        if (i > 0) {
          Serial.print(char(inputString[i]));
        }
      }
    }
  }
}

```)
Der Arduino wartet zuerst auf das Startzeichen seines Senders. Nach dem Empfangen ist wartet der Arduino 1 ms und fängt dann an in der zweiten ```C for```-Schleife an die 8 Datenbits einzulesen. Wenn am Pin #sym.tilde 0V anliegen, dann hat die Diode den Pin auf Masse gezogen und ```C digitalRead(PIN_02)``` liefert LOW, bzw. 0. Der Code achtet nur auf ein Low am Pin, dann wird das entsprechende Bit gesetzt. Bei einer HIGH, bzw. einer 1 wird das Bit auf 0 gesetzt. Anfangs sind die Bits zwar eh alle auf 0 gesetzt, aber wenn man nun ein Array verwendet, welches bereits beschrieben wurde, aus dem EEPROM#footnote([https://docs.arduino.cc/tutorials/uno-r4-wifi/eeprom]) des R4 zum Beispiel, dann überschreibt der Code vollständig die alten Zustände. Nach den Datenbits erfolgt ein Polling mit der ```C do{} while(!digitalRead(PIN_02))```-Schleife. Beim Polling wartet der R4 auf den fallenden Flankenwechsel, von Stopp- auf Startbit. 
Danach wird das Zeichen über den Serial-Monitor auf dem Computer ausgegeben. Wobei man erst beim zweiten Zeichen anfängt, durch den Puffer. 
Nach 54 Iterationen startet die ```C loop()```-Funktion erneut und wartet auf das Startzeichen.
#pagebreak()
= Anhang
#figure(caption: "Aufbau mit Breadboard", image("DSC00123.JPG"))
#figure(caption: "Bildschirmaufnahme", image("Beweis.png"))