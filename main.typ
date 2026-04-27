#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2.5cm),
  header: align(right)[
    #text(8pt, fill: luma(100))[
      Projekt: Safety-Critical Systems | Autor: Twój Zespół \
      Politechnika Gdańska, 2026
    ]
  ],
  footer: context {
    align(right)[
      #text(9pt)[Strona #counter(page).display()]
    ]
  }
)

#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")
#set par(justify: true)

#align(center)[
  #text(17pt, weight: "bold")[Opis systemu do radioterapii LINAC] \
  #v(1em)
  #text(12pt)[Projekt: Systemy Krytyczne (Safety-Critical Systems)] \
  #text(11pt)[Wersja: 1.2 | Data: #datetime.today().display()]
]

#line(length: 100%, stroke: 1pt + gray)
#v(1em)

= Opis urządzenia

Medyczny akcelerator liniowy (LINAC - Linear particle accelerator) to urządzenie stosowane w teleradioterapii (napromienianiu z zewnątrz) pacjentów chorych na nowotwory. Kształtuje ono wysokoenergetyczne promieniowanie rentgenowskie lub wiązki elektronów w taki sposób, aby dopasować je do kształtu guza i zniszczyć komórki nowotworowe, oszczędzając jednocześnie otaczające zdrowe tkanki.

#figure(
  image("linac-scheme.png", width: 70%),
  caption: [Poglądowy schemat budowy akceleratora medycznego],
) <budowa_fizyczna>

Na powyższym schemacie poglądowym widać fizyczną budowę urządzenia, w tym głowicę (Gantry), stół pacjenta oraz obszar izocentrum, w którym skupia się wiązka promieniowania. Terapia ta ma charakter wysoce krytyczny; podanie nieprawidłowej dawki lub skierowanie promieniowania w niewłaściwe miejsce może skutkować poważnymi obrażeniami lub śmiercią pacjenta.

= Opis systemu

== Główne parametry
- *Zakres energii fotonów/elektronów:* 4 do 20 MV (megawoltów)
- *Moc dawki:* do 600 MU/min (Monitor Units na minutę)
- *Obrót gantry (głowicy):* 360 stopni wokół pacjenta

== Cele systemu
+ Pacjenci powinni otrzymywać precyzyjną dawkę promieniowania przepisaną przez lekarza onkologa.
+ Promieniowanie musi być dostarczane ściśle do docelowego obszaru guza, minimalizując ekspozycję zdrowych tkanek.
+ System musi natychmiast wstrzymać dostarczanie promieniowania w przypadku wykrycia jakiegokolwiek błędu sprzętowego, programowego lub błędu operatora.

== Struktura systemu

Aby umożliwić przejrzystą analizę bezpieczeństwa na poziomie architektury systemu, zrezygnowano z modelowania pojedynczych podzespołów fizycznych na rzecz głównych bloków funkcjonalnych. Wewnętrzne elementy toru terapeutycznego (takie jak działo elektronowe, generator RF, falowód przyspieszający czy magnes zakrzywiający) zostały logicznie połączone i zdefiniowane jako jeden nadrzędny komponent – *Akcelerator liniowy*. Podobnie ciężkie ramy mechaniczne (Gantry, Stand) zostały ujęte funkcjonalnie pod postacią napędzających je *Silników pozycjonujących*. Pozwala to na precyzyjną identyfikację interfejsów bez zbędnego zaciemniania analizy (np. drzew FTA).

Zgodnie z tym założeniem, system składa się z dokładnie 11 głównych komponentów:

#figure(
  image("LINAC.drawio.png", width: 90%),
  caption: [Schemat blokowy systemu LINAC i jego otoczenia],
) <architektura>

*Oprogramowanie:*
+ *Komputer sterujący:* Główna jednostka obliczeniowa zarządzająca danymi terapeutycznymi i koordynująca pracę sprzętu.
+ *Baza danych pacjentów:* Przechowuje plany leczenia, przepisane dawki i dane dotyczące pozycjonowania pacjentów.

*Sprzęt/Czujniki:*
3. *Akcelerator liniowy (Sprzęt):* Generuje wysokoenergetyczną wiązkę promieniowania.
4. *Detektor dawki promieniowania (Czujnik):* Komora jonizacyjna umieszczona na drodze wiązki, mierząca dokładną dawkę dostarczaną w czasie rzeczywistym.
5. *Konsola operatora (Sprzęt):* Interfejs znajdujący się na zewnątrz bunkra, używany przez technika do inicjowania i monitorowania wiązki.
6. *Wyłącznik awaryjny E-Stop (Sprzęt):* Fizyczne przyciski (wewnątrz pomieszczenia i na konsoli), które natychmiast odcinają zasilanie wysokiego napięcia.
7. *Blokada drzwi bunkra (Czujnik):* Wyłącznik bezpieczeństwa, który przerywa obwód bezpieczeństwa w przypadku otwarcia ciężkich drzwi bunkra.
8. *Kamera monitorująca (Czujnik):* Kamera umieszczona wewnątrz bunkra, która na żywo przesyła obraz we wnętrzu do *Komputera sterującego*, który wyświetla go na *Konsoli operatora*, umożliwiając elektroradiologowi podgląd i natychmiastowe zatrzymanie procedury przyciskiem *E-Stop*, gdy pacjent się poruszy.

