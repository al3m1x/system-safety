#set page(
  paper: "a4",
  margin: (x: 1.8cm, y: 2.2cm),
  header: context {
    if counter(page).get().first() == 1 {
      align(right)[
        #text(8pt, fill: luma(100))[
          Autorzy:
          \ Juliusz Radziszewski s193504
          \ Adrian Szwaczyk s193233
          \ Sebastian Kwaśniak s188807
          \ Maciej Żuralski s193367
        ]
      ]
    }
  },
  footer: context {
    align(right)[
      #text(9pt)[Strona #counter(page).display()]
    ]
  }
)

#set text(font: "New Computer Modern", size: 10.5pt)
#set heading(numbering: "1.1")
#set par(justify: true)
#set table(
  stroke: 0.45pt + gray,
  inset: 4pt,
)
#set figure(supplement: [Rysunek])

#let hazard-color(level) = {
  if level == "High" {
    rgb("#f4cccc")
  } else if level == "Medium" {
    rgb("#fff2cc")
  } else if level == "Low" {
    rgb("#d9ead3")
  } else {
    rgb("#eeeeee")
  }
}

#let crit(level) = table.cell(fill: hazard-color(level))[#level]

#align(center)[
  #text(11pt, weight: "bold")[#strong[Politechnika Gdańska]] \
  #v(0.5em)
  #text(17pt, weight: "bold")[Analiza zagrożeń systemu radioterapii LINAC] \
  #v(1em)
  #text(12pt)[Projekt: Systemy Krytyczne (Safety-Critical Systems)] \
  #text(11pt)[Etap 1: Hazards analysis | Wersja: 1.0 | Data: #datetime.today().display()]
]

#line(length: 100%, stroke: 1pt + gray)
#v(1em)

= Cel i zakres analizy

Celem dokumentu jest identyfikacja zagrożeń dla medycznego akceleratora liniowego LINAC opisanego w dokumencie `Opis systemu do radioterapii LINAC`, wskazanie scenariuszy wypadkowych za pomocą analizy FTA oraz przedstawienie poziomu ryzyka wybranych zagrożeń w macierzy ryzyka.

Analiza obejmuje tryby pracy zdefiniowane w opisie systemu: tryb gotowości, pozycjonowania, terapeutyczny, kalibracji/QA oraz awaryjny. Uwzględniono zagrożenia sprzętowe, programowe, środowiskowe, elektryczne, mechaniczne oraz błędy ludzkie podczas obsługi, konfiguracji i utrzymania systemu.

== Założenia

- System jest używany w bunkrze radioterapeutycznym przez przeszkolonych elektroradiologów, a kalibracja jest wykonywana przez fizyków medycznych.
- W trybie terapeutycznym pacjent przebywa sam w bunkrze, a operator monitoruje procedurę z konsoli poza pomieszczeniem.
- Blokada drzwi bunkra i przyciski E-Stop są zabezpieczeniami sprzętowymi, które powinny odcinać zasilanie wysokiego napięcia niezależnie od komputera sterującego.
- Prawdopodobieństwo w tabelach jest oszacowaniem jakościowym dla realistycznej eksploatacji klinicznej, a nie dokładną wartością statystyczną.
- Krytyczność wynika z połączenia prawdopodobieństwa i ciężkości konsekwencji zgodnie z macierzą w rozdziale 5.

= Skale oceny

#table(
  columns: (2.7cm, 10.8cm),
  table.header([*Poziom*], [*Znaczenie prawdopodobieństwa*]),
  [High], [Zdarzenie może wystąpić wielokrotnie w okresie eksploatacji systemu lub jest silnie zależne od typowych błędów operacyjnych.],
  [Medium], [Zdarzenie jest możliwe przy pojedynczej awarii, błędzie konfiguracji lub nieprawidłowym działaniu procedury.],
  [Low], [Zdarzenie wymaga zbiegu kilku awarii lub błędów, ale pozostaje wiarygodne w praktyce eksploatacyjnej.],
  [Marginal], [Zdarzenie wymaga rzadkiego zbiegu wielu niesprawności, obejść zabezpieczeń lub skrajnego naruszenia procedur.]
)

#v(0.8em)

