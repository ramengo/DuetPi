#!/usr/bin/env python3
"""
Genera TEST_BABY_MERGE.gcode - layout centro-esterno con cleaning tra copie.

Ordine stampa: centro (baby=0) → -0.05 (sx) → +0.05 (dx) → -0.10 → +0.10 → ... → ±0.20
Stessa colonna X = stesso babystep per T0 e T1 (confronto visivo diretto).

Layout bed:
  Y=230-266: T1 row  [centro X=360, baby=0]
  Y=150-186: T0 row  [centro X=360, baby=0]
             X=200(-0.20) ... X=360(0.00) ... X=520(+0.20)

Fine stampa: M290 R0 Z0, Z250, T-1, G28 XY.
"""

import re
import os

DIR = os.path.dirname(os.path.abspath(__file__))
T0_FILE  = os.path.join(DIR, 'TEST_BABY.gcode')
T1_FILE  = os.path.join(DIR, 'TEST_BABY_T1.gcode')
OUT_FILE = os.path.join(DIR, 'TEST_BABY_MERGE.gcode')

# Percorso macro cleaning su RRF — adattare al percorso effettivo sul sistema
CLEANING_MACRO = "0:/macros/Fabbrix/cleaning.g"

# ── Bounding box originale (identica per entrambi i file) ──────────────────
ORIG_MINX, ORIG_MAXX = 531.9, 568.1
ORIG_MINY, ORIG_MAXY = 284.4, 320.6

# ── Layout stampe ──────────────────────────────────────────────────────────
T0_Y    = 150.0
T1_Y    = 230.0
X_START = 200.0   # X angolo sx copia più a sinistra (baby=-0.20)
X_STEP  = 40.0    # passo tra colonne

# ── Babystep ───────────────────────────────────────────────────────────────
BS_MIN, BS_MAX, BS_STEP = -0.20, 0.20, 0.05
ALL_BABYSTEPS = [round(BS_MIN + i * BS_STEP, 2)
                 for i in range(round((BS_MAX - BS_MIN) / BS_STEP) + 1)]
N = len(ALL_BABYSTEPS)   # 9: -0.20 … +0.20

# Ordine centro-esterno: 0, -0.05, +0.05, -0.10, +0.10, -0.15, +0.15, -0.20, +0.20
c = N // 2   # indice del centro (=4, valore 0.00)
BABYSTEPS_ORDER = [ALL_BABYSTEPS[c]]
for offset in range(1, c + 1):
    BABYSTEPS_ORDER.append(ALL_BABYSTEPS[c - offset])
    BABYSTEPS_ORDER.append(ALL_BABYSTEPS[c + offset])


def baby_to_x(baby: float) -> float:
    """X angolo basso-sinistra della copia per il babystep dato."""
    idx = round((baby - BS_MIN) / BS_STEP)
    return X_START + idx * X_STEP


# ── Sezioni file ────────────────────────────────────────────────────────────
T0_HEADER_END = 60
T0_BODY_END   = 496
T1_INIT_START = 212   # T1 / M82 / M141 S28 / M83 / G1 retract
T1_INIT_END   = 217
T1_BODY_START = 219   # M107 P1 … retract finale
T1_BODY_END   = 655


def shift_xy(line: str, dx: float, dy: float) -> str:
    """Sposta X e Y in righe G0/G1/G2/G3 (I/J archi invariati)."""
    stripped = line.strip()
    if not stripped or stripped.startswith(';'):
        return line
    if not re.match(r'[Gg][0-3][\s;]', stripped):
        return line
    line = re.sub(r'X(-?\d+\.?\d*)',
                  lambda m: 'X{:.3f}'.format(float(m.group(1)) + dx), line)
    line = re.sub(r'Y(-?\d+\.?\d*)',
                  lambda m: 'Y{:.3f}'.format(float(m.group(1)) + dy), line)
    return line


# ── Lettura file ───────────────────────────────────────────────────────────
with open(T0_FILE) as f:
    t0 = f.readlines()
with open(T1_FILE) as f:
    t1 = f.readlines()

t0_header = t0[:T0_HEADER_END]
t0_body   = t0[T0_HEADER_END:T0_BODY_END]
t0_footer = t0[T0_BODY_END:]
t1_init   = t1[T1_INIT_START:T1_INIT_END]
t1_body   = t1[T1_BODY_START:T1_BODY_END]

# ── Costruzione output ─────────────────────────────────────────────────────
out = []

