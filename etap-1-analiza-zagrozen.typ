#set page(
  paper: "a4",
  margin: (x: 1.8cm, y: 2.5cm),
  header-ascent: 0pt,
  header: context {
    if counter(page).get().first() == 1 {
      align(right)[
        #pad(top: 0.35cm)[
          #text(8pt, fill: luma(100))[
            Autorzy:
            \ Juliusz Radziszewski s193504
            \ Adrian Szwaczyk s193233
            \ Sebastian Kwaśniak s188807
            \ Maciej Żuralski s193367
          ]
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
  if level == "Wysokie" {
    rgb("#f4cccc")
  } else if level == "Średnie" {
    rgb("#fff2cc")
  } else if level == "Niskie" {
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
  #text(11pt)[Etap 1: Hazard analysis | Wersja: 1.3 | Data: #datetime.today().display()]
]

#line(length: 100%, stroke: 1pt + gray)
#v(1em)

= Cel i zakres analizy

Celem dokumentu jest identyfikacja zagrożeń dla medycznego akceleratora liniowego LINAC opisanego w dokumencie `main.typ`, a następnie rozwinięcie drzew błędów FTA dla ośmiu najbardziej krytycznych zagrożeń. Analiza traktuje hazard jako niebezpieczną sytuację z potencjałem szkody, a nie jako sam skutek wypadkowy.

Analiza obejmuje tryby pracy zdefiniowane w opisie systemu: tryb gotowości, pozycjonowania, terapeutyczny, kalibracji/QA oraz awaryjny. Uwzględniono źródła zagrożeń z list kontrolnych: operacyjne, środowiskowe, elektryczne, sprzętowe, programowe, mechaniczne, biologiczne oraz wynikające z nieprawidłowego użycia systemu.

== Założenia

- System jest używany w bunkrze radioterapeutycznym przez przeszkolonych elektroradiologów, a kalibracja i QA są wykonywane przez fizyków medycznych.
- W trybie terapeutycznym pacjent przebywa sam w bunkrze, a operator monitoruje procedurę z konsoli poza pomieszczeniem.
- Blokada drzwi bunkra i przyciski E-Stop są zabezpieczeniami sprzętowymi, które powinny odcinać zasilanie wysokiego napięcia niezależnie od komputera sterującego.
- Elementy FTA odnoszą się do komponentów zdefiniowanych w `main.typ`: komputera sterującego, bazy danych pacjentów, akceleratora liniowego, detektora dawki, konsoli operatora, E-Stop, blokady drzwi bunkra, kamery monitorującej, MLC, stołu pacjenta oraz silników pozycjonujących.
- Prawdopodobieństwo w tabelach jest oszacowaniem jakościowym dla realistycznej eksploatacji klinicznej, a nie dokładną wartością statystyczną.

= Słownik pojęć i skrótów

Dla zapewnienia jednoznaczności i spójności analizy, poniżej zdefiniowano kluczowe terminy i skróty techniczne używane w dokumencie oraz na schematach FTA:

- *LINAC (Linear Accelerator):* Medyczny akcelerator liniowy -- urządzenie do teleradioterapii generujące wysokoenergetyczne promieniowanie (wiązkę fotonów lub elektronów) służące do niszczenia komórek nowotworowych.
- *E-Stop (Emergency Stop):* Wyłącznik awaryjny -- sprzętowy, najwyższy priorytetowo obwód bezpieczeństwa. Jego aktywacja natychmiastowo odcina zasilanie elementów wykonawczych (np. toru wysokiego napięcia i silników) niezależnie od logiki oprogramowania.
- *MLC (Multileaf Collimator):* Kolimator wielolistkowy -- urządzenie znajdujące się w głowicy akceleratora, wyposażone w dziesiątki niezależnie sterowanych, wolframowych "listków", które kształtują wiązkę promieniowania tak, aby precyzyjnie odpowiadała obrysowi guza.
- *MU (Monitor Units):* Jednostki monitorujące -- standardowa w radioterapii miara pochłoniętej dawki promieniowania dostarczanej przez akcelerator, zliczana w czasie rzeczywistym przez sprzętowy detektor dawki (najczęściej komorę jonizacyjną).
- *Beam On / Beam Off:* Stany sterujące emisją wiązki. "Beam On" oznacza aktywną generację i dostarczanie promieniowania, natomiast "Beam Off" oznacza poprawne przerwanie lub zakończenie tego procesu.
- *Izocentrum (Isocenter):* Punkt w przestrzeni trójwymiarowej, wokół którego obracają się elementy pozycjonujące maszyny, stół oraz kolimator, wyznaczający docelowe miejsce ogniskowania wiązki wewnątrz ciała pacjenta.
- *QA (Quality Assurance):* Zapewnienie jakości -- procedury kalibracyjne i testowe wykonywane za pomocą fantomów (sztucznych modeli) przez fizyków medycznych w celu weryfikacji poprawności dozowania promieniowania.

= Skale oceny

#table(
  columns: (2.7cm, 10.8cm),
  table.header([*Poziom*], [*Znaczenie prawdopodobieństwa*]),
  [Wysoki], [Zdarzenie może wystąpić wielokrotnie w okresie eksploatacji systemu lub jest silnie zależne od typowych błędów operacyjnych.],
  [Średni], [Zdarzenie jest możliwe przy pojedynczej awarii, błędzie konfiguracji lub nieprawidłowym działaniu procedury.],
  [Niski], [Zdarzenie wymaga zbiegu kilku awarii lub błędów, ale pozostaje wiarygodne w praktyce eksploatacyjnej.],
  [Marginalne], [Zdarzenie wymaga rzadkiego zbiegu wielu niesprawności, obejść zabezpieczeń lub skrajnego naruszenia procedur.]
)

#v(0.8em)

#table(
  columns: (2.7cm, 10.8cm),
  table.header([*Poziom*], [*Znaczenie ciężkości skutków*]),
  [Krytyczny], [Śmierć pacjenta lub osoby z personelu, trwałe ciężkie obrażenia, bardzo poważne skutki radiacyjne.],
  [Poważny], [Ciężkie obrażenia, istotne pogorszenie rokowania pacjenta, duże szkody materialne lub długotrwałe przerwanie leczenia.],
  [Umiarkowany], [Przejściowy wpływ na zdrowie pacjenta, umiarkowane szkody, konieczność powtórzenia procedury lub dodatkowej diagnostyki.],
  [Marginalny], [Drobne szkody, brak istotnego wpływu na zdrowie pacjenta, lokalne zakłócenie pracy.]
)