#table(
  columns: (2.7cm, 10.8cm),
  table.header([*Poziom*], [*Znaczenie ciężkości skutków*]),
  [Critical], [Śmierć pacjenta lub osoby z personelu, trwałe ciężkie obrażenia, bardzo poważne skutki radiacyjne.],
  [Serious], [Ciężkie obrażenia, istotne pogorszenie rokowania pacjenta, duże szkody materialne lub długotrwałe przerwanie leczenia.],
  [Moderate], [Przejściowy wpływ na zdrowie pacjenta, umiarkowane szkody, konieczność powtórzenia procedury lub dodatkowej diagnostyki.],
  [Marginal], [Drobne szkody, brak istotnego wpływu na zdrowie pacjenta, lokalne zakłócenie pracy.]
)

= Identyfikacja zagrożeń

#text(size: 8.4pt)[
#table(
  columns: (0.9cm, 2.7cm, 4.1cm, 4.1cm, 1.55cm, 1.55cm, 1.55cm),
  align: (center, left, left, left, center, center, center),
  table.header(
    [*Id*], [*Hazard name*], [*Main causes*], [*Consequences*], [*Likelihood*], [*Severity*], [*Criticality*],
  ),
  [H-01], [Nadmierna dawka promieniowania], [Błąd licznika MU w komputerze sterującym, błędny odczyt detektora dawki, zablokowany przekaźnik wysokiego napięcia, niepoprawny plan leczenia.], [Oparzenia popromienne, martwica tkanek, poważne uszkodzenie narządów lub śmierć pacjenta.], [Low], [Critical], crit("High"),
  [H-02], [Zbyt niska dawka terapeutyczna], [Przedwczesne wyłączenie wiązki, błędna kalibracja dawki, awaria akceleratora, błędna wartość dawki w planie.], [Nieskuteczne leczenie nowotworu, progresja choroby, konieczność powtórzenia terapii.], [Medium], [Serious], crit("High"),
  [H-03], [Napromienienie niewłaściwego obszaru pacjenta], [Błędne pozycjonowanie stołu lub gantry, zły plan pacjenta, błąd transformacji współrzędnych, ruch pacjenta podczas emisji.], [Napromienienie zdrowych tkanek i niedostarczenie dawki do guza; możliwe trwałe obrażenia lub śmierć.], [Low], [Critical], crit("High"),
  [H-04], [Osoba znajduje się w bunkrze podczas emisji wiązki], [Błąd operatora, obejście blokady drzwi, nieskuteczna kontrola obecności, awaria sygnalizacji i monitoringu.], [Nieplanowana ekspozycja personelu lub osoby postronnej na promieniowanie jonizujące.], [Marginal], [Critical], crit("Medium"),
  [H-05], [Kolizja gantry lub stołu z pacjentem albo operatorem], [Awaria krańcówek, błędne enkodery, niekontrolowane polecenie ruchu, błąd operatora w trybie pozycjonowania lub serwisowym.], [Zmiażdżenie, złamania, urazy głowy lub uszkodzenie sprzętu.], [Medium], [Serious], crit("High"),
  [H-06], [Nieprawidłowy kształt pola promieniowania], [Zacięcie listków MLC, błąd sterowania MLC, utrata informacji zwrotnej o pozycji listków, użycie niewłaściwej konfiguracji.], [Napromienienie zdrowych tkanek lub niedostateczna dawka w części guza.], [Medium], [Serious], crit("High"),
  [H-07], [Brak skutecznego monitorowania pacjenta podczas emisji], [Awaria kamery, zamrożenie obrazu na konsoli, opóźnienie transmisji, nieuwaga operatora, brak alarmu utraty wideo.], [Ruch pacjenta lub pogorszenie stanu nie zostają wykryte, co może prowadzić do błędnej ekspozycji albo opóźnienia reakcji.], [Medium], [Serious], crit("High"),
  [H-08], [Emisja wiązki w niewłaściwym trybie pracy], [Błąd logiki trybów, pozostawiony tryb kalibracji, obejście kontroli dostępu, użycie planu QA przy obecnym pacjencie.], [Nieautoryzowana lub niekontrolowana emisja promieniowania poza zatwierdzoną procedurą terapeutyczną.], [Marginal], [Critical], crit("Medium"),
  [H-09], [Nieskuteczne zatrzymanie awaryjne], [Awaria E-Stop, zespawany przekaźnik, błąd okablowania obwodu bezpieczeństwa, brak testu okresowego.], [Brak możliwości natychmiastowego przerwania emisji lub ruchu mechanicznego podczas incydentu.], [Low], [Critical], crit("High"),
  [H-10], [Warunki środowiskowe zakłócają pomiar dawki], [Niewłaściwa temperatura lub wilgotność, awaria klimatyzacji, kondensacja, dryft komory jonizacyjnej.], [Błędna informacja zwrotna o dawce, przerwanie leczenia lub niepoprawne dawkowanie.], [Medium], [Moderate], crit("Medium"),
  [H-11], [Porażenie elektryczne personelu serwisowego], [Kontakt z obwodami wysokiego napięcia, brak rozładowania kondensatorów, obejście blokad serwisowych, uszkodzona izolacja.], [Ciężkie obrażenia elektryczne lub śmierć technika serwisowego.], [Marginal], [Critical], crit("Medium"),
  [H-12], [Nieprawidłowa kalibracja detektora dawki], [Błąd procedury QA, użycie złego fantomu, nieuwzględnienie dryftu, zatwierdzenie nieaktualnego współczynnika kalibracji.], [Systematycznie błędna dawka w wielu sesjach leczenia.], [Low], [Critical], crit("High"),
  [H-13], [Wczytanie niewłaściwego planu pacjenta], [Błędna identyfikacja pacjenta, pomyłka w bazie danych, niezatwierdzona wersja planu, nieskuteczna weryfikacja na konsoli.], [Podanie dawki i geometrii leczenia przeznaczonej dla innego pacjenta lub innej frakcji.], [Low], [Critical], crit("High"),
  [H-14], [Zanieczyszczenie biologiczne powierzchni stołu lub akcesoriów], [Niewłaściwa dezynfekcja, pośpiech między pacjentami, brak kontroli czystości wyposażenia unieruchamiającego.], [Zakażenie pacjenta lub personelu, opóźnienie terapii i konieczność dekontaminacji.], [Medium], [Moderate], crit("Medium"),
)
]