*Elementy mechaniczne:*
9. *Kolimator - MLC (Mechanika/Sprzęt):* Zestaw ciężkich metalowych "listków" napędzanych silnikami, które dynamicznie kształtują wiązkę promieniowania.
10. *Stół pacjenta (Mechanika/Sprzęt):* Zrobotyzowana leżanka poruszająca się w wielu osiach w celu precyzyjnego ułożenia pacjenta.
11. *Silniki pozycjonujące (Mechanika):* Silniki odpowiedzialne za obrót gantry (ciężkiego ramienia utrzymującego akcelerator) wokół stołu z pacjentem.

*Interfejsy:* *Komputer sterujący* pobiera plany z *Bazy danych pacjentów* i wysyła sygnały sterujące do *Akceleratora liniowego* oraz *MLC*. Nieustannie odbiera również sygnały zwrotne z *Detektora dawki promieniowania* i obraz wideo z *Kamery monitorującej*, przekazując go na bieżąco do *Konsoli operatora*. Jeśli *Blokada drzwi bunkra* lub wyłącznik *E-Stop* zostaną wyzwolone, sprzętowe zabezpieczenie omija oprogramowanie, fizycznie odcinając zasilanie *Akceleratora liniowego*.

== Środowisko systemu
LINAC działa w wysoce kontrolowanym środowisku:
- *Operatorzy i inne osoby:* Elektroradiolodzy (obsługujący maszynę), Lekarze onkolodzy-radioterapeuci (przepisujący dawkę), Fizycy medyczni (kalibrujący sprzęt) oraz Pacjenci. *W ramach niniejszej analizy skupiono się przede wszystkim na interakcjach pacjenta oraz elektroradiologa z systemem, traktując pozostałe role jako drugoplanowe.*
- *Inne elementy otoczenia:* Gruby betonowo-ołowiany bunkier (krypta) zapobiegający wydostawaniu się promieniowania na zewnątrz.
- *Energia i niebezpieczne substancje:* Energia elektryczna o wysokim napięciu, mikrofale (RF) oraz promieniowanie jonizujące (promieniowanie X/elektrony).
- *Warunki pracy:* Surowe warunki kliniczne wewnątrz budynku. Temperatura i wilgotność muszą być ściśle kontrolowane, ponieważ ich wahania mogą wpływać na dokładność *Detektora dawki promieniowania* (komory jonizacyjnej).

= Procedura radioterapii

+ Pacjent wchodzi do bunkra i kładzie się na *Stole pacjenta*.
+ Elektroradiolog używa ręcznych elementów sterujących do regulacji *Silników pozycjonujących* i stołu, ustawiając pacjenta zgodnie z laserami pozycjonującymi.
+ Elektroradiolog opuszcza bunkier i bezpiecznie zamyka drzwi (aktywując *Blokadę drzwi bunkra*).
+ Przy *Konsoli operatora* na zewnątrz bunkra, elektroradiolog wczytuje plan pacjenta z *Bazy danych pacjentów*.
+ *Komputer sterujący* konfiguruje listki *MLC* w celu ukształtowania wiązki odpowiednio do specyficznego guza.
+ Elektroradiolog naciska przycisk "Beam On" (Włącz wiązkę).
+ *Akcelerator liniowy* generuje wiązkę, a *Detektor dawki promieniowania* monitoruje podawaną dawkę. Podczas naświetlania elektroradiolog uważnie obserwuje pacjenta za pośrednictwem *Kamery monitorującej* na *Konsoli operatora*, mając możliwość natychmiastowego wyłączenia promieniowania przyciskiem stop (*E-Stop*) w przypadku, gdy pacjent zacznie się poruszać.
+ Po osiągnięciu przepisanej dawki, *Komputer sterujący* automatycznie wyłącza wiązkę.
+ Elektroradiolog otwiera drzwi, wchodzi do bunkra i pomaga pacjentowi zejść ze stołu.

= Tryby pracy systemu LINAC

== Tryb gotowości (Idle Mode)
Domyślny stan systemu po włączeniu zasilania, gdy nie odbywa się żadna terapia. Komputer sterujący jest aktywny, systemy chłodzenia oraz czujniki diagnostyczne pracują, ale obwody wysokiego napięcia akceleratora pozostają sprzętowo zablokowane. W tym trybie system oczekuje na wczytanie planu pacjenta.

