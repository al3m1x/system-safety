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
            ("G-H01-A", "System nie zatrzymuje wiązki po osiągnięciu zaplanowanej dawki", "OR", [
                ("BE-H01-01", "Komputer sterujący nie wysyła polecenia Beam Off po osiągnięciu MU"),
                ("BE-H01-02", "Błąd licznika MU lub przepełnienie zmiennej w module sterującym dawką"),
                ("BE-H01-03", "Konsola operatora nie pokazuje alarmu przekroczenia dawki"),
                ("BE-H01-04", "Operator po alarmie ponownie uruchamia wiązkę bez pełnej weryfikacji"),
            ]),
            ("G-H01-B", "Rzeczywista dawka jest większa niż dawka mierzona przez system", "OR", [
                ("BE-H01-05", "Detektor dawki promieniowania jest rozkalibrowany i zaniża odczyt"),
                ("BE-H01-06", "Komora jonizacyjna ulega nasyceniu przy wysokiej mocy dawki"),
                ("BE-H01-07", "Utrata połączenia z detektorem, a komputer używa ostatniej poprawnej wartości"),
                ("BE-H01-08", "Warunki temperatury lub wilgotności powodują dryft pomiaru dawki"),
            ]),
            ("G-H01-C", "Akcelerator liniowy fizycznie pozostaje aktywny mimo komendy wyłączenia", "OR", [
                ("BE-H01-09", "Przekaźnik wysokiego napięcia jest zespawany w stanie zamkniętym"),
                ("BE-H01-10", "Linia sterująca HV Enable jest zwarta do stanu aktywnego"),
                ("BE-H01-11", "Obwód E-Stop nie odcina zasilania toru wysokiego napięcia"),
            ]),
        ],
    },
    "h03": {
        "top": ("H-03 TOP", "Wiązka promieniowania trafia poza planowany obszar guza"),
        "gate": "OR",
        "branches": [
            ("G-H03-A", "Niepoprawna geometria systemu względem pacjenta", "OR", [
                ("BE-H03-01", "Stół pacjenta ustawia błędne współrzędne pozycjonowania"),
                ("BE-H03-02", "Enkoder gantry raportuje niepoprawny kąt obrotu"),
                ("BE-H03-03", "Silniki pozycjonujące wykonują ruch w niewłaściwej osi"),
                ("BE-H03-04", "Operator ustawia pacjenta względem niewłaściwego znacznika laserowego"),
            ]),
            ("G-H03-B", "Plan leczenia nie odpowiada aktualnemu pacjentowi lub frakcji", "OR", [
                ("BE-H03-05", "Baza danych pacjentów zwraca plan innego pacjenta"),
                ("BE-H03-06", "Komputer sterujący używa niezatwierdzonej wersji planu"),
                ("BE-H03-07", "Konsola obcina istotną część identyfikatora planu lub pacjenta"),
                ("BE-H03-08", "Operator pomija kontrolę zgodności pacjent-plan"),
            ]),
            ("G-H03-C", "Pacjent zmienia pozycję po uruchomieniu wiązki", "AND", [
                ("BE-H03-09", "Pacjent porusza się lub zsuwa na stole podczas emisji"),
                ("BE-H03-10", "Kamera monitorująca nie pozwala wykryć ruchu"),
                ("BE-H03-11", "Operator nie aktywuje E-Stop w wymaganym czasie"),
            ]),
        ],
    },
    "h05": {
        "top": ("H-05 TOP", "Ruchomy element LINAC powoduje kolizję z pacjentem lub operatorem"),
        "gate": "OR",
        "branches": [
            ("G-H05-A", "System wykonuje niekontrolowany lub błędny ruch", "OR", [
                ("BE-H05-01", "Komputer sterujący wysyła komendę ruchu do niewłaściwej osi"),
                ("BE-H05-02", "Silniki pozycjonujące nie zatrzymują się po zwolnieniu sterowania"),
                ("BE-H05-03", "Hamulec gantry nie utrzymuje pozycji po zaniku zasilania"),
                ("BE-H05-04", "Tryb serwisowy pozostawia wyłączone ograniczenie prędkości"),
            ]),
            ("G-H05-B", "System nie rozpoznaje niebezpiecznego położenia", "OR", [
                ("BE-H05-05", "Krańcówka stołu pacjenta jest uszkodzona"),
                ("BE-H05-06", "Enkoder pozycji gantry jest rozkalibrowany"),
                ("BE-H05-07", "Model kolizji w oprogramowaniu nie uwzględnia aktualnego osprzętu"),
                ("BE-H05-08", "Połączenie czujnika pozycji z komputerem sterującym jest przerwane"),
            ]),
            ("G-H05-C", "Operator lub pacjent znajduje się w strefie ruchu", "OR", [
                ("BE-H05-09", "Operator stoi przy stole podczas ruchu gantry"),
                ("BE-H05-10", "Pacjent wysuwa kończynę poza obszar unieruchomienia"),
                ("BE-H05-11", "Operator wybiera zbyt duży krok ruchu w trybie pozycjonowania"),
                ("BE-H05-12", "Kamera lub widoczność lokalna nie pozwala ocenić odstępu"),
            ]),
        ],
    },
    "h06": {
        "top": ("H-06 TOP", "Pole promieniowania ma kształt inny niż zapisany w planie leczenia"),
        "gate": "OR",
        "branches": [
            ("G-H06-A", "Kolimator MLC fizycznie nie osiąga zadanej konfiguracji", "OR", [
                ("BE-H06-01", "Listek MLC zacina się w pozycji otwartej lub zamkniętej"),
                ("BE-H06-02", "Napęd listka MLC gubi kroki podczas ruchu"),
                ("BE-H06-03", "Enkoder pozycji listka MLC raportuje niepoprawną wartość"),
                ("BE-H06-04", "Kalibracja pozycji listków MLC ma przesunięcie względem izocentrum"),
            ]),
            ("G-H06-B", "Komputer sterujący wysyła do MLC niepoprawną geometrię pola", "OR", [
                ("BE-H06-05", "Plan z bazy danych zawiera nieaktualną sekwencję pozycji listków"),
                ("BE-H06-06", "Błąd transformacji współrzędnych zmienia kształt pola"),
                ("BE-H06-07", "Komputer sterujący używa konfiguracji MLC z poprzedniej frakcji"),
                ("BE-H06-08", "Konsola operatora nie pokazuje różnicy między planem i konfiguracją MLC"),
            ]),
            ("G-H06-C", "Emisja trwa mimo rozbieżności pozycji MLC", "AND", [
                ("BE-H06-09", "Sprzężenie zwrotne pozycji MLC nie zgłasza odchylenia"),
                ("BE-H06-10", "Komputer sterujący nie porównuje pozycji rzeczywistej z zadaną"),
                ("BE-H06-11", "Blokada Beam On nie wymusza statusu MLC Ready"),
            ]),
        ],
    },
    "h07": {
        "top": ("H-07 TOP", "Pacjent nie jest skutecznie monitorowany podczas aktywnej emisji wiązki"),
        "gate": "OR",
        "branches": [
            ("G-H07-A", "Obraz pacjenta nie dociera do operatora", "OR", [
                ("BE-H07-01", "Kamera monitorująca traci zasilanie"),
                ("BE-H07-02", "Przewód lub interfejs transmisji wideo jest uszkodzony"),
                ("BE-H07-03", "Komputer sterujący zamraża ostatnią klatkę obrazu"),
                ("BE-H07-04", "Konsola operatora nie wyświetla strumienia z kamery"),
            ]),
            ("G-H07-B", "Obraz jest dostępny, ale nie pozwala wykryć stanu pacjenta", "OR", [
                ("BE-H07-05", "Oświetlenie bunkra jest niewystarczające"),
                ("BE-H07-06", "Kamera jest źle ustawiona po konserwacji"),
                ("BE-H07-07", "Pacjent jest zasłonięty przez gantry lub akcesoria unieruchamiające"),
                ("BE-H07-08", "Opóźnienie transmisji przekracza czas potrzebny do reakcji"),
            ]),
            ("G-H07-C", "Człowiek nie reaguje na nieprawidłową sytuację", "OR", [
                ("BE-H07-09", "Operator jest rozproszony innym alarmem na konsoli"),
                ("BE-H07-10", "Brak alarmu technicznego utraty obrazu"),
                ("BE-H07-11", "Operator nie ma jasnej procedury przerwania leczenia przy utracie wideo"),
            ]),
        ],
    },
    "h09": {
        "top": ("H-09 TOP", "Aktywacja E-Stop nie zatrzymuje wiązki lub ruchu mechanicznego"),
        "gate": "OR",
        "branches": [
            ("G-H09-A", "Sygnał awaryjny nie powstaje lub nie dociera do obwodu bezpieczeństwa", "OR", [
                ("BE-H09-01", "Przycisk E-Stop jest mechanicznie zablokowany"),
                ("BE-H09-02", "Styk E-Stop jest skorodowany i pozostaje otwarty"),
                ("BE-H09-03", "Przewód obwodu E-Stop jest przerwany po konserwacji"),
                ("BE-H09-04", "E-Stop w bunkrze nie jest podłączony do aktywnego kanału bezpieczeństwa"),
            ]),
            ("G-H09-B", "Obwód bezpieczeństwa nie usuwa energii z elementów wykonawczych", "OR", [
                ("BE-H09-05", "Przekaźnik wysokiego napięcia akceleratora jest zespawany"),
                ("BE-H09-06", "Wejście HV Enable jest zwarte do stanu aktywnego"),
                ("BE-H09-07", "Napęd silników pozycjonujących ma obejście sygnału Safety Off"),
                ("BE-H09-08", "Zasilanie awaryjne podtrzymuje tor ruchu bez blokady bezpieczeństwa"),
            ]),
            ("G-H09-C", "Stan awaryjny nie jest poprawnie zatrzaśnięty i zweryfikowany", "OR", [
                ("BE-H09-09", "Komputer sterujący pozwala na Beam On bez ręcznego resetu po E-Stop"),
                ("BE-H09-10", "Konsola operatora pokazuje fałszywy status Emergency cleared"),
                ("BE-H09-11", "Test okresowy E-Stop nie obejmuje rzeczywistego odcięcia HV i napędów"),
            ]),
        ],
    },
    "h10": {
        "top": ("H-10 TOP", "Do leczenia zostaje użyty plan nieodpowiadający aktualnemu pacjentowi"),
        "gate": "OR",
        "branches": [
            ("G-H10-A", "System wybiera lub prezentuje błędny rekord z bazy danych pacjentów", "OR", [
                ("BE-H10-01", "Zapytanie do bazy danych zwraca rekord o podobnym imieniu i nazwisku"),
                ("BE-H10-02", "Replikacja bazy danych jest opóźniona i udostępnia starszą wersję planu"),
                ("BE-H10-03", "Błąd mapowania identyfikatora pacjenta na identyfikator planu"),
                ("BE-H10-04", "Suma kontrolna lub podpis planu nie są weryfikowane przy wczytaniu"),
            ]),
            ("G-H10-B", "Operator zatwierdza niewłaściwy plan na konsoli", "OR", [
                ("BE-H10-05", "Skaner identyfikatora pacjenta nie działa i użyto ręcznego wyboru"),
                ("BE-H10-06", "Konsola obcina długi identyfikator lub nazwę planu"),
                ("BE-H10-07", "Operator pomija procedurę time-out przed Beam On"),
                ("BE-H10-08", "Dwie zaplanowane frakcje mają podobne nazwy i daty"),
            ]),
            ("G-H10-C", "Nieaktualna lub niezatwierdzona wersja planu trafia do leczenia", "OR", [
                ("BE-H10-09", "Lekarz/fizyk nie zatwierdził finalnej wersji planu w systemie"),
                ("BE-H10-10", "Komputer sterujący nie blokuje planu o statusie roboczym"),
                ("BE-H10-11", "Awaria sieci powoduje użycie lokalnej kopii planu bez walidacji"),
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
    img = Image.new("RGB", (2400, 1500), "white")
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
    line(draw, (420, branch_bus_y), (1980, branch_bus_y))

    centers = [420, 1200, 1980]
    for cx, (gid, title, gtype, basics) in zip(centers, tree["branches"]):
        branch = (cx - 330, branch_top_y, cx + 330, branch_bottom_y)
        line(draw, (cx, branch_bus_y), (cx, branch[1]))
        box(draw, branch, gid, title, f18, f22b)
        line(draw, (cx, branch[3]), (cx, branch_gate_y - gate_radius_y))
        gate(draw, (cx, branch_gate_y), gtype, f22b)

        first_y = 775
        gap = 145
        child_box = (cx - 290, 0, cx + 330, 0)
        bus_x = child_box[0] - 45
        gate_drop_y = branch_gate_y + gate_radius_y + 40

        line(draw, (cx, branch_gate_y + gate_radius_y), (cx, gate_drop_y))
        line(draw, (cx, gate_drop_y), (bus_x, gate_drop_y))

        child_centers = [first_y + i * gap + 55 for i in range(len(basics))]
        line(draw, (bus_x, gate_drop_y), (bus_x, child_centers[-1]))

        for i, (bid, btxt) in enumerate(basics):
            y = first_y + i * gap
            rect = (child_box[0], y, child_box[2], y + 110)
            line(draw, (bus_x, y + 55), (rect[0], y + 55))
            box(draw, rect, bid, btxt, f18, f22b)

    img.save(OUT / f"fta-{name}.jpg", "JPEG", quality=94, dpi=(300, 300))


def main():
    OUT.mkdir(exist_ok=True)
    for name, tree in TREES.items():
        render(name, tree)
        print(f"figures/fta-{name}.jpg")


if __name__ == "__main__":
    main()
