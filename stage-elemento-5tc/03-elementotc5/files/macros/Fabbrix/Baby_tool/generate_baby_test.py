#!/usr/bin/env python3
"""
Genera TEST_BABY_6x.gcode da TEST_BABY.gcode.
6 copie del quadrato test (20x20mm, h=0.3mm) spostate di 40mm in X,
ognuna con un babystep Z diverso (incremento 0.05mm).
Range babystep: -0.10 → +0.15mm
"""

import re
import os

script_dir  = os.path.dirname(os.path.abspath(__file__))
INPUT_FILE  = os.path.join(script_dir, 'TEST_BABY.gcode')
OUTPUT_FILE = os.path.join(script_dir, 'TEST_BABY_6x.gcode')

# Babystep per ciascuna copia (da sinistra a destra sul bed)
BABYSTEPS = [-0.20, -0.15, -0.10, -0.05, 0.00, 0.05]
X_STEP_MM = 40.0   # passo X tra le copie (stampa larga 36.2mm → gap 3.8mm)

# Bounding box originale (da header gcode)
ORIG_MINX = 531.9
ORIG_MINY = 284.4
ORIG_MAXX = 568.1
ORIG_MAXY = 320.6

# Posizione target: angolo basso-sinistra copia 1
TARGET_X = 200.0
TARGET_Y = 150.0

X_BASE = TARGET_X - ORIG_MINX   # = -331.9
Y_BASE = TARGET_Y - ORIG_MINY   # = -134.4

# Sezioni (1-indexed come nell'editor):
#   Header : righe  1..60  → indices 0..59
#   Body   : righe 61..496 → indices 60..495   (move to pos + skirt + walls + fill + retract)
#   Footer : righe 497..   → indices 496..
HEADER_END = 60
BODY_END   = 496


def shift_xy(line: str, dx: float, dy: float) -> str:
    """Sposta X di dx e Y di dy in tutte le righe di movimento G0/G1/G2/G3."""
    stripped = line.strip()
    if not stripped or stripped.startswith(';'):
        return line
    if not re.match(r'[Gg][0-3][\s;]', stripped):
        return line
    def repl_x(m):
        return 'X{:.3f}'.format(float(m.group(1)) + dx)
    def repl_y(m):
        return 'Y{:.3f}'.format(float(m.group(1)) + dy)
    line = re.sub(r'X(-?\d+\.?\d*)', repl_x, line)
    line = re.sub(r'Y(-?\d+\.?\d*)', repl_y, line)
    return line


with open(INPUT_FILE, 'r') as f:
    lines = f.readlines()

header = lines[:HEADER_END]
body   = lines[HEADER_END:BODY_END]
footer = lines[BODY_END:]

out = []
# Aggiorna bounding box nell'header con i valori della nuova posizione
header_out = []
for line in header:
    line = re.sub(r';MINX:\S+', f';MINX:{TARGET_X:.1f}', line)
    line = re.sub(r';MINY:\S+', f';MINY:{TARGET_Y:.1f}', line)
    final_maxx = ORIG_MAXX + X_BASE + (len(BABYSTEPS) - 1) * X_STEP_MM
    final_maxy = ORIG_MAXY + Y_BASE
    line = re.sub(r';MAXX:\S+', f';MAXX:{final_maxx:.1f}', line)
    line = re.sub(r';MAXY:\S+', f';MAXY:{final_maxy:.1f}', line)
    header_out.append(line)

out.extend(header_out)
out.append('\n')
out.append('; ====================================================\n')
out.append('; CALIBRAZIONE BABYSTEP - 6 COPIE\n')
out.append('; Range: -0.20 → +0.05mm | Passo: 0.05mm\n')
out.append('; Copie affiancate in X, passo 40mm, gap 3.8mm\n')
out.append(';\n')
for i, b in enumerate(BABYSTEPS):
    sign = '+' if b >= 0 else ''
    x_min = TARGET_X + i * X_STEP_MM
    x_max = x_min + (ORIG_MAXX - ORIG_MINX)
    y_min = TARGET_Y
    y_max = TARGET_Y + (ORIG_MAXY - ORIG_MINY)
    out.append(f';   Copia {i+1}/6 → babystep {sign}{b:.2f}mm  '
               f'X {x_min:.1f}-{x_max:.1f}  Y {y_min:.1f}-{y_max:.1f}\n')
out.append('; ====================================================\n')

STEP = 0.05   # incremento relativo tra una copia e la prossima

for i, baby in enumerate(BABYSTEPS):
    dx   = X_BASE + i * X_STEP_MM
    dy   = Y_BASE
    sign = '+' if baby >= 0 else ''
    label = f'BABY {sign}{baby:.2f}mm [{i+1}/6]'

    out.append('\n')
    out.append(f'; --- COPIA {i+1}/6 | babystep {sign}{baby:.2f}mm ---\n')
    if i == 0:
        # Prima copia: reset assoluto al valore iniziale (M290 è cumulativo!)
        out.append(f'M290 R0 Z{baby:.2f}\n')
    else:
        # Copie successive: aggiunge il passo relativo (+0.05)
        out.append(f'M290 Z{STEP:.2f}\n')
    out.append(f'M117 {label}\n')

    for line in body:
        out.append(shift_xy(line, dx, dy))

    # Tra una copia e la successiva: alza Z e resetta E
    if i < len(BABYSTEPS) - 1:
        out.append('; transizione alla prossima copia\n')
        out.append('G1 Z5 F3000\n')
        out.append('G92 E0\n')

out.append('\n')
out.append('; fine test babystep - reset assoluto a zero\n')
out.append('M290 R0 Z0\n')
out.append('M117 BABY TEST DONE\n')
out.append('\n')
out.extend(footer)

with open(OUTPUT_FILE, 'w') as f:
    f.writelines(out)

print(f'Generato: {OUTPUT_FILE}')
print(f'Righe totali: {len(out)}')
print()
for i, b in enumerate(BABYSTEPS):
    sign = '+' if b >= 0 else ''
    x_min = TARGET_X + i * X_STEP_MM
    x_max = x_min + (ORIG_MAXX - ORIG_MINX)
    print(f'  Copia {i+1}/6: babystep {sign}{b:.2f}mm  '
          f'X {x_min:.1f}-{x_max:.1f}  Y {TARGET_Y:.1f}-{TARGET_Y+(ORIG_MAXY-ORIG_MINY):.1f}')