= Macierz ryzyka

Przyjęto następującą jakościową macierz krytyczności. W każdej komórce podano najpierw poziom ryzyka, a następnie identyfikatory hazardów z danej klasy.

#table(
  columns: (auto, 2.4cm, 3cm, 3cm, 3cm, 3cm),
  align: center + horizon,
  table.cell(colspan: 2, rowspan: 2, stroke: none)[],
  table.cell(colspan: 4, fill: luma(230))[*Ciężkość*],
  table.cell(fill: luma(245))[*Marginalna*], 
  table.cell(fill: luma(245))[*Umiarkowana*], 
  table.cell(fill: luma(245))[*Poważna*], 
  table.cell(fill: luma(245))[*Krytyczna*],
  table.cell(rowspan: 4, fill: luma(230))[
    #rotate(-90deg, reflow: true)[*Prawdopodobieństwo*]
  ],
  table.cell(fill: luma(245))[*Wysoki*],
  crit("Średnie"), crit("Wysokie"), crit("Wysokie"), crit("Wysokie"),
  table.cell(fill: luma(245))[*Średni*],
  crit("Niskie"), crit("Średnie"), table.cell(fill: hazard-color("Wysokie"))[*Wysoki* \ H-05, H-07], crit("Wysokie"),
  table.cell(fill: luma(245))[*Niski*],
  crit("Niskie"), crit("Niskie"), table.cell(fill: hazard-color("Średnie"))[*Średnie* \ H-02], table.cell(fill: hazard-color("Wysokie"))[*Wysokie* \ H-01, H-03, H-06, H-09, H-10],
  table.cell(fill: luma(245))[*Marginalne*],
  crit("Marginalne"), crit("Niskie"), crit("Niskie"), table.cell(fill: hazard-color("Średnie"))[*Średni* \ H-04, H-08],
)

