#import "template.typ": *

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Biomedical Coding Challenge Teil 2",
  authors: (
    "Bastian Johannes Roth",
  ),
)
#set heading(numbering: "1.")

#let ce(body) = {
  align(center)[#body]
}

#let re(body) = {
  align(right)[#body]
}
#let li(body) = {
  align(left)[#body]
}

#v(1fr)
#ce[#text(size: 16pt)[*Abstrakt*]]
Die *Biomedical-Coding-Challenge* dient dazu um motivierte Studenten an das Programmieren mit unterschiedlichen Sprachen heranzuleiten und gleichzeitig interessante Themen der Medizintechnik zu untersuchen. In Zusammenarbeit mit der Firma Brainlab aus München werden Studenten vom ersten Semester an mit verschiedenen Aufgaben gefordert. Über das Semester haben wir Studenten dann Zeit die Aufgaben zu lösen und so zur nächsten Challenge weiter zu schreiten.\
Im zweiten Semester ist es die Aufgabe der Studenten ein C-Programm mit Hilfestellung von Prof. Dr. Koller zu entwickeln, welches schädliche DNA-Sequenzen aus genetischen Code finden kann. Dabei wird die Verständnis von Ein- und Ausgabe durch Benutzer, das Speichern von Eingaben und deren Weiterverarbeitung, die Verschlüsselung von Daten, Speicheroptimierung und das Verarbeiten von Dateien gefordert.\
Mithilfe von Moodle und einem Compiler werden die einzelnen Funktionen getestet und so kann von Funktion zu Funktion geschritten werden.
#v(1fr)
#pagebreak()
= Funktion: Benutzereingaben
DNA-Sequenzen bestehen immer aus den 4 DNA-Basen *Adenin*, *Guanin*}, *Cytosin* und *Thymin*. (Im Folgenden A, C, G, T). Nun soll eine Funktion erstellt werden die nur die Eingaben der Buchstaben "A", "C", "G", "T" und der Eingabetaste zulässt. Zu beachten ist, ist das der Benutzer ein kleines "c" und ein großes "C" eingeben kann, es beides aber als die gleiche Eingabe gewertet werden soll. Über die `getch()`-Funktion wird eine einzelne Benutzereingabe gelesen, in der Variable `char ausgabe` gespeichert. Im Folgenden wird dann die Eingabe mit den verschiedenen erlaubten Zuständen verglichen. Bei gültiger Eingabe wird das Zeichen auf dem Bildschirm ausgegeben und der richtige `char` returned. Bei ungültiger Eingabe wird über das ASCII Zeichen 7 ein Ton auf dem Computer ausgegeben und nichts erscheint auf dem Bildschirm. Ein Druck der Eingabetaste wird dann als ASCII 10 returned, allerdings nicht auf dem Bildschirm. 
#ce[#rect(width: 15cm,fill: luma(240))[#li[
```cpp
char getDNABase(void){
    int eingabe_ASCII, breaker_var = 0;
    char ausgabe;
    while (breaker_var == 0)
        {
            eingabe_ASCII = getch();                        
            if (eingabe_ASCII == 65 || eingabe_ASCII == 97) 
                {
                    breaker_var = 1;
                    putchar(65);     
                    return 'A';      
                }
            if (eingabe_ASCII == 67 || eingabe_ASCII == 99)
                {...}
            if (eingabe_ASCII == 71 || eingabe_ASCII == 103)
                {...}
            if (eingabe_ASCII == 84 || eingabe_ASCII == 116)
                {...}
            if (eingabe_ASCII == 10 || eingabe_ASCII == 13)
                {
                    breaker_var = 1;
                    return '\n';
                }
            else
                {
                    breaker_var = 0;  putchar(7);
                } }
            return 0;
        }
```
]]]