# Header con bounding box aggiornata
final_maxx = ORIG_MAXX + (X_START - ORIG_MINX) + (N - 1) * X_STEP
final_maxy = T1_Y + (ORIG_MAXY - ORIG_MINY)
for line in t0_header:
    line = re.sub(r';MINX:\S+', f';MINX:{X_START:.1f}', line)
    line = re.sub(r';MINY:\S+', f';MINY:{T0_Y:.1f}', line)
    line = re.sub(r';MAXX:\S+', f';MAXX:{final_maxx:.1f}', line)
    line = re.sub(r';MAXY:\S+', f';MAXY:{final_maxy:.1f}', line)
    out.append(line)

# ── Sezione T0 ─────────────────────────────────────────────────────────────
center_x = baby_to_x(0.0)
out += [
    '\n',
    '; ============================================================\n',
    '; TEST BABYSTEP - T0 (1.75mm / nozzle 0.6)\n',
    f'; {N} copie | centro X={center_x:.0f} (baby=0) → espansione ±{BS_STEP:.2f} per volta\n',
    f'; Y={T0_Y:.0f}mm | M98 cleaning tra ogni copia\n',
    '; ============================================================\n',
]

t0_dy = T0_Y - ORIG_MINY
for i, baby in enumerate(BABYSTEPS_ORDER):
    x_left = baby_to_x(baby)
    t0_dx  = x_left - ORIG_MINX
    sign   = '+' if baby >= 0 else ''
    out.append(f'\n; --- T0 copia {i+1}/{N} | babystep {sign}{baby:.2f}mm | X {x_left:.0f} ---\n')
    out.append(f'M290 R0 Z{baby:.2f}\n')
    out.append(f'M117 T0 {sign}{baby:.2f}mm [{i+1}/{N}]\n')
    for line in t0_body:
        out.append(shift_xy(line, t0_dx, t0_dy))
    if i < N - 1:
        out.append(f'M98 P"{CLEANING_MACRO}"\n')

# ── Switch T1 ──────────────────────────────────────────────────────────────
out += [
    '\n',
    '; ============================================================\n',
    '; SWITCH → T1\n',
    '; ============================================================\n',
]
out += t1_init

# ── Sezione T1 ─────────────────────────────────────────────────────────────
out += [
    '\n',
    '; ============================================================\n',
    '; TEST BABYSTEP - T1 (2.85mm / nozzle 0.6)\n',
    f'; {N} copie | centro X={center_x:.0f} (baby=0) → espansione ±{BS_STEP:.2f} per volta\n',
    f'; Y={T1_Y:.0f}mm | M98 cleaning tra ogni copia\n',
    '; ============================================================\n',
]

t1_dy = T1_Y - ORIG_MINY
for i, baby in enumerate(BABYSTEPS_ORDER):
    x_left = baby_to_x(baby)
    t1_dx  = x_left - ORIG_MINX
    sign   = '+' if baby >= 0 else ''
    out.append(f'\n; --- T1 copia {i+1}/{N} | babystep {sign}{baby:.2f}mm | X {x_left:.0f} ---\n')
    out.append(f'M290 R0 Z{baby:.2f}\n')
    out.append(f'M117 T1 {sign}{baby:.2f}mm [{i+1}/{N}]\n')
    for line in t1_body:
        out.append(shift_xy(line, t1_dx, t1_dy))
    if i < N - 1:
        out.append(f'M98 P"{CLEANING_MACRO}"\n')

# ── Fine test: reset babystep, presenta, rilascia tool, home XY ────────────
out += [
    '\n',
    '; ============================================================\n',
    '; FINE TEST\n',
    '; ============================================================\n',
    'M290 R0 Z0\n',
    'M117 BABY MERGE DONE\n',
    'G1 Z250 F1000\n',
    'M400\n',
    'T-1\n',
    'G28 X Y\n',
    '\n',
]
out += t0_footer

# ── Scrittura ──────────────────────────────────────────────────────────────
with open(OUT_FILE, 'w') as f:
    f.writelines(out)

print(f'Generato: {OUT_FILE}')
print(f'Righe: {len(out)}')
print()
print(f'Ordine stampa ({N} copie per tool, centro-esterno):')
for i, b in enumerate(BABYSTEPS_ORDER):
    x = baby_to_x(b)
    sign = '+' if b >= 0 else ''
    print(f'  {i+1:2d}. babystep {sign}{b:.2f}  X {x:.0f}-{x + (ORIG_MAXX - ORIG_MINX):.1f}')
print(f'\nM98 cleaning: {CLEANING_MACRO}')
print('Fine: M290 R0 Z0 → G1 Z250 → T-1 → G28 X Y → footer')