#v(1em)

= Identyfikacja zagrożeń

W ramach analizy zidentyfikowano 10 głównych hazardów. Definicje utrzymano na podobnym poziomie szczegółowości: każdy hazard opisuje stan systemu lub sytuację operacyjną, a nie pojedynczą przyczynę ani samą konsekwencję.

#text(size: 8.3pt)[
#table(
  columns: (0.9cm, 2.7cm, 3.8cm, 4.1cm, 1.7cm, 1.55cm, 1.55cm),
  align: (center, left, left, left, center, center, center),
  table.header(
    [*Id*], [*Nazwa hazardu*], [*Główny czynnik*], [*Konsekwencje*], [*Prawdopodo-\ bieństwo*], [*Ciężkość*], [*Krytyczność*],
  ),
  [H-01], [Nadmierna dawka promieniowania], [Błąd licznika MU w komputerze sterującym, zaniżony odczyt detektora dawki, zablokowany przekaźnik wysokiego napięcia, niepoprawna wartość dawki w planie.], [Oparzenia popromienne, martwica tkanek, poważne uszkodzenie narządów lub śmierć pacjenta.], [Niskie], [Krytyczna], crit("Wysokie"),
  [H-02], [Zbyt niska dawka terapeutyczna], [Przedwczesne wyłączenie wiązki, awaria akceleratora, błędna kalibracja dawki, niepełne wykonanie frakcji lub błędna wartość dawki w planie.], [Nieskuteczne leczenie nowotworu, progresja choroby, konieczność powtórzenia terapii.], [Niskie], [Poważna], crit("Średnie"),
  [H-03], [Napromienienie niewłaściwego obszaru pacjenta], [Błędne pozycjonowanie stołu lub silników pozycjonujących, zły plan pacjenta, błąd transformacji współrzędnych, ruch pacjenta podczas emisji.], [Napromienienie zdrowych tkanek i niedostarczenie dawki do guza; możliwe trwałe obrażenia lub śmierć.], [Niskie], [Krytyczna], crit("Wysokie"),
  [H-04], [Osoba znajduje się w bunkrze podczas emisji wiązki], [Błąd operatora, obejście blokady drzwi, nieskuteczna kontrola obecności, awaria sygnalizacji lub monitoringu.], [Nieplanowana ekspozycja personelu lub osoby postronnej na promieniowanie jonizujące.], [Marginalne], [Krytyczna], crit("Średnie"),
  [H-05], [Kolizja elementów ruchomych (stołu pacjenta lub układu silników) z człowiekiem], [Niewłaściwe wysterowanie silników pozycjonujących przez komputer sterujący, awaria sprzętowa silników lub stołu pacjenta, błąd elektroradiologa w trybie pozycjonowania.], [Zmiażdżenie, złamania, urazy głowy lub uszkodzenie sprzętu.], [Średnie], [Poważna], crit("Wysokie"),
  [H-06], [Nieprawidłowy kształt pola promieniowania], [Zacięcie listków MLC, błąd sterowania MLC, utrata informacji zwrotnej o pozycji listków, użycie niewłaściwej konfiguracji pola.], [Napromienienie zdrowych tkanek, niedostateczna dawka w części guza lub uszkodzenie narządu krytycznego.], [Niskie], [Krytyczna], crit("Wysokie"),
  [H-07], [Brak skutecznego monitorowania pacjenta podczas emisji], [Awaria kamery, zamrożenie obrazu na konsoli, opóźnienie transmisji, nieuwaga operatora, brak alarmu utraty wideo.], [Ruch pacjenta lub pogorszenie stanu nie zostają wykryte, co może prowadzić do błędnej ekspozycji albo opóźnienia reakcji.], [Średnie], [Poważna], crit("Wysokie"),
  [H-08], [Emisja wiązki w niewłaściwym trybie pracy], [Błąd logiki trybów, pozostawiony tryb kalibracji, obejście kontroli dostępu, użycie planu QA przy obecnym pacjencie.], [Nieautoryzowana lub niekontrolowana emisja promieniowania poza zatwierdzoną procedurą terapeutyczną.], [Marginalne], [Krytyczna], crit("Średnie"),
  [H-09], [Nieskuteczne zatrzymanie awaryjne], [Awaria przycisku E-Stop, zablokowany obwód odcięcia zasilania, awaria przekaźnika bezpieczeństwa.], [System nie przerywa emisji promieniowania lub ruchu mimo wyzwolenia E-Stop, eskalacja wypadku.], [Niskie], [Krytyczna], crit("Wysokie"),
  [H-10], [Wczytanie niewłaściwego planu pacjenta], [Błędna identyfikacja pacjenta, pomyłka w bazie danych, niezatwierdzona wersja planu, nieskuteczna weryfikacja na konsoli.], [Podanie dawki i geometrii leczenia przeznaczonej dla innego pacjenta lub innej frakcji.], [Niskie], [Krytyczna], crit("Wysokie"),
)
]

