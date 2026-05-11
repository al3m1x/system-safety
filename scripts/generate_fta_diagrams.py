#!/usr/bin/env python3
from pathlib import Path
import textwrap

from PIL import Image, ImageDraw, ImageFont
import platform

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "figures"

if platform.system() == "Windows":
    FONT = "C:/Windows/Fonts/arial.ttf"
    BOLD = "C:/Windows/Fonts/arialbd.ttf"
else:
    FONT = "/System/Library/Fonts/Supplemental/Arial.ttf"
    BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"

TREES = {
    "h01": { 
        "top": ("H-01 TOP", "Nadmierna dawka promieniowania dostarczona pacjentowi"),
        "gate": "OR",
        "branches": [
            ("G-H01-A", "System nie wstrzymuje automatycznie wiązki", "OR", [
                ("BE-H01-01", "Komputer sterujący błędnie zlicza Monitor Units (MU)"),
                ("BE-H01-02", "Komputer sterujący zawiesza się przed wysłaniem komendy Beam Off"),
                # ZAGŁĘBIENIE 4 POZIOMU - z użyciem głównego bloku (Akceleratora)
                ("G-H01-A1", "Akcelerator liniowy podtrzymuje emisję niezależnie", "OR", [
                    ("BE-H01-03", "Akcelerator liniowy ignoruje sprzętowy sygnał odcięcia od Komputera"),
                    ("BE-H01-04", "Akcelerator liniowy ulega awarii i generuje wiązkę spontanicznie"),
                ]),
            ]),
            ("G-H01-B", "Zaniżony pomiar dostarczanej dawki", "OR", [
                ("BE-H01-05", "Detektor dawki ulega nasyceniu przy wysokiej mocy wiązki"),
                ("BE-H01-06", "Detektor dawki traci kalibrację z powodu awarii pomiarowej"),
                ("BE-H01-07", "Komputer sterujący błędnie interpretuje sygnał z Detektora"),
            ]),
            ("G-H01-C", "Brak reakcji na stanowisku operatorskim", "AND", [
                ("BE-H01-08", "Konsola operatora ulega awarii i nie wyświetla stanu dawki"),
                ("BE-H01-09", "Wyłącznik awaryjny (E-Stop) blokuje się w pozycji zwartej"),
            ]),
        ],
    },
    "h03": { 
        "top": ("H-03 TOP", "Wiązka promieniowania trafia poza planowany obszar guza"),
        "gate": "OR",
        "branches": [
            ("G-H03-A", "Błędne ułożenie mechaniczne", "OR", [
                ("BE-H03-01", "System laserów pozycjonujących rzuca przesunięte izocentrum"),
                ("BE-H03-02", "Stół pacjenta przemieszcza się do błędnych współrzędnych"),
                ("BE-H03-03", "Silniki pozycjonujące obracają maszynę pod błędnym kątem"),
                ("BE-H03-04", "Elektroradiolog układa pacjenta niezgodnie ze znacznikami laserów"),
            ]),
            ("G-H03-B", "Niewłaściwe dane geometryczne w systemie", "OR", [
                ("BE-H03-05", "Baza danych pacjentów dostarcza uszkodzony plik planu"),
                ("BE-H03-06", "Komputer sterujący błędnie transformuje osie maszyny z planu"),
            ]),
            ("G-H03-C", "Brak sprzętowego przerwania podczas ruchu", "AND", [
                ("BE-H03-07", "Kamera monitorująca maskuje przemieszczenie (opóźnienie obrazu)"),
                ("BE-H03-08", "Elektroradiolog nie wciska Wyłącznika awaryjnego (E-Stop) na czas"),
                ("BE-H03-09", "Pacjent zsuwa się na Stole pacjenta w trakcie naświetlania"),
            ]),
        ],
    },
    "h05": { 
        "top": ("H-05 TOP", "Ruchomy element LINAC powoduje kolizję z człowiekiem"),
        "gate": "OR",
        "branches": [
            ("G-H05-A", "Awaria sprzętowa podczas ruchu zautomatyzowanego", "OR", [
                ("BE-H05-01", "Komputer sterujący wysyła błędny wektor ruchu zagrażający kolizją"),
                ("BE-H05-02", "Silniki pozycjonujące ignorują sprzętowy sygnał zatrzymania"),
                ("BE-H05-03", "Stół pacjenta przemieszcza się samoczynnie wskutek własnej awarii"),
                ("BE-H05-04", "Utrata zasilania z Sieci powoduje swobodny opad elementów maszyny"),
            ]),
            ("G-H05-B", "Błąd w trybie sterowania ręcznego", "AND", [
                ("BE-H05-05", "Elektroradiolog na Konsoli wymusza ruch o zbyt dużym skoku"),
                ("BE-H05-06", "Kamera monitorująca nie obejmuje punktu zbliżenia w swoim polu"),
                ("BE-H05-07", "Elektroradiolog ignoruje procedurę sprawdzania odstępu w bunkrze"),
            ]),
        ],
    },
    "h06": { 
        "top": ("H-06 TOP", "Pole promieniowania ma kształt inny niż zapisany w planie"),
        "gate": "OR",
        "branches": [
            ("G-H06-A", "Fizyczna awaria sprzętu kształtującego", "OR", [
                ("BE-H06-01", "Kolimator (MLC) fizycznie blokuje listki w błędnej pozycji"),
                ("BE-H06-02", "Kolimator (MLC) wysyła fałszywą informację zwrotną o swojej pozycji"),
            ]),
            ("G-H06-B", "Błąd sterowania lub wizualizacji kształtu", "OR", [
                ("BE-H06-03", "Baza danych pacjentów wysyła przestarzałą sekwencję listków"),
                ("BE-H06-04", "Komputer sterujący generuje błędne sygnały sterujące dla MLC"),
                ("BE-H06-05", "Komputer sterujący gubi synchronizację ruchu MLC z dawką"),
            ]),
            ("G-H06-C", "Brak reakcji na zaistniałą niezgodność", "AND", [
                ("BE-H06-06", "Konsola operatora nie wyświetla alarmu o błędzie kształtu"),
                ("BE-H06-07", "Elektroradiolog akceptuje błędny zarys pola na Konsoli operatora"),
            ]),
        ],
    },
    "h07": { 
        "top": ("H-07 TOP", "Pacjent nie jest skutecznie monitorowany podczas aktywnej emisji"),
        "gate": "OR",
        "branches": [
            ("G-H07-A", "Brak obrazu wideo z wnętrza bunkra", "OR", [
                ("BE-H07-01", "Kamera monitorująca ulega awarii sprzętowej lub traci zasilanie"),
                ("BE-H07-02", "Awaria Sieci zasilającej powoduje zgaśnięcie oświetlenia w bunkrze"),
                ("BE-H07-03", "Kamera monitorująca zostaje zasłonięta przez ruch Silników pozycjonujących"),
                ("BE-H07-04", "Komputer sterujący zatrzymuje przetwarzanie strumienia z Kamery"),
            ]),
            ("G-H07-B", "Brak odczytu wizualnego na stanowisku", "OR", [
                ("BE-H07-05", "Konsola operatora zamraża klatkę bez wyświetlenia komunikatu błędu"),
                ("BE-H07-06", "Konsola operatora ulega całkowitej awarii ekranu"),
                ("BE-H07-07", "Elektroradiolog opuszcza stanowisko przy Konsoli podczas emisji"),
            ]),
        ],
    },
    "h08": { 
        "top": ("H-08 TOP", "Emisja wiązki promieniowania w niewłaściwym trybie pracy"),
        "gate": "OR",
        "branches": [
            ("G-H08-A", "Emisja przy obecności personelu w bunkrze", "AND", [
                ("BE-H08-01", "Blokada drzwi bunkra nie sygnalizuje otwarcia do Komputera"),
                ("BE-H08-02", "Elektroradiolog celowo omija zabezpieczenia z poziomu Konsoli"),
                ("BE-H08-03", "Komputer sterujący zezwala na emisję mimo braku sygnału z Blokady"),
            ]),
            ("G-H08-B", "Błędny tryb terapeutyczny zamiast serwisowego", "AND", [
                ("BE-H08-04", "Fizyk medyczny pozostawia Komputer sterujący w trybie serwisowym"),
                ("BE-H08-05", "Baza danych pacjentów podmienia plan terapeutyczny na kalibracyjny"),
                ("BE-H08-06", "Komputer sterujący ignoruje zabezpieczenia trybu klinicznego"),
            ]),
            ("G-H08-C", "Emisja w Trybie gotowości (Idle)", "AND", [
                ("BE-H08-07", "Akcelerator liniowy ulega awarii i generuje wiązkę spontanicznie"),
                ("BE-H08-08", "Komputer sterujący błędnie interpretuje stan jako gotowy do emisji"),
            ]),
        ],
    },
    "h09": { 
        "top": ("H-09 TOP", "Aktywacja Wyłącznika awaryjnego (E-Stop) nie odcina systemu"),
        "gate": "OR",
        "branches": [
            ("G-H09-A", "Brak wyzwolenia sygnału z urządzenia", "OR", [
                ("BE-H09-01", "Wyłącznik awaryjny (E-Stop) blokuje się mechanicznie podczas wciskania"),
                ("BE-H09-02", "Elektroradiolog nie ma dostępu do Wyłącznika awaryjnego w bunkrze"),
                ("BE-H09-03", "Wyłącznik awaryjny (E-Stop) nie przerywa obwodu z powodu uszkodzenia"),
                ("BE-H09-04", "Elektroradiolog w panice opuszcza Konsolę nie wciskając Wyłącznika"),
            ]),
            ("G-H09-B", "Ignorowanie zatrzymania awaryjnego przez system", "OR", [
                ("BE-H09-05", "Komputer sterujący ignoruje programowy sygnał od Wyłącznika"),
                ("BE-H09-06", "Konsola operatora opóźnia przekazanie sygnału awaryjnego"),
                # ZAGŁĘBIENIE 4 POZIOMU - z użyciem głównych bloków omijających E-Stop
                ("G-H09-B1", "Elementy wykonawcze maszyny omijają fizyczny sygnał E-Stop", "OR", [
                    ("BE-H09-07", "Akcelerator liniowy nie przerywa emisji mimo rozłączenia sprzętowego"),
                    ("BE-H09-08", "Silniki pozycjonujące kontynuują ruch bez zasilania z obwodu E-Stop"),
                ]),
            ]),
        ],
    },
    "h10": { 
        "top": ("H-10 TOP", "Wczytanie planu nieodpowiadającego aktualnemu pacjentowi"),
        "gate": "AND",
        "branches": [
            ("G-H10-A", "System udostępnia niewłaściwe dane", "OR", [
                ("BE-H10-01", "Baza danych pacjentów paruje identyfikator z błędnym rekordem"),
                ("BE-H10-02", "Baza danych pacjentów wysyła starszą wersję planu zamiast aktualnej"),
                ("BE-H10-03", "Komputer sterujący wczytuje plan poprzedniego pacjenta z pamięci"),
            ]),
            ("G-H10-B", "Luki w procesie weryfikacji tożsamości", "OR", [
                ("BE-H10-04", "Lekarz nie weryfikuje ostatecznego planu w Bazie danych pacjentów"),
                ("BE-H10-05", "Konsola operatora błędnie formatuje i ucina identyfikator pacjenta"),
                ("BE-H10-06", "Elektroradiolog pomija potwierdzenie tożsamości na Konsoli"),
                ("BE-H10-07", "Pacjent reaguje na nieswoje nazwisko podane przez Elektroradiologa"),
            ]),
        ],
    },
}

