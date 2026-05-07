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
  #text(11pt)[Etap 1: Hazard analysis | Wersja: 1.1 | Data: #datetime.today().display()]
]

#line(length: 100%, stroke: 1pt + gray)
#v(1em)

= Cel i zakres analizy

Celem dokumentu jest identyfikacja zagrożeń dla medycznego akceleratora liniowego LINAC opisanego w dokumencie `main.typ`, a następnie rozwinięcie drzew błędów FTA dla siedmiu najbardziej krytycznych zagrożeń. Analiza traktuje hazard jako niebezpieczną sytuację z potencjałem szkody, a nie jako sam skutek wypadkowy.

Analiza obejmuje tryby pracy zdefiniowane w opisie systemu: tryb gotowości, pozycjonowania, terapeutyczny, kalibracji/QA oraz awaryjny. Uwzględniono źródła zagrożeń z list kontrolnych: operacyjne, środowiskowe, elektryczne, sprzętowe, programowe, mechaniczne, biologiczne oraz wynikające z nieprawidłowego użycia systemu.

== Założenia

- System jest używany w bunkrze radioterapeutycznym przez przeszkolonych elektroradiologów, a kalibracja i QA są wykonywane przez fizyków medycznych.
- W trybie terapeutycznym pacjent przebywa sam w bunkrze, a operator monitoruje procedurę z konsoli poza pomieszczeniem.
- Blokada drzwi bunkra i przyciski E-Stop są zabezpieczeniami sprzętowymi, które powinny odcinać zasilanie wysokiego napięcia niezależnie od komputera sterującego.
- Elementy FTA odnoszą się do komponentów zdefiniowanych w `main.typ`: komputera sterującego, bazy danych pacjentów, akceleratora liniowego, detektora dawki, konsoli operatora, E-Stop, blokady drzwi bunkra, kamery monitorującej, MLC, stołu pacjenta oraz silników pozycjonujących.
- Prawdopodobieństwo w tabelach jest oszacowaniem jakościowym dla realistycznej eksploatacji klinicznej, a nie dokładną wartością statystyczną.

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

Zgodnie z instrukcją etapu zidentyfikowano 10 hazardów, czyli nie przekroczono górnego limitu. Definicje utrzymano na podobnym poziomie szczegółowości: każdy hazard opisuje stan systemu lub sytuację operacyjną, a nie pojedynczą przyczynę ani samą konsekwencję.