= Funktion: Basen einlesen
In der darauf folgenden Funktion soll der Benutzer nun Basen über die Tastatur mit der Funktion `getDNABase()` eingeben. Da Basen immer als Codons (3 Basen $=$ 1 Codon) auftreten. Als Übergabeparameter soll die Funktion eine Zeichenkette `char seq[]` bekommen und dann die Basen in diese speichern. Als Returnwert soll die Funktion die Anzahl der erfolgreich abgespeicherten Basen `int counter` wiedergeben. Dabei dürfen keine falschen Eingaben gespeichert werden und auch das Drücken der Eingabetaste soll nicht mehr in die Zeichenkette. Die Gesamtlänge der Funktion muss immer durch 3 vollständig teilbar sein. Hier wird das mit der `int counter` Variable überprüft. Sollte die Eingabetaste gedrückt werden, dann wird mit dem Modulo-Operator überprüft ob, die Länge der Zeichenkette ein Vielfaches von 3 ist. Treffen beide Fälle zu, dann wird die Anzahl der erfolgreich abgespeicherten Basen ausgegeben. 
#ce[#rect(width: 15cm,fill: luma(240))[#li[
```cpp
int getDNASequence(char seq[])
    {
        int counter = 0, position = 0;
        char eingabe;
        while (1)
        {
            eingabe = getDNABase();
        
            if (eingabe == '\n' && counter % 3 == 0)
            {
                return counter;
                break;
            }
            else if (eingabe == 'A' || eingabe == 'C' || eingabe == 'G' || eingabe ==
            'T')
            {
                seq[position] = eingabe;
                counter++;
                position++;
            }
        }
        return 0;
    }
```
]]]

= Funktion: Verschlüsselung
Um möglichst wenig Speicher zu verbrauchen soll ein Codon nun verschlüsselt werden. Es gibt 4 mögliche Zustände für die Basen in einem Codon, daher ergeben sich $4 dot 4 dot 4=64$ mögliche Codon-Kombinationen. Die einzlenen Basen werden werden mit den folgenden Bits verschlüsselt:
#ce[#grid(columns: (auto, auto, auto, auto),column-gutter: 10mm, [#ce[*Adenin*: `00`]],[#ce[*Cytosin*: `01`]],[#ce[*Guanin*: `10`]],[#ce[*Tyhmin*: `11`]])]
Ein Variable des Typ `unsigned char` hat eine Speicherbreite von 1 Byte, d.h. 8 Bits. Die Idee ist jetzt auf den Bitpaaren die Basen zu speichern. 
#ce[#grid(columns: (auto, auto, auto, auto,auto, auto, auto, auto),column-gutter: 1mm,row-gutter: 1mm, [*8*],[*7*],[*6*],[*5*],[*4*],[*3*],[*2*],[*1*],
[`0`],[`0`],[`0`],[`0`],[`0`],[`0`],[`0`],[`0`])]
Auf den ersten beiden Bits wird die erste Base des Codons gespeichert, als Beispiel jetzt das Codon "AGT". Bits 1 und 2 Adenin, Bits 3 und 4 Guanin und Bits 5 und 6 Thymin.
#ce[#grid(columns: (auto, auto, auto, auto), column-gutter: 2mm, row-gutter: 1mm,
[#ce[]],[#ce[T]],[#ce[G]],[#ce[A]],
[`00`],[`11`],[`10`],[`00`])]
So wird ein Codon, was eigentlich aus 3 `char` besteht mit einem einzigen `char` dargestellt. Die Funktion vergleicht dann die Base der übergebenen Zeichenkette mit den 4 möglichen Basen in einer `switch`-Funktion. Trifft ein `case` zu, dann werden die entsprechenden Bits des `unsigned char` auf den Bitwert der Base gesetzt. Nach dem Setzen der Bits, werden die Bits mithilfe von Bitshifting um zwei Stellen nach Links geschoben. Bitshift mit `int bit_T = bit_T << 2`
#ce[#grid(columns: (auto,auto),column-gutter: 4mm, row-gutter: 2mm,[`int Bit_T`],[`00 00 00 11`],[],[#rotate(sym.arrow, 90deg)],
[`int Bit_T`],[`00 00 11 00`])]
#ce[#rect(width: 15cm,fill: luma(240))[#li[
  ```cpp
unsigned char encode(char seq[])
{
  	int bit_A = 0;
  	int bit_C = 1;
  	int bit_G = 2;
  	int bit_T = 3;
  	unsigned char ausgabe = 0;

  	for (int i = 0; i < 3; i++)
  {
    		switch (seq[i])
    		{
    		case A:
        			ausgabe |= bit_A;
        			break;
    		case C:
        			ausgabe |= bit_C;
        			break;
    		case G:
        ausgabe |= bit_G;
        break;
    		case T:
        			ausgabe |= bit_T;
        			break;
    		}
    		bit_A = bit_A << 2;
    		bit_C = bit_C << 2;
    		bit_G = bit_G << 2;
    		bit_T = bit_T << 2;
    	}
  return ausgabe;
}
```
]]]