== Tryb pozycjonowania (Setup Mode)
Tryb używany podczas fizycznej obecności operatora i pacjenta w bunkrze. Ze względów bezpieczeństwa generowanie wiązki jest całkowicie zablokowane. System pozwala jedynie na powolne sterowanie *Silnikami pozycjonującymi* (ruchy stołu i gantry) za pomocą ręcznego pilota w celu precyzyjnego ułożenia pacjenta.

== Tryb terapeutyczny (Treatment Mode)
Podstawowy tryb pracy. System wymaga zweryfikowanego planu pacjenta z bazy danych. Wiązkę można zainicjować wyłącznie z zewnętrznej *Konsoli operatora*, gdy *Blokada drzwi bunkra* jest zamknięta. *Komputer sterujący* aktywnie porównuje dostarczoną dawkę z dawką przypisaną w planie.

== Tryb kalibracji / QA (Calibration Mode)
Używany wyłącznie przez fizyków medycznych bez obecności pacjenta w pomieszczeniu. Tryb ten pozwala na ręczne pominięcie standardowych planów leczenia w celu wyemitowania wiązki do fantomów wodnych (urządzeń testowych). Służy do weryfikacji dokładności *Detektora dawki promieniowania* oraz geometrii wiązki.

== Tryb awaryjny (Emergency Mode)
Uruchamiany automatycznie przez system lub ręcznie za pomocą przycisku *E-Stop*. Zasilanie wysokiego napięcia do *Akceleratora liniowego* i *Silników pozycjonujących* jest natychmiast odcinane za pomocą przekaźników sprzętowych. Sterowanie z poziomu oprogramowania zostaje zablokowane aż do pełnego restartu systemu i ręcznego przeprowadzenia kontroli bezpieczeństwa.

= Zagrożenia (Główne ryzyka)

Poniżej przedstawiono główne ryzyka związane z systemem LINAC, które zostaną poddane głębszej analizie za pomocą drzew błędów (FTA - Fault Tree Analysis) w kolejnym zadaniu.

*1. Przedawkowanie promieniowania (Krytyczne)*
Najpoważniejsze zagrożenie. System nie zatrzymuje wiązki promieniowania po dostarczeniu zaplanowanej dawki. Może to być spowodowane błędem obliczeniowym oprogramowania, awarią *Detektora dawki promieniowania* lub zwarciem elektrycznym utrzymującym aktywność akceleratora. Konsekwencje obejmują poważne oparzenia popromienne, martwicę tkanek lub śmierć pacjenta.

*2. Zbyt niska dawka promieniowania / Pudło (Poważne)*
System dostarcza znacznie mniej promieniowania niż zalecono lub wiązka jest nieprawidłowo ukształtowana przez *MLC*, omijając guz. Choć nie powoduje to natychmiastowej śmierci, konsekwencją jest niepowodzenie w leczeniu raka, co prowadzi do postępu choroby i stanowi poważne zagrożenie dla długoterminowego zdrowia pacjenta.

*3. Zmiażdżenie / Uderzenie pacjenta (Poważne)*
*Silniki pozycjonujące* lub *Stół pacjenta* poruszają się w sposób niekontrolowany lub ignorują czujniki krańcowe, gdy pacjent znajduje się na leżance. Biorąc pod uwagę ogromną wagę gantry, może to skutkować poważnymi urazami fizycznymi lub zmiażdżeniem pacjenta albo technika przebywającego w pomieszczeniu.

= Wykorzystanie AI (AI usage)

Zgodnie z wytycznymi projektu, poniżej przedstawiono zakres wykorzystania narzędzi sztucznej inteligencji w procesie przygotowania raportu:

a) *Zakres wykorzystania:*
Sztuczna inteligencja została wykorzystana przede wszystkim jako źródło wiedzy dziedzinowej w celu identyfikacji kluczowych komponentów systemu LINAC oraz opracowania ich technicznych opisów. Narzędzia AI wsparły proces definiowania procedury radioterapii oraz ogólnego formatowania dokumentu w języku Typst. Ponadto AI posłużyło do przeprowadzenia korekty językowej, stylistycznej oraz znalezienia błędów merytorycznych w tekście.

b) *Weryfikacja wyników:*
Wszystkie informacje wygenerowane przy wsparciu AI zostały poddane ręcznej weryfikacji przez zespół projektowy. Sprawdzono spójność techniczną opisów komponentów z ogólnodostępnymi schematami akceleratorów medycznych oraz zweryfikowano logiczną poprawność trybów pracy i procedur pod kątem wymagań dla systemów krytycznych (safety-critical).