= Wybrane zagrożenia do analizy FTA

Zespół projektowy liczy 4 osoby, dlatego zgodnie z wymaganiem przeanalizowano 8 zagrożeń: H-01, H-03, H-04, H-05, H-07, H-08, H-11 oraz H-13. Dobór obejmuje różne klasy zagrożeń: radiacyjne, mechaniczne, programowe, ludzkie, środowiskowo-organizacyjne i elektryczne.

W drzewach FTA zastosowano następujące oznaczenia:
- `OR` oznacza, że wystarczy jedno zdarzenie podrzędne.
- `AND` oznacza, że muszą zajść wszystkie zdarzenia podrzędne w danej gałęzi.
- `BE` oznacza zdarzenie bazowe.

== FTA H-01: Nadmierna dawka promieniowania

#figure(
  block(width: 100%, inset: 6pt, stroke: 0.5pt + gray)[
    #set text(font: "DejaVu Sans Mono", size: 7.2pt)
```text
H-01 TOP: Nadmierna dawka promieniowania dostarczona pacjentowi
└─ OR
   ├─ G-H01-A: System nie zatrzymuje wiązki po osiągnięciu zaplanowanej dawki
   │  └─ OR
   │     ├─ BE-H01-01: Komputer sterujący nie wysyła polecenia Beam Off po osiągnięciu MU
   │     ├─ BE-H01-02: Błąd licznika MU lub przepełnienie zmiennej w module sterującym dawką
   │     ├─ BE-H01-03: Konsola operatora nie pokazuje alarmu przekroczenia dawki
   │     └─ BE-H01-04: Operator po alarmie ponownie uruchamia wiązkę bez pełnej weryfikacji
   ├─ G-H01-B: Rzeczywista dawka jest większa niż dawka mierzona przez system
   │  └─ OR
   │     ├─ BE-H01-05: Detektor dawki promieniowania jest rozkalibrowany i zaniża odczyt
   │     ├─ BE-H01-06: Komora jonizacyjna ulega nasyceniu przy wysokiej mocy dawki
   │     ├─ BE-H01-07: Utrata połączenia z detektorem, a komputer używa ostatniej poprawnej wartości
   │     └─ BE-H01-08: Warunki temperatury lub wilgotności powodują dryft pomiaru dawki
   └─ G-H01-C: Akcelerator liniowy fizycznie pozostaje aktywny mimo komendy wyłączenia
      └─ OR
         ├─ BE-H01-09: Przekaźnik wysokiego napięcia jest zespawany w stanie zamkniętym
         ├─ BE-H01-10: Linia sterująca HV Enable jest zwarta do stanu aktywnego
         └─ BE-H01-11: Obwód E-Stop nie odcina zasilania toru wysokiego napięcia
```
  ],
  caption: [Drzewo FTA dla H-01],
)

