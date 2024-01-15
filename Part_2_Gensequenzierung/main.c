/**
 * @file main.c
 * @author Bastian Johannes Roth
 * @brief Das Programm dient dazu um aus einer gegebenen Gensequenz eine spezielle Gensequenz herauszusuchen, welche vom Benutzer eingegeben wird.
 * @version 1.0
 * @date 2023-06-14
 * 
 * @copyright Copyright (c) 2023
 * 
 */
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_UNKODIERT 3000 // maximale Anzahl von unkodierten Basen
#define MAX_KODIERT 1000 // maximale Anzahl von kodierten Basen
#define MAX_GENOM 1000 // maximale Anzahl von kodierten Basen, welche aus einer Datei eingelesen werden kînnen

enum DNABase
{
	A = 'A',
	C = 'C',
	G = 'G',
	T = 'T'
};

/**
 * @brief Funktion die nur die Tasteneingaben a,A,c,C,g,G,t,T und 'ENTER' zulÑsst, auf dem Bildschirm werden nur A C G T ausgegeben, nichts anderes
 *
 * @return char returned den eingegebenen Character
 */
char getDNABase(void)
{
	int eingabe_ASCII, breaker_var = 0; // Variablen fÅr die getch()-Eingabe und die Variable zum beenden der Schleife
	char ausgabe;
	while (breaker_var == 0)
	{
		eingabe_ASCII = getch();						// Eingabe durch den Benutzer und umwandeln in ASCII-Wert
		if (eingabe_ASCII == 65 || eingabe_ASCII == 97) // Vergleich des ASCII-Werts, hier fÅr 'a' und 'A'
		{
			putchar(65); // Ausgabe des Chars in der Konsole
			return 'A';	 // Ausgabe der Funktion in Form des korrekten chars
		}
		if (eingabe_ASCII == 67 || eingabe_ASCII == 99) // Fall Eingabe = 'c' oder 'C'
		{
			putchar(67);
			return 'C';
		}
		if (eingabe_ASCII == 71 || eingabe_ASCII == 103) // Fall Eingabe = 'g' oder 'G'
		{
			putchar(71);
			return 'G';
		}
		if (eingabe_ASCII == 84 || eingabe_ASCII == 116) // Fall Eingabe = 't' oder 'T'
		{
			putchar(84);
			return 'T';
		}
		if (eingabe_ASCII == 10 || eingabe_ASCII == 13) // Fall Eingabe = 13 oder 10
		{
			return '\n';
		}
		else
		{
			breaker_var = 0;
			putchar(7);
		}
	}
	return 0;
}
/**
 * @brief Die Funktion liest Basen vom Benutzer ein und speichert sie in einem Array ab, dabei muss die Gesamtanzahl durch 3 teilbar sein, aufgrund von den Triplets
 *
 * @param seq Eingabe eines Char-Arrays zur Speicherung von DNA-Basen-Kombinationen
 * @return int Char-Array mit den gespeicherten Basen, durch 3 teilbar
 */
int getDNASequence(char seq[])
{
	int counter = 0;
	int breaker = 1;  // Breaker Variable zum beenden der While-Schleife,
	int position = 0; // Positions-Variable zum Navigieren im char-Array
	char eingabe;	  // Eingabe durch getDNABase()
	while (1)
	{
		eingabe = getDNABase();

		if (eingabe == '\n' && counter % 3 == 0)
		{
			return counter;
			break;
		}
		else if (eingabe == 'A' || eingabe == 'C' || eingabe == 'G' || eingabe == 'T')
		{
			seq[position] = eingabe;
			counter++;
			position++;
		}
	}
	return 0;
}