def font(size, bold=False):
    path = BOLD if bold else FONT
    return ImageFont.truetype(path, size) if Path(path).exists() else ImageFont.load_default()

def wrap(draw, text, fnt, width):
    words, lines, line = text.split(), [], ""
    for word in words:
        trial = f"{line} {word}".strip()
        if line and draw.textbbox((0, 0), trial, font=fnt)[2] > width:
            lines.append(line)
            line = word
        else:
            line = trial
    return lines + ([line] if line else [])

def box(draw, rect, ident, text, fnt, bold_fnt):
    x1, y1, x2, y2 = rect
    draw.rounded_rectangle(rect, radius=8, fill="#fff2cc", outline="#1f4e79", width=4)
    lines = [ident] + wrap(draw, text, fnt, x2 - x1 - 36)
    heights = [draw.textbbox((0, 0), s, font=(bold_fnt if i == 0 else fnt))[3] for i, s in enumerate(lines)]
    y = y1 + ((y2 - y1) - sum(heights) - 8 * (len(lines) - 1)) / 2
    for i, line in enumerate(lines):
        current = bold_fnt if i == 0 else fnt
        w = draw.textbbox((0, 0), line, font=current)[2]
        draw.text((x1 + (x2 - x1 - w) / 2, y), line, font=current, fill="#111111")
        y += heights[i] + 8