Scenariusz wypadkowy H-01 jest krytyczny, ponieważ pojedyncza awaria pomiaru dawki może zostać wzmocniona przez brak niezależnego zatrzymania wiązki albo błędną reakcję operatora. Kluczowe komponenty to komputer sterujący, detektor dawki, akcelerator liniowy, konsola operatora i E-Stop.

== FTA H-03: Napromienienie niewłaściwego obszaru pacjenta

#figure(
  block(width: 100%, inset: 6pt, stroke: 0.5pt + gray)[
    #set text(font: "DejaVu Sans Mono", size: 7.2pt)
```text
H-03 TOP: Wiązka promieniowania trafia poza planowany obszar guza
└─ OR
   ├─ G-H03-A: Niepoprawna geometria systemu względem pacjenta
   │  └─ OR
   │     ├─ BE-H03-01: Stół pacjenta ustawia błędne współrzędne pozycjonowania
   │     ├─ BE-H03-02: Enkoder gantry raportuje niepoprawny kąt obrotu
   │     ├─ BE-H03-03: Silniki pozycjonujące wykonują ruch w niewłaściwej osi
   │     └─ BE-H03-04: Operator ustawia pacjenta względem niewłaściwego znacznika laserowego
   ├─ G-H03-B: Plan leczenia nie odpowiada aktualnemu pacjentowi lub frakcji
   │  └─ OR
   │     ├─ BE-H03-05: Baza danych pacjentów zwraca plan innego pacjenta
   │     ├─ BE-H03-06: Komputer sterujący używa niezatwierdzonej wersji planu
   │     ├─ BE-H03-07: Konsola obcina istotną część identyfikatora planu lub pacjenta
   │     └─ BE-H03-08: Operator pomija kontrolę zgodności pacjent-plan
   └─ G-H03-C: Pacjent zmienia pozycję po uruchomieniu wiązki
      └─ AND
         ├─ BE-H03-09: Pacjent porusza się lub zsuwa na stole podczas emisji
         ├─ BE-H03-10: Kamera monitorująca nie pozwala wykryć ruchu
         └─ BE-H03-11: Operator nie aktywuje E-Stop w wymaganym czasie
```
  ],
  caption: [Drzewo FTA dla H-03],
)

W tym scenariuszu ważne są zarówno błędy sprzętowe pozycjonowania, jak i błędy danych terapeutycznych. Nawet poprawnie działająca wiązka staje się niebezpieczna, jeżeli izocentrum lub plan leczenia nie odpowiadają rzeczywistej pozycji pacjenta.

== FTA H-04: Osoba znajduje się w bunkrze podczas emisji wiązki

#figure(
  block(width: 100%, inset: 6pt, stroke: 0.5pt + gray)[
    #set text(font: "DejaVu Sans Mono", size: 7.2pt)
```text
H-04 TOP: Wiązka zostaje włączona, gdy w bunkrze znajduje się osoba niebędąca pacjentem
└─ AND
   ├─ G-H04-A: System uznaje bunkier za gotowy do emisji
   │  └─ OR
   │     ├─ BE-H04-01: Blokada drzwi bunkra jest zwarta w stanie "drzwi zamknięte"
   │     ├─ BE-H04-02: Serwisowe obejście blokady drzwi pozostaje aktywne po pracach QA
   │     ├─ BE-H04-03: Czujnik drzwi jest źle wyregulowany po konserwacji
   │     └─ BE-H04-04: Komputer sterujący nie sprawdza stanu blokady przed Beam On
   ├─ G-H04-B: Obecność osoby nie zostaje wykryta przed startem
   │  └─ OR
   │     ├─ BE-H04-05: Operator nie wykonuje końcowej kontroli wizualnej bunkra
   │     ├─ BE-H04-06: Kamera monitorująca ma martwe pole lub zasłonięty obraz
   │     ├─ BE-H04-07: Sygnalizacja świetlna lub dźwiękowa ostrzegająca przed emisją nie działa
   │     └─ BE-H04-08: Procedura wejścia/wyjścia z bunkra nie wymaga potwierdzenia drugiej osoby
   └─ G-H04-C: Nie dochodzi do skutecznej reakcji awaryjnej
      └─ OR
         ├─ BE-H04-09: Osoba w bunkrze nie ma dostępu do działającego E-Stop
         ├─ BE-H04-10: Operator nie zauważa osoby na konsoli przed emisją
         └─ BE-H04-11: E-Stop nie odcina zasilania wysokiego napięcia
```
  ],
  caption: [Drzewo FTA dla H-04],
)