= Wybrane zagrożenia do analizy FTA

Zidentyfikowane zagrożenia poddano selekcji i do dalszej analizy wybrano 8 z nich: H-01, H-03, H-05, H-06, H-07, H-08, H-09 oraz H-10. Dobór obejmuje różne klasy zagrożeń: radiacyjne, mechaniczne, programowe, ludzkie, środowiskowo-organizacyjne i elektryczne. Zespół liczy 4 osoby, co spełnia wymóg wytypowania dwóch hazardów na członka zespołu.

W drzewach FTA zastosowano następujące oznaczenia:
- `OR` oznacza, że wystarczy jedno zdarzenie podrzędne.
- `AND` oznacza, że muszą zajść wszystkie zdarzenia podrzędne w danej gałęzi.
- `BE` oznacza zdarzenie bazowe.

== FTA H-01: Nadmierna dawka promieniowania

#figure(
  image("figures/fta-h01.jpg", width: 100%),
  caption: [Drzewo FTA dla H-01],
)

Scenariusz H-01 jest krytyczny, ponieważ pojedyncza awaria pomiaru dawki może zostać wzmocniona przez brak niezależnego zatrzymania wiązki albo błędną reakcję operatora. Kluczowe komponenty to komputer sterujący, detektor dawki, akcelerator liniowy, konsola operatora i E-Stop.

== FTA H-03: Napromienienie niewłaściwego obszaru pacjenta

#figure(
  image("figures/fta-h03.jpg", width: 100%),
  caption: [Drzewo FTA dla H-03],
)

W tym scenariuszu ważne są zarówno błędy sprzętowe pozycjonowania, jak i błędy danych terapeutycznych. Nawet poprawnie działająca wiązka staje się niebezpieczna, jeżeli izocentrum lub plan leczenia nie odpowiadają rzeczywistej pozycji pacjenta.

== FTA H-05: Kolizja elementów ruchomych z człowiekiem

#figure(
  image("figures/fta-h05.jpg", width: 100%),
  caption: [Drzewo FTA dla H-05],
)

Najbardziej ryzykowne fazy dla H-05 to pozycjonowanie i prace serwisowe, ponieważ w bunkrze może przebywać człowiek, a system pozwala na ruch stołu, obroty maszyny lub innych elementów pozycjonujących.

== FTA H-06: Nieprawidłowy kształt pola promieniowania

#figure(
  image("figures/fta-h06.jpg", width: 100%),
  caption: [Drzewo FTA dla H-06],
)

H-06 jest osobnym hazardem względem H-03, ponieważ pacjent może być poprawnie ułożony, ale samo pole promieniowania może mieć błędny kształt. Najważniejsze komponenty to MLC, komputer sterujący, baza danych pacjentów i konsola operatora.

== FTA H-07: Brak skutecznego monitorowania pacjenta podczas emisji

#figure(
  image("figures/fta-h07.jpg", width: 100%),
  caption: [Drzewo FTA dla H-07],
)