/**
 * @brief Funktion verschlÅsselt ein Codon mit Bits, Bsp: Leerer unsigned char: 00 00 00 00 = "AGT" = 00 11 10 00
 *
 * @param seq öbergabe eines Codon-Strings
 * @return unsigned char Ausgabe des verschlÅsselten Char
 */
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
	// 0 (00 00 00 00) -> 0  (00 00 00 00) -> 0  (00 00 00 00) -> bit_A
	// 1 (00 00 00 01) -> 4  (00 00 01 00) -> 16 (00 01 00 00) -> bit_C
	// 2 (00 00 00 10) -> 8  (00 00 10 00) -> 32 (00 10 00 00) -> bit_G
	// 3 (00 00 00 11) -> 12 (00 00 11 00) -> 48 (00 11 00 00) -> bit_T

	// ALSO: Ich muss nach jeder Iteration 2 Bits nach links shiften, wenn eine For-Schleife benutzt wird
	// Eigentlich nur *4 immer die Bits, aber Bit-Shiften zum Ausprobieren, da wir ja auch den char in Bits manipulieren
	// Zahlen kann man nicht binÑr angeben, schade :( (Compiler sagt nein)

	return ausgabe;
}
/**
 * @brief Die Funktion liest ein Basentriplet ein und Åbergibt es.
 * 
 * @param fp File-Pointer der auf die richtige Datei zeigt
 * @return unsigned char 
 */
unsigned char readCodon(FILE *fp)
{
	char einlesen;
	fscanf(fp, "%s", &einlesen);
	return einlesen;
}
/**
 * @brief Funktion dient dazu ein Array mit einer beliebigen Zahl zu fÅllen
 *
 * @param array Array welches Åbergeben wird
 * @param n Anzahl der Elemente im Array
 */
void arrayFuellen(char array[], int n)
{
	for (int i = 0; i < n; i++)
	{
		array[i] = 64;
	}
}
/**
 * @brief Die Funktion durchsucht eine Datei, in der kodierte Gene abgespeichert sind, nach einer eingegeben Gen-Sequenz, welche auch kodiert wird.
 *
 * @return int
 */
int main(void)
{
	char genom[MAX_GENOM] = {0};
	char suchGen[MAX_UNKODIERT] = {0};
	char genKodiert[MAX_KODIERT] = {0};
	arrayFuellen(genom, MAX_GENOM);
	arrayFuellen(suchGen, MAX_UNKODIERT);
	arrayFuellen(genKodiert, MAX_KODIERT);
	// char* genom;
	// char* suchGen;
	// char* genKodiert;
	// genom = malloc(3000*sizeof(unsigned char));
	// suchGen = malloc(3000*sizeof(unsigned char));
	// genKodiert = malloc(1000*sizeof(unsigned char));

	FILE *fp;
	fp = fopen("C:\\UNI\\Informatik_2\\Informatik_Praktikum\\BMC_C\\Informatik_II\\genom.txt", "rb");

	printf("Geben Sie die DNA-Sequenz des Gens ein: ");

	// getDNASequence(suchGen);
	int anzahlBasen = getDNASequence(suchGen);
	int index_genKodiert = 0;

	for (int i = 0; i < anzahlBasen; i += 3, index_genKodiert++)
	{
		char tmp[3] = {suchGen[i], suchGen[i + 1], suchGen[i + 2]};
		genKodiert[index_genKodiert] = encode(tmp);
	}

	int lenGenKodiertInt = /*strlen(genKodiert);*/ index_genKodiert;

	fread(genom, sizeof(int), MAX_GENOM, fp);

	int gefunden = 0;
	if (gefunden == 0)
	{
		for (int i = 0; i < MAX_GENOM && !gefunden; i++)
		{
			if (genom[i] == genKodiert[0])
			{
				for (int k = 0; k < lenGenKodiertInt; k++)
				{
					if (genom[i] != genKodiert[k])
					{
						break;
					}
					else
					{
						i++;
						if (k == lenGenKodiertInt - 1)
						{
							// Wenn es das letzte kodierte Codon ist, das auch Åbereinstimmt,
							// dann ist das Gen gefunden
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