H-04 wymaga zwykle jednoczesnego naruszenia procedury i nieskutecznego zabezpieczenia. Mimo niskiego prawdopodobieństwa skutki są krytyczne, bo osoba niebędąca pacjentem nie jest chroniona planem leczenia ani geometrią wiązki.

== FTA H-05: Kolizja gantry lub stołu z pacjentem albo operatorem

#figure(
  block(width: 100%, inset: 6pt, stroke: 0.5pt + gray)[
    #set text(font: "DejaVu Sans Mono", size: 7.2pt)
```text
H-05 TOP: Ruchomy element LINAC powoduje kolizję z pacjentem lub operatorem
└─ OR
   ├─ G-H05-A: System wykonuje niekontrolowany lub błędny ruch
   │  └─ OR
   │     ├─ BE-H05-01: Komputer sterujący wysyła komendę ruchu do niewłaściwej osi
   │     ├─ BE-H05-02: Silniki pozycjonujące nie zatrzymują się po zwolnieniu sterowania
   │     ├─ BE-H05-03: Hamulec gantry nie utrzymuje pozycji po zaniku zasilania
   │     └─ BE-H05-04: Tryb serwisowy pozostawia wyłączone ograniczenie prędkości
   ├─ G-H05-B: System nie rozpoznaje niebezpiecznego położenia
   │  └─ OR
   │     ├─ BE-H05-05: Krańcówka stołu pacjenta jest uszkodzona
   │     ├─ BE-H05-06: Enkoder pozycji gantry jest rozkalibrowany
   │     ├─ BE-H05-07: Model kolizji w oprogramowaniu nie uwzględnia aktualnego osprzętu
   │     └─ BE-H05-08: Połączenie czujnika pozycji z komputerem sterującym jest przerwane
   └─ G-H05-C: Operator lub pacjent znajduje się w strefie ruchu
      └─ OR
         ├─ BE-H05-09: Operator stoi przy stole podczas ruchu gantry
         ├─ BE-H05-10: Pacjent wysuwa kończynę poza obszar unieruchomienia
         ├─ BE-H05-11: Operator wybiera zbyt duży krok ruchu w trybie pozycjonowania
         └─ BE-H05-12: Kamera lub widoczność lokalna nie pozwala ocenić odstępu
```
  ],
  caption: [Drzewo FTA dla H-05],
)

Najbardziej ryzykowne fazy dla H-05 to pozycjonowanie i prace serwisowe, ponieważ w bunkrze może przebywać człowiek, a system pozwala na ruch stołu, gantry lub elementów pozycjonujących.

== FTA H-07: Brak skutecznego monitorowania pacjenta podczas emisji