= Funktion: Main-Funktion
Die Main-Funktion vereint nun alle Funktionen des Programms. Der Benutzer soll nun Basen eingeben, die in der Beispieldatei `genom.dat` suchen will. Die Eingabe wird mit der Eingabetaste beendet, wenn die Anzahl der eingegeben Basen durch 3 teilbar ist. In der Beispieldatei liegen die Basen bereits verschlüsselt als `char` vor. Die eingegeben Basen werden nun verschlüsselt, indem immer 3 Basen in ein Temp-Array geschrieben werden und dies an die Funktion `encode` überreicht wird. Danach erhält man ein Array, welches nur noch ein Drittel des eigentlichen Speichers einnimmt. Nun werden die beiden Arrays (Such-Array und das Genom-Array) verglichen. Wenn die erste Base des Such-Arrays übereinstimmt, dann wird an der Stelle im Genom-Array weiter mit dem Such-Array verglichen. Ist das nicht der Fall wird einfach weiter durch das Genom-Array iteriert. Falls eine Übereinstimmung gefunden wurde, dann wird ab dieser Stelle weiter verglichen, bis entweder alle Elemente des Such-Arrays mit der Folge in dem Genom-Array übereinstimmen oder ein Unterschied auftaucht. Wenn alle übereinstimmen, dann wird die Variable `gefunden` auf 1 gesetzt. Wenn `gefunden` 1 ist, so wurde der Genabschnitt gefunden und es wird dem Benutzer ausgegeben.
#ce[#rect(width: 15cm,fill: luma(240))[#li[
  ```cpp
int main(void)
{
    char* genom;
    char* suchGen;
    char* genKodiert;
    genom = malloc(3000*sizeof(unsigned char));
    suchGen = malloc(3000*sizeof(unsigned char));
    genKodiert = malloc(1000*sizeof(unsigned char));
    FILE *fp;
    fp = open("genom.dat", "rb");
    printf("Geben Sie die DNA-Sequenz des Gens ein: ");
    getDNASequence(suchGen);
    int anzahlBasen = strlen(suchGen);
    int index_genKodiert = 0;
    
    for (int i = 0; i < anzahlBasen; i += 3, index_genKodiert++)
    {
        char tmp[3] = {suchGen[i], suchGen[i + 1], suchGen[i + 2]};
        genKodiert[index_genKodiert] = encode(tmp);
    }

    int lenGenKodiertInt = strlen(genKodiert);
    fread(genom, sizeof(int), MAX_GENOM, fp);
    int gefunden = 0;
    if (gefunden == 0){
        for (int i = 0; i < MAX_GENOM && !gefunden; i++)
        {
            if (genom[i] == genKodiert[0])
            {
                for (int k = 0; k < lenGenKodiertInt; k++)
                {
                    if (genom[i] != genKodiert[k]){
                        break;
                    }
                    else
                    {
                        i++;
                        if (k == lenGenKodiertInt-1){
                            gefunden = 1;
                        }
                    }
                }
            }
        }
    }
    if (gefunden == 1)
    {
        printf("-Gen gefunden!");
    }
    else
    {
        printf("-Gen nicht gefunden!");
    }
    getch();
    return 0;
}
```
]]]
