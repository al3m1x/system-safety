# AGENTS.md

Kontekst dla kolejnych etapow projektu z przedmiotu "Bezpieczenstwo systemow" / "Systemy Krytyczne (Safety-Critical Systems)".

## Projekt

Projekt dotyczy medycznego akceleratora liniowego LINAC stosowanego w radioterapii zewnetrznej.

Glowny opis systemu znajduje sie w:

- `main.typ` - zrodlo Typst etapu opisu systemu
- `main.pdf` - wygenerowany PDF
- `etap-0-radioterapia.pdf` - PDF etapu 0

Dokument analizy zagrozen znajduje sie w:

- `etap-1-analiza-zagrozen.typ`
- `etap-1-analiza-zagrozen.pdf`

Ilustracje uzywane w dokumentach:

- `linac-scheme.png`
- `LINAC.drawio.png`

## Sklad zespolu

Autorzy:

- Juliusz Radziszewski s193504
- Adrian Szwaczyk s193233
- Sebastian Kwasniak s188807
- Maciej Zuralski s193367

Zespol ma 4 osoby. Jesli instrukcja etapu wymaga liczby analiz zaleznej od liczby osob, przyjmuj wartosc 4.

## Definicja systemu

System LINAC sluzy do dostarczania precyzyjnej dawki promieniowania jonizujacego do obszaru guza pacjenta, z minimalizacja ekspozycji zdrowych tkanek. Jest to system safety-critical. Nieprawidlowa dawka, zla geometria wiazki, niepoprawne pozycjonowanie pacjenta lub nieskuteczne zatrzymanie awaryjne moga skutkowac ciezkimi obrazeniami albo smiercia.

Komponenty systemu przyjete w `main.typ`:

1. Komputer sterujacy
2. Baza danych pacjentow
3. Akcelerator liniowy
4. Detektor dawki promieniowania
5. Konsola operatora
6. Wylacznik awaryjny E-Stop
7. Blokada drzwi bunkra
8. Kamera monitorujaca
9. Kolimator MLC
10. Stol pacjenta
11. Silniki pozycjonujace

W opisie `main.typ` podano, ze system sklada sie z 12 komponentow, ale lista zawiera 11 pozycji. Przy kolejnych etapach zachowaj spojnosc z lista komponentow, a jesli etap wymaga precyzyjnej liczby komponentow, najpierw zweryfikuj i ewentualnie popraw opis systemu.

## Tryby pracy

Uwzgledniaj nastepujace tryby pracy:

- Idle Mode / tryb gotowosci
- Setup Mode / tryb pozycjonowania
- Treatment Mode / tryb terapeutyczny
- Calibration Mode / QA
- Emergency Mode / tryb awaryjny

W kolejnych analizach bierz pod uwage nie tylko normalna terapie, ale tez konfiguracje, kalibracje, QA, serwis i sytuacje awaryjne.

## Procedura radioterapii

Skrocony przeplyw:

1. Pacjent wchodzi do bunkra i kladzie sie na stole.
2. Elektroradiolog pozycjonuje pacjenta, stol i gantry.
3. Operator wychodzi, zamyka drzwi bunkra i aktywuje blokade drzwi.
4. Przy konsoli operator wczytuje plan pacjenta z bazy danych.
5. Komputer sterujacy konfiguruje MLC.
6. Operator wlacza wiazke przyciskiem Beam On.
7. Akcelerator emituje wiazke, a detektor dawki monitoruje dawke.
8. Operator obserwuje pacjenta przez kamere i moze uzyc E-Stop.
9. Po osiagnieciu dawki komputer wylacza wiazke.
10. Operator wchodzi do bunkra i pomaga pacjentowi zejsc ze stolu.

## Wyniki etapu 1

W etapie 1 przygotowano hazard analysis.

Zidentyfikowane hazardy:

- H-01 Nadmierna dawka promieniowania
- H-02 Zbyt niska dawka terapeutyczna
- H-03 Napromienienie niewlasciwego obszaru pacjenta
- H-04 Osoba znajduje sie w bunkrze podczas emisji wiazki
- H-05 Kolizja gantry lub stolu z pacjentem albo operatorem
- H-06 Nieprawidlowy ksztalt pola promieniowania
- H-07 Brak skutecznego monitorowania pacjenta podczas emisji
- H-08 Emisja wiazki w niewlasciwym trybie pracy
- H-09 Nieskuteczne zatrzymanie awaryjne
- H-10 Warunki srodowiskowe zaklocaja pomiar dawki
- H-11 Porazenie elektryczne personelu serwisowego
- H-12 Nieprawidlowa kalibracja detektora dawki
- H-13 Wczytanie niewlasciwego planu pacjenta
- H-14 Zanieczyszczenie biologiczne powierzchni stolu lub akcesoriow

Gleboka analiza FTA zostala wykonana dla:

- H-01
- H-03
- H-04
- H-05
- H-07
- H-08
- H-11
- H-13

Nie zmieniaj identyfikatorow hazardow bez wyraznej potrzeby, bo kolejne etapy powinny sie do nich odwolywac.

## Styl dokumentow

Dokumenty tworz w Typst.

Preferencje:

- jezyk dokumentow: polski
- pliki zrodlowe: `etap-N-opis.typ` albo nazwa odpowiadajaca instrukcji etapu
- pliki wynikowe: taka sama nazwa z rozszerzeniem `.pdf`
- format strony: A4
- czcionka: `New Computer Modern`
- numerowane naglowki: `#set heading(numbering: "1.1")`
- justowanie akapitow: `#set par(justify: true)`
- stopka z numerem strony
- naglowek pierwszej strony z autorami, zgodny ze stylem `main.typ`

Po utworzeniu lub zmianie dokumentu zawsze uruchom:

```sh
typst compile nazwa-dokumentu.typ nazwa-dokumentu.pdf
```

Jesli dokument jest szeroki tabelarycznie, sprawdz render do PNG:

```sh
typst compile nazwa-dokumentu.typ /tmp/check-{p}.png
```

Nastepnie obejrzyj przynajmniej strony z duzymi tabelami/diagramami.

## Zasady merytoryczne

Przy kolejnych etapach:

- odwolywac sie do komponentow i interfejsow z `main.typ`
- utrzymywac spojne nazwy hazardow i zdarzen z etapu 1
- uwzgledniac bledy sprzetowe, programowe, ludzkie, organizacyjne i srodowiskowe
- nie traktowac hazardu jako accident; hazard to niebezpieczna sytuacja, accident to skutek/scenariusz wypadkowy
- dla LINAC szczegolnie wazne sa: dawka, geometria wiazki, pozycjonowanie, blokady drzwi, E-Stop, MLC, detektor dawki, baza planow pacjentow i tryby QA/serwisowe
- jezeli instrukcja wymaga diagramow, mozna uzyc czytelnych diagramow tekstowych w Typst albo osobnych obrazow, ale PDF musi pozostac czytelny
- dodawac sekcje "Wykorzystanie AI", jezeli wymaga tego format projektu albo poprzednie dokumenty

## Uwagi techniczne

- Nie usuwaj `.DS_Store`, jesli nie jest to potrzebne do zadania.
- Przy commitach nigdy nie dodawaj `.DS_Store` ani innych plikow systemowych macOS. Commituj tylko pliki merytoryczne projektu.
- Nie nadpisuj `main.typ` bez wyraznej potrzeby. Jesli kolejny etap wymaga aktualizacji opisu systemu, zrob to w minimalnym zakresie i opisz zmiane.
- Nie uzywaj zewnetrznych zaleznosci, jesli Typst wystarcza.
- W repo nie ma obecnie Graphviz (`dot`) ani narzedzi `pdfinfo`/`pdftotext`; sprawdzanie PDF mozna robic przez kompilacje Typst do PNG.