#text(size: 8.3pt)[
#table(
  columns: (0.9cm, 2.75cm, 4.05cm, 4.05cm, 1.55cm, 1.55cm, 1.55cm),
  align: (center, left, left, left, center, center, center),
  table.header(
    [*Id*], [*Hazard name*], [*Main causes*], [*Consequences*], [*Likelihood*], [*Severity*], [*Criticality*],
  ),
  [H-01], [Nadmierna dawka promieniowania], [Błąd licznika MU w komputerze sterującym, zaniżony odczyt detektora dawki, zablokowany przekaźnik wysokiego napięcia, niepoprawna wartość dawki w planie.], [Oparzenia popromienne, martwica tkanek, poważne uszkodzenie narządów lub śmierć pacjenta.], [Low], [Critical], crit("High"),
  [H-02], [Zbyt niska dawka terapeutyczna], [Przedwczesne wyłączenie wiązki, awaria akceleratora, błędna kalibracja dawki, niepełne wykonanie frakcji lub błędna wartość dawki w planie.], [Nieskuteczne leczenie nowotworu, progresja choroby, konieczność powtórzenia terapii.], [Low], [Serious], crit("Medium"),
  [H-03], [Napromienienie niewłaściwego obszaru pacjenta], [Błędne pozycjonowanie stołu lub gantry, zły plan pacjenta, błąd transformacji współrzędnych, ruch pacjenta podczas emisji.], [Napromienienie zdrowych tkanek i niedostarczenie dawki do guza; możliwe trwałe obrażenia lub śmierć.], [Low], [Critical], crit("High"),
  [H-04], [Osoba znajduje się w bunkrze podczas emisji wiązki], [Błąd operatora, obejście blokady drzwi, nieskuteczna kontrola obecności, awaria sygnalizacji lub monitoringu.], [Nieplanowana ekspozycja personelu lub osoby postronnej na promieniowanie jonizujące.], [Marginal], [Critical], crit("Medium"),
  [H-05], [Kolizja gantry lub stołu z pacjentem albo operatorem], [Awaria krańcówek, błędne enkodery, niekontrolowane polecenie ruchu, błąd operatora w trybie pozycjonowania albo serwisowym.], [Zmiażdżenie, złamania, urazy głowy lub uszkodzenie sprzętu.], [Medium], [Serious], crit("High"),
  [H-06], [Nieprawidłowy kształt pola promieniowania], [Zacięcie listków MLC, błąd sterowania MLC, utrata informacji zwrotnej o pozycji listków, użycie niewłaściwej konfiguracji pola.], [Napromienienie zdrowych tkanek, niedostateczna dawka w części guza lub uszkodzenie narządu krytycznego.], [Low], [Critical], crit("High"),
  [H-07], [Brak skutecznego monitorowania pacjenta podczas emisji], [Awaria kamery, zamrożenie obrazu na konsoli, opóźnienie transmisji, nieuwaga operatora, brak alarmu utraty wideo.], [Ruch pacjenta lub pogorszenie stanu nie zostają wykryte, co może prowadzić do błędnej ekspozycji albo opóźnienia reakcji.], [Medium], [Serious], crit("High"),
  [H-08], [Emisja wiązki w niewłaściwym trybie pracy], [Błąd logiki trybów, pozostawiony tryb kalibracji, obejście kontroli dostępu, użycie planu QA przy obecnym pacjencie.], [Nieautoryzowana lub niekontrolowana emisja promieniowania poza zatwierdzoną procedurą terapeutyczną.], [Marginal], [Critical], crit("Medium"),
  [H-09], [Nieskuteczne zatrzymanie awaryjne], [Awaria E-Stop, zespawany przekaźnik, błąd okablowania obwodu bezpieczeństwa, brak testu okresowego.], [Brak możliwości natychmiastowego przerwania emisji lub ruchu mechanicznego podczas incydentu.], [Low], [Critical], crit("High"),
  [H-13], [Wczytanie niewłaściwego planu pacjenta], [Błędna identyfikacja pacjenta, pomyłka w bazie danych, niezatwierdzona wersja planu, nieskuteczna weryfikacja na konsoli.], [Podanie dawki i geometrii leczenia przeznaczonej dla innego pacjenta lub innej frakcji.], [Low], [Critical], crit("High"),
)
]

= Wybrane zagrożenia do analizy FTA

Zgodnie z wymaganiem przygotowano drzewa FTA dla 7 najbardziej krytycznych hazardów: H-01, H-03, H-05, H-06, H-07, H-09 oraz H-13. Dobór obejmuje hazardy o krytyczności `High`, które bezpośrednio dotyczą dawki, geometrii wiązki, pozycjonowania, monitorowania pacjenta, zatrzymania awaryjnego i poprawności planu leczenia.

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

== FTA H-05: Kolizja gantry lub stołu z pacjentem albo operatorem

#figure(
  image("figures/fta-h05.jpg", width: 100%),
  caption: [Drzewo FTA dla H-05],
)

Najbardziej ryzykowne fazy dla H-05 to pozycjonowanie i prace serwisowe, ponieważ w bunkrze może przebywać człowiek, a system pozwala na ruch stołu, gantry lub elementów pozycjonujących.

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

== FTA H-09: Nieskuteczne zatrzymanie awaryjne

#figure(
  image("figures/fta-h09.jpg", width: 100%),
  caption: [Drzewo FTA dla H-09],
)

H-09 jest krytyczny, bo E-Stop stanowi ostatnią barierę dla hazardów radiacyjnych i mechanicznych. Drzewo rozróżnia awarię samego przycisku, awarię toru odcięcia energii oraz błędne przywrócenie systemu do pracy.

== FTA H-13: Wczytanie niewłaściwego planu pacjenta

#figure(
  image("figures/fta-h13.jpg", width: 100%),
  caption: [Drzewo FTA dla H-13],
)

#pagebreak()

= Macierz ryzyka

Przyjęto następującą jakościową macierz krytyczności. W każdej komórce podano najpierw poziom ryzyka, a następnie identyfikatory hazardów z danej klasy.

#table(
  columns: (2.4cm, 3cm, 3cm, 3cm, 3cm),
  align: (center, center, center, center, center),
  table.header([*Likelihood \\ Severity*], [*Marginal*], [*Moderate*], [*Serious*], [*Critical*]),
  [*High*], crit("Medium"), crit("High"), crit("High"), crit("High"),
  [*Medium*], crit("Low"), crit("Medium"), table.cell(fill: hazard-color("High"))[*High* \ H-05, H-07], crit("High"),
  [*Low*], crit("Low"), crit("Low"), table.cell(fill: hazard-color("Medium"))[*Medium* \ H-02], table.cell(fill: hazard-color("High"))[*High* \ H-01, H-03, H-06, H-09, H-13],
  [*Marginal*], crit("Marginal"), crit("Low"), crit("Low"), table.cell(fill: hazard-color("Medium"))[*Medium* \ H-04, H-08],
)