#figure(
  block(width: 100%, inset: 6pt, stroke: 0.5pt + gray)[
    #set text(font: "DejaVu Sans Mono", size: 7.2pt)
```text
H-07 TOP: Pacjent nie jest skutecznie monitorowany podczas aktywnej emisji wiązki
└─ OR
   ├─ G-H07-A: Obraz pacjenta nie dociera do operatora
   │  └─ OR
   │     ├─ BE-H07-01: Kamera monitorująca traci zasilanie
   │     ├─ BE-H07-02: Przewód lub interfejs transmisji wideo jest uszkodzony
   │     ├─ BE-H07-03: Komputer sterujący zamraża ostatnią klatkę obrazu
   │     └─ BE-H07-04: Konsola operatora nie wyświetla strumienia z kamery
   ├─ G-H07-B: Obraz jest dostępny, ale nie pozwala wykryć stanu pacjenta
   │  └─ OR
   │     ├─ BE-H07-05: Oświetlenie bunkra jest niewystarczające
   │     ├─ BE-H07-06: Kamera jest źle ustawiona po konserwacji
   │     ├─ BE-H07-07: Pacjent jest zasłonięty przez gantry lub akcesoria unieruchamiające
   │     └─ BE-H07-08: Opóźnienie transmisji przekracza czas potrzebny do reakcji
   └─ G-H07-C: Człowiek nie reaguje na nieprawidłową sytuację
      └─ OR
         ├─ BE-H07-09: Operator jest rozproszony innym alarmem na konsoli
         ├─ BE-H07-10: Brak alarmu technicznego utraty obrazu
         └─ BE-H07-11: Operator nie ma jasnej procedury przerwania leczenia przy utracie wideo
```
  ],
  caption: [Drzewo FTA dla H-07],
)

H-07 nie musi bezpośrednio oznaczać wypadku, ale usuwa istotną warstwę detekcji. W połączeniu z ruchem pacjenta, pogorszeniem stanu zdrowia lub awarią pozycjonowania może prowadzić do H-03 albo opóźnionego zatrzymania wiązki.

== FTA H-08: Emisja wiązki w niewłaściwym trybie pracy

#figure(
  block(width: 100%, inset: 6pt, stroke: 0.5pt + gray)[
    #set text(font: "DejaVu Sans Mono", size: 7.2pt)
```text
H-08 TOP: Wiązka zostaje wyemitowana poza zatwierdzonym trybem terapeutycznym
└─ OR
   ├─ G-H08-A: Błąd egzekwowania trybu pracy przez system
   │  └─ OR
   │     ├─ BE-H08-01: Flaga trybu w komputerze sterującym jest uszkodzona lub niespójna
   │     ├─ BE-H08-02: Moduł Beam On nie weryfikuje aktualnego trybu przed emisją
   │     ├─ BE-H08-03: Interfejs serwisowy może aktywować HV Enable poza konsolą terapeutyczną
   │     └─ BE-H08-04: Test regresyjny nie obejmuje przejść między trybami pracy
   ├─ G-H08-B: Tryb kalibracji/QA jest użyty w obecności pacjenta
   │  └─ OR
   │     ├─ BE-H08-05: Operator wybiera plan QA zamiast planu leczenia pacjenta
   │     ├─ BE-H08-06: System nie wymaga potwierdzenia braku pacjenta w trybie QA
   │     ├─ BE-H08-07: Uprawnienia operatora pozwalają uruchomić tryb QA bez fizyka medycznego
   │     └─ BE-H08-08: Fantom QA lub akcesoria są błędnie rozpoznane jako konfiguracja pacjenta
   └─ G-H08-C: Zabezpieczenia trybu pozycjonowania są nieskuteczne
      └─ OR
         ├─ BE-H08-09: Blokada emisji w Setup Mode jest błędnie skonfigurowana
         ├─ BE-H08-10: Obwód wysokiego napięcia pozostaje uzbrojony po przejściu z Treatment Mode
         └─ BE-H08-11: Konsola operatora pokazuje nieaktualny status trybu
```
  ],
  caption: [Drzewo FTA dla H-08],
)

Ten hazard dotyczy głównie konfiguracji i utrzymania systemu. Niewłaściwa separacja trybów pracy jest szczególnie niebezpieczna, bo omija podstawowe założenie, że emisja wiązki jest dozwolona tylko w kontrolowanej procedurze terapeutycznej.

== FTA H-11: Porażenie elektryczne personelu serwisowego