def gate(draw, center, label, fnt):
    x, y = center
    draw.ellipse((x - 48, y - 30, x + 48, y + 30), fill="#d9ead3", outline="#1f4e79", width=4)
    w = draw.textbbox((0, 0), label, font=fnt)[2]
    draw.text((x - w / 2, y - 14), label, font=fnt, fill="#111111")

def line(draw, a, b):
    draw.line((*a, *b), fill="#1f4e79", width=4)

def render(name, tree):
    img = Image.new("RGB", (2400, 2200), "white")
    draw = ImageDraw.Draw(img)
    f18, f20, f22b, f28b = font(18), font(20), font(22, True), font(28, True)

    draw.text((70, 45), f"FTA {tree['top'][0].split()[0]}", font=f28b, fill="#111111")

    gate_radius_y = 30
    top = (650, 105, 1750, 215)
    box(draw, top, *tree["top"], f20, f22b)

    top_gate = (1200, 320)
    branch_bus_y = 395
    branch_top_y = 465
    branch_bottom_y = 575
    branch_gate_y = 680

    line(draw, (1200, top[3]), (1200, top_gate[1] - gate_radius_y))
    gate(draw, top_gate, tree["gate"], f22b)
    line(draw, (1200, top_gate[1] + gate_radius_y), (1200, branch_bus_y))

    num_branches = len(tree["branches"])
    centers = [2400 * (i + 0.5) / num_branches for i in range(num_branches)]
    
    line(draw, (centers[0], branch_bus_y), (centers[-1], branch_bus_y))
    box_w = min(660, (2400 / num_branches) - 60)

    for cx, (gid, title, gtype, basics) in zip(centers, tree["branches"]):
        branch = (cx - box_w / 2, branch_top_y, cx + box_w / 2, branch_bottom_y)
        
        line(draw, (cx, branch_bus_y), (cx, branch[1]))
        box(draw, branch, gid, title, f18, f22b)
        
        line(draw, (cx, branch[3]), (cx, branch_gate_y - gate_radius_y))
        gate(draw, (cx, branch_gate_y), gtype, f22b)

        current_y = 760
        gap = 145
        bus_x = cx - box_w / 2 - 10
        gate_drop_y = branch_gate_y + gate_radius_y + 40
        line(draw, (cx, branch_gate_y + gate_radius_y), (cx, gate_drop_y))
        line(draw, (cx, gate_drop_y), (bus_x, gate_drop_y))

        main_bus_connections = []
        temp_y = current_y
        for item in basics:
            main_bus_connections.append(temp_y + 55)
            if len(item) == 2:
                temp_y += gap
            elif len(item) == 4:
                temp_y += 110 + 35 + 30 + 20 + 20 
                temp_y += len(item[3]) * gap
                temp_y += 20 

        if main_bus_connections:
            line(draw, (bus_x, gate_drop_y), (bus_x, main_bus_connections[-1]))

        for item in basics:
            if len(item) == 2:
                bid, btxt = item
                rect = (bus_x + 45, current_y, cx + box_w / 2, current_y + 110)
                line(draw, (bus_x, current_y + 55), (rect[0], current_y + 55))
                box(draw, rect, bid, btxt, f18, f22b)
                current_y += gap
                
            elif len(item) == 4:
                gid, gtxt, gtype, sub_basics = item
                rect = (bus_x + 45, current_y, cx + box_w / 2, current_y + 110)
                line(draw, (bus_x, current_y + 55), (rect[0], current_y + 55))
                box(draw, rect, gid, gtxt, f18, f22b)
                
                current_y += 110 
                
                gate_y = current_y + 35
                gate_center = (rect[0] + (rect[2] - rect[0]) / 2, gate_y)
                line(draw, (gate_center[0], current_y), (gate_center[0], gate_y - 30))
                gate(draw, gate_center, gtype, f22b)
                
                sub_bus_x = bus_x + 45 + 40 
                sub_gate_drop_y = gate_y + 30 + 20
                line(draw, (gate_center[0], gate_y + 30), (gate_center[0], sub_gate_drop_y))
                line(draw, (gate_center[0], sub_gate_drop_y), (sub_bus_x, sub_gate_drop_y))
                
                current_y = sub_gate_drop_y + 20
                
                sub_connections = [current_y + j * gap + 55 for j in range(len(sub_basics))]
                if sub_basics:
                    line(draw, (sub_bus_x, sub_gate_drop_y), (sub_bus_x, sub_connections[-1]))
                
                for sid, stxt in sub_basics:
                    srect = (sub_bus_x + 45, current_y, cx + box_w / 2, current_y + 110)
                    line(draw, (sub_bus_x, current_y + 55), (srect[0], current_y + 55))
                    box(draw, srect, sid, stxt, f18, f22b)
                    current_y += gap
                    
                current_y += 20 

    img.save(OUT / f"fta-{name}.jpg", "JPEG", quality=94, dpi=(300, 300))

def main():
    OUT.mkdir(exist_ok=True)
    for name, tree in TREES.items():
        render(name, tree)
        print(f"Wygenerowano: figures/fta-{name}.jpg")

if __name__ == "__main__":
    main()