#v(1em)

#text(size: 8.8pt)[
#table(
  columns: (1.1cm, 3.45cm, 1.8cm, 1.8cm, 1.8cm, 5.45cm),
  align: (center, left, center, center, center, left),
  table.header([*Id*], [*Hazard*], [*Likelihood*], [*Severity*], [*Risk*], [*Uzasadnienie oceny*]),
  [H-01], [Nadmierna dawka promieniowania], [Low], [Critical], crit("High"), [Wymaga awarii kontroli dawki, ale skutki radiacyjne są potencjalnie śmiertelne.],
  [H-02], [Zbyt niska dawka terapeutyczna], [Low], [Serious], crit("Medium"), [Skutki są poważne, ale zwykle ujawniają się przez brak skuteczności leczenia, a nie przez natychmiastowy uraz.],
  [H-03], [Napromienienie niewłaściwego obszaru], [Low], [Critical], crit("High"), [Błąd geometrii lub danych może bezpośrednio uszkodzić zdrowe narządy.],
  [H-04], [Osoba w bunkrze podczas emisji], [Marginal], [Critical], crit("Medium"), [Wymaga naruszenia procedur i nieskutecznej blokady, ale skutki ekspozycji są krytyczne.],
  [H-05], [Kolizja gantry lub stołu], [Medium], [Serious], crit("High"), [Ruch mechaniczny występuje rutynowo w setupie; urazy mogą być ciężkie.],
  [H-06], [Nieprawidłowy kształt pola], [Low], [Critical], crit("High"), [Błąd MLC może napromienić narządy krytyczne mimo poprawnego ułożenia pacjenta.],
  [H-07], [Brak monitorowania pacjenta], [Medium], [Serious], crit("High"), [Awaria monitoringu jest wiarygodna i usuwa ważną warstwę detekcji incydentu.],
  [H-08], [Emisja w niewłaściwym trybie], [Marginal], [Critical], crit("Medium"), [Wymaga błędu trybów lub obejścia, ale może prowadzić do niekontrolowanej ekspozycji.],
  [H-09], [Nieskuteczne zatrzymanie awaryjne], [Low], [Critical], crit("High"), [E-Stop jest ostatnią barierą dla emisji i ruchu; jego nieskuteczność może być śmiertelna.],
  [H-13], [Wczytanie niewłaściwego planu], [Low], [Critical], crit("High"), [Błąd identyfikacji lub danych wpływa jednocześnie na dawkę, geometrię i konfigurację MLC.],
)
]

= Wnioski

Najwyższą krytyczność mają zagrożenia, w których błąd danych, pozycjonowania, kształtowania wiązki, pomiaru dawki albo zatrzymania awaryjnego może bezpośrednio przełożyć się na napromienienie pacjenta niezgodne z planem leczenia: H-01, H-03, H-06, H-09 oraz H-13. Wysoką krytyczność mają też H-05 i H-07, ponieważ dotyczą rutynowych czynności klinicznych i usuwają istotne bariery ochronne.

Najważniejsze zalecane kierunki redukcji ryzyka to:
- niezależna weryfikacja dawki i stanu Beam Off poza głównym komputerem sterującym,
- wymuszona identyfikacja pacjenta i planu leczenia bez ręcznego obejścia w normalnym trybie pracy,
- jednoznaczna separacja trybów Treatment, Setup i QA,
- sprzętowa blokada emisji przy braku statusu MLC Ready,
- okresowe testy E-Stop, blokady drzwi, krańcówek, enkoderów i toru monitoringu wideo,
- procedury kontroli energii resztkowej podczas prac serwisowych.

= Wykorzystanie AI

Narzędzie AI zostało wykorzystane do przeglądu zgodności dokumentu z instrukcją `Project Task 1 Guidelines - Track 1.pdf`, uporządkowania listy hazardów, dopracowania drzew FTA oraz sprawdzenia spójności z opisem systemu w `main.typ`. Wyniki zostały sformułowane jako jakościowa analiza projektowa i wymagają przeglądu zespołu pod kątem zgodności z ustaleniami przyjętymi na zajęciach.