#figure(
  block(width: 100%, inset: 6pt, stroke: 0.5pt + gray)[
    #set text(font: "DejaVu Sans Mono", size: 7.2pt)
```text
H-11 TOP: Technik serwisowy zostaje porażony energią elektryczną LINAC
└─ AND
   ├─ G-H11-A: Niebezpieczne napięcie jest obecne w dostępnym obszarze
   │  └─ OR
   │     ├─ BE-H11-01: Kondensatory wysokiego napięcia nie zostały rozładowane po wyłączeniu
   │     ├─ BE-H11-02: Zasilacz serwisowy pozostaje aktywny mimo odcięcia toru terapeutycznego
   │     ├─ BE-H11-03: Przekaźnik izolujący jest sklejony w pozycji zamkniętej
   │     └─ BE-H11-04: Wilgoć lub zabrudzenie obniża rezystancję izolacji
   ├─ G-H11-B: Osłona lub procedura serwisowa nie izoluje technika
   │  └─ OR
   │     ├─ BE-H11-05: Blokada panelu serwisowego jest obejściem pozostawionym po diagnostyce
   │     ├─ BE-H11-06: Procedura LOTO nie została wykonana lub udokumentowana
   │     ├─ BE-H11-07: Etykieta ostrzegawcza nie wskazuje obecności energii resztkowej
   │     └─ BE-H11-08: Czujnik napięcia resztkowego jest niesprawny lub nieskalibrowany
   └─ G-H11-C: Dochodzi do kontaktu człowieka z elementem pod napięciem
      └─ OR
         ├─ BE-H11-09: Technik dotyka złącza HV podczas pomiaru
         ├─ BE-H11-10: Uszkodzona izolacja przewodu odsłania przewodnik
         └─ BE-H11-11: Użyte narzędzie pomiarowe nie ma odpowiedniej kategorii bezpieczeństwa
```
  ],
  caption: [Drzewo FTA dla H-11],
)

H-11 jest związany przede wszystkim z trybem konserwacji. Istotne jest rozróżnienie między zatrzymaniem terapeutycznym a pełnym, udokumentowanym odłączeniem energii podczas prac przy obwodach wysokiego napięcia.

== FTA H-13: Wczytanie niewłaściwego planu pacjenta

#figure(
  block(width: 100%, inset: 6pt, stroke: 0.5pt + gray)[
    #set text(font: "DejaVu Sans Mono", size: 7.2pt)
```text
H-13 TOP: Do leczenia zostaje użyty plan nieodpowiadający aktualnemu pacjentowi
└─ OR
   ├─ G-H13-A: System wybiera lub prezentuje błędny rekord z bazy danych pacjentów
   │  └─ OR
   │     ├─ BE-H13-01: Zapytanie do bazy danych zwraca rekord o podobnym imieniu i nazwisku
   │     ├─ BE-H13-02: Replikacja bazy danych jest opóźniona i udostępnia starszą wersję planu
   │     ├─ BE-H13-03: Błąd mapowania identyfikatora pacjenta na identyfikator planu
   │     └─ BE-H13-04: Suma kontrolna lub podpis planu nie są weryfikowane przy wczytaniu
   ├─ G-H13-B: Operator zatwierdza niewłaściwy plan na konsoli
   │  └─ OR
   │     ├─ BE-H13-05: Skaner identyfikatora pacjenta nie działa i użyto ręcznego wyboru
   │     ├─ BE-H13-06: Konsola obcina długi identyfikator lub nazwę planu
   │     ├─ BE-H13-07: Operator pomija procedurę time-out przed Beam On
   │     └─ BE-H13-08: Dwie zaplanowane frakcje mają podobne nazwy i daty
   └─ G-H13-C: Nieaktualna lub niezatwierdzona wersja planu trafia do leczenia
      └─ OR
         ├─ BE-H13-09: Lekarz/fizyk nie zatwierdził finalnej wersji planu w systemie
         ├─ BE-H13-10: Komputer sterujący nie blokuje planu o statusie roboczym
         └─ BE-H13-11: Awaria sieci powoduje użycie lokalnej kopii planu bez walidacji
```
  ],
  caption: [Drzewo FTA dla H-13],
)

H-13 łączy awarie informatyczne z błędami ludzkimi. Szczególnie ryzykowne jest ręczne obejście identyfikacji pacjenta, ponieważ wtedy poprawność leczenia zależy od jakości interfejsu konsoli i dyscypliny proceduralnej operatora.

#pagebreak()

= Macierz ryzyka

Przyjęto następującą jakościową macierz krytyczności. W każdej komórce podano najpierw poziom ryzyka, a następnie identyfikatory analizowanych zagrożeń, które trafiły do danej klasy.