H-07 nie musi bezpośrednio oznaczać wypadku, ale usuwa istotną warstwę detekcji. W połączeniu z ruchem pacjenta, pogorszeniem stanu zdrowia lub awarią pozycjonowania może prowadzić do H-03 albo opóźnionego zatrzymania wiązki.

== FTA H-08: Emisja wiązki promieniowania w niewłaściwym trybie pracy

#figure(
  image("figures/fta-h08.jpg", width: 100%),
  caption: [Drzewo FTA dla H-08],
)

Zagrożenie H-08 uwzględnia naruszenie logiki stanów maszyny (np. emisja podczas pozycjonowania, w trybie gotowości albo przy błędnym kontekście QA). Kluczowe jest tu prawidłowe działanie blokady drzwi, separacji trybów QA/serwis/Treatment oraz warunków dopuszczenia Beam On przez komputer sterujący i akcelerator liniowy.

== FTA H-09: Nieskuteczne zatrzymanie awaryjne

#figure(
  image("figures/fta-h09.jpg", width: 100%),
  caption: [Drzewo FTA dla H-09],
)

H-09 jest krytyczny, bo E-Stop stanowi ostatnią barierę dla hazardów radiacyjnych i mechanicznych. Drzewo rozróżnia brak skutecznej aktywacji E-Stop, awarię toru odcięcia energii oraz brak przejścia elementów wykonawczych do stanu bezpiecznego.

== FTA H-10: Wczytanie niewłaściwego planu pacjenta

#figure(
  image("figures/fta-h10.jpg", width: 100%),
  caption: [Drzewo FTA dla H-10],
)

#pagebreak()

= Wnioski

Najwyższą krytyczność mają zagrożenia, w których błąd danych, pozycjonowania lub pomiaru dawki może bezpośrednio przełożyć się na napromienienie pacjenta niezgodne z planem leczenia: H-01, H-03, H-05, H-07 oraz H-09. Zagrożenia H-04, H-08 i H-10 mają niższą częstość i często charakteryzują się większym udziałem błędu proceduralnego, ale wymagają szczególnie mocnych zabezpieczeń systemowych i walidacyjnych ze względu na swoją krytyczną ciężkość skutków.

Najważniejsze zalecane kierunki redukcji ryzyka to:
- niezależna weryfikacja dawki i stanu Beam Off poza głównym komputerem sterującym,
- wymuszona identyfikacja pacjenta i planu leczenia bez ręcznego obejścia w normalnym trybie pracy,
- jednoznaczna separacja trybów Treatment, Setup i QA na poziomie sprzętowym i programowym,
- sprzętowa blokada emisji przy braku statusu MLC Ready,
- okresowe testy E-Stop, blokady drzwi, krańcówek i toru monitoringu wideo,
- procedury kontroli energii resztkowej podczas prac serwisowych.

= Wykorzystanie AI (AI usage)

Poniżej przedstawiono zakres wykorzystania narzędzi sztucznej inteligencji w procesie przygotowania raportu:

a) *Zakres wykorzystania:*
Sztuczna inteligencja została wykorzystana jako wsparcie w zakresie specjalistycznej wiedzy medycznej dotyczącej radioterapii, przy porządkowaniu listy hazardów, dopracowaniu opisów przyczyn i konsekwencji oraz przygotowaniu jakościowej analizy FTA dla wybranych zagrożeń. Narzędzia AI pomogły również w sprawdzeniu spójności dokumentu z opisem systemu, ujednoliceniu terminologii dotyczącej komponentów LINAC oraz ogólnym formatowaniu raportu w języku Typst.

b) *Weryfikacja wyników:*
Wszystkie informacje przygotowane przy wsparciu AI zostały poddane ręcznej weryfikacji przez zespół projektowy. Sprawdzono, czy hazardy odnoszą się do komponentów i trybów pracy przyjętych w opisie systemu, czy nie są mylone z bezpośrednimi skutkami wypadkowymi oraz czy drzewa FTA zachowują logiczną zgodność z przyjętymi założeniami analizy bezpieczeństwa.