#table(
  columns: (2.4cm, 3cm, 3cm, 3cm, 3cm),
  align: (center, center, center, center, center),
  table.header([*Likelihood \\ Severity*], [*Marginal*], [*Moderate*], [*Serious*], [*Critical*]),
  [*High*], crit("Medium"), crit("High"), crit("High"), crit("High"),
  [*Medium*], crit("Low"), crit("Medium"), table.cell(fill: hazard-color("High"))[*High* \ H-05, H-07], crit("High"),
  [*Low*], crit("Low"), crit("Low"), crit("Medium"), table.cell(fill: hazard-color("High"))[*High* \ H-01, H-03, H-13],
  [*Marginal*], crit("Marginal"), crit("Low"), crit("Low"), table.cell(fill: hazard-color("Medium"))[*Medium* \ H-04, H-08, H-11],
)

#v(1em)

#text(size: 9pt)[
#table(
  columns: (1.1cm, 3.4cm, 1.8cm, 1.8cm, 1.8cm, 5.5cm),
  align: (center, left, center, center, center, left),
  table.header([*Id*], [*Hazard*], [*Likelihood*], [*Severity*], [*Risk*], [*Uzasadnienie oceny*]),
  [H-01], [Nadmierna dawka promieniowania], [Low], [Critical], crit("High"), [Wymaga awarii kontroli dawki, ale skutki radiacyjne są potencjalnie śmiertelne.],
  [H-03], [Napromienienie niewłaściwego obszaru], [Low], [Critical], crit("High"), [Błąd geometrii lub danych może bezpośrednio uszkodzić zdrowe narządy.],
  [H-04], [Osoba w bunkrze podczas emisji], [Marginal], [Critical], crit("Medium"), [Wymaga naruszenia procedur i nieskutecznej blokady, ale skutki ekspozycji są krytyczne.],
  [H-05], [Kolizja gantry lub stołu], [Medium], [Serious], crit("High"), [Ruch mechaniczny występuje rutynowo w setupie; urazy mogą być ciężkie.],
  [H-07], [Brak monitorowania pacjenta], [Medium], [Serious], crit("High"), [Awaria monitoringu jest wiarygodna i usuwa ważną warstwę detekcji incydentu.],
  [H-08], [Emisja w niewłaściwym trybie], [Marginal], [Critical], crit("Medium"), [Wymaga błędu trybów lub obejścia, ale może prowadzić do niekontrolowanej ekspozycji.],
  [H-11], [Porażenie elektryczne serwisanta], [Marginal], [Critical], crit("Medium"), [Zdarzenie ograniczone do konserwacji, lecz energia wysokiego napięcia może być śmiertelna.],
  [H-13], [Wczytanie niewłaściwego planu], [Low], [Critical], crit("High"), [Wymaga błędu identyfikacji lub danych; konsekwencje dotyczą pełnej geometrii i dawki leczenia.],
)
]

= Wnioski

Najwyższą krytyczność mają zagrożenia, w których błąd danych, pozycjonowania lub pomiaru dawki może bezpośrednio przełożyć się na napromienienie pacjenta niezgodne z planem leczenia: H-01, H-03, H-05, H-07 oraz H-13. Zagrożenia H-04, H-08 i H-11 mają niższą częstość, ale wymagają szczególnie mocnych zabezpieczeń proceduralnych i sprzętowych, ponieważ ich ciężkość pozostaje krytyczna.

Najważniejsze zalecane kierunki redukcji ryzyka to:
- niezależna weryfikacja dawki i stanu Beam Off poza głównym komputerem sterującym,
- wymuszona identyfikacja pacjenta i planu leczenia bez ręcznego obejścia w normalnym trybie pracy,
- jednoznaczna separacja trybów Treatment, Setup i QA,
- okresowe testy E-Stop, blokady drzwi, krańcówek, enkoderów i toru monitoringu wideo,
- procedury LOTO i kontrola energii resztkowej podczas prac serwisowych.

= Wykorzystanie AI

Narzędzie AI zostało wykorzystane do przygotowania struktury dokumentu, rozwinięcia tabeli zagrożeń, zaproponowania scenariuszy FTA oraz dopasowania treści do opisu systemu LINAC z dokumentu `main.typ`. Wyniki zostały sformułowane jako jakościowa analiza projektowa i wymagają przeglądu zespołu pod kątem zgodności z ustaleniami przyjętymi na zajęciach.
