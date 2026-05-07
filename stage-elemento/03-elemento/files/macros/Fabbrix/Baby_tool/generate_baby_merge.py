#!/usr/bin/env python3
"""
Genera TEST_BABY_MERGE.gcode:
  - 9 copie T0 (1.75mm): babystep -0.20 → +0.20, Y=150, sinistra→destra
  - 9 copie T1 (2.85mm): babystep +0.20 → -0.20, Y=230, destra→sinistra

Layout sul bed (stesso X = stesso babystep, facile confronto visivo):
  Y=266: T1#9(-0.20)  T1#8(-0.15) ... T1#1(+0.20)
  Y=230: [  T1 row, da destra a sinistra  ]
  Y=186: [  T0 row, da sinistra a destra  ]
  Y=150: T0#1(-0.20)  T0#2(-0.15) ... T0#9(+0.20)
         X=200         X=240            X=520
"""

import re
import os

DIR = os.path.dirname(os.path.abspath(__file__))
T0_FILE  = os.path.join(DIR, 'TEST_BABY.gcode')
T1_FILE  = os.path.join(DIR, 'TEST_BABY_T1.gcode')
OUT_FILE = os.path.join(DIR, 'TEST_BABY_MERGE.gcode')

# ── Bounding box originale (identica per entrambi i file) ──────────────────
ORIG_MINX, ORIG_MAXX = 531.9, 568.1
ORIG_MINY, ORIG_MAXY = 284.4, 320.6

# ── Layout stampe ──────────────────────────────────────────────────────────
T0_Y     = 150.0   # riga T0 (angolo basso-sinistra)
T1_Y     = 230.0   # riga T1 (angolo basso-sinistra, sopra T0)
X_START  = 200.0   # X min copia 1 T0 (e copia 9 T1)
X_STEP   = 40.0    # passo tra copie

# ── Babystep ───────────────────────────────────────────────────────────────
BS_MIN, BS_MAX, BS_STEP = -0.20, 0.20, 0.05
BABYSTEPS_T0 = [round(BS_MIN + i * BS_STEP, 2)
                for i in range(round((BS_MAX - BS_MIN) / BS_STEP) + 1)]   # -0.20 … +0.20
BABYSTEPS_T1 = list(reversed(BABYSTEPS_T0))                                # +0.20 … -0.20
N = len(BABYSTEPS_T0)   # 9

# ── Sezioni T0 (1-indexed come nell'editor) ────────────────────────────────
# Header : righe  1..60  → indices 0..59
# Body   : righe 61..496 → indices 60..495
# Footer : righe 497..   → indices 496..
T0_HEADER_END = 60
T0_BODY_END   = 496

# ── Sezioni T1 (rilevate con grep) ─────────────────────────────────────────
# Init (T1 + M82 + M141 + M83 + retract): righe 213..217 → indices 212..216
# Body (M107 P1 … retract finale)        : righe 220..655 → indices 219..654
T1_INIT_START = 212
T1_INIT_END   = 217
T1_BODY_START = 219
T1_BODY_END   = 655


# ── Utility ────────────────────────────────────────────────────────────────
def shift_xy(line: str, dx: float, dy: float) -> str:
    """Sposta X di dx e Y di dy in righe G0/G1/G2/G3 (I/J archi invariati)."""
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


def m290_block(i: int, baby: float, step: float) -> list[str]:
    """Righe M290 corrette (cumulativo RRF): R0 solo alla prima copia."""
    sign = '+' if baby >= 0 else ''
    if i == 0:
        return [f'M290 R0 Z{baby:.2f}\n']
    return [f'M290 Z{step:+.2f}\n']


# ── Lettura file ───────────────────────────────────────────────────────────
with open(T0_FILE) as f:
    t0 = f.readlines()

with open(T1_FILE) as f:
    t1 = f.readlines()

t0_header = t0[:T0_HEADER_END]
t0_body   = t0[T0_HEADER_END:T0_BODY_END]
t0_footer = t0[T0_BODY_END:]

t1_init = t1[T1_INIT_START:T1_INIT_END]
t1_body = t1[T1_BODY_START:T1_BODY_END]

# ── Costruzione output ─────────────────────────────────────────────────────
out = []

# — Header T0 (setup comune: G32, scan, heat, prime T0+T1) —
# Aggiorna bounding box nel header
final_maxx = ORIG_MAXX + (X_START - ORIG_MINX) + (N - 1) * X_STEP
final_maxy = T1_Y + (ORIG_MAXY - ORIG_MINY)
for line in t0_header:
    line = re.sub(r';MINX:\S+', f';MINX:{X_START:.1f}', line)
    line = re.sub(r';MINY:\S+', f';MINY:{T0_Y:.1f}', line)
    line = re.sub(r';MAXX:\S+', f';MAXX:{final_maxx:.1f}', line)
    line = re.sub(r';MAXY:\S+', f';MAXY:{final_maxy:.1f}', line)
    out.append(line)

# — Sezione T0 —
out += [
    '\n',
    '; ============================================================\n',
    '; TEST BABYSTEP - T0 (1.75mm / nozzle 0.6)\n',
    f'; {N} copie | babystep {BS_MIN:+.2f} → {BS_MAX:+.2f}mm | passo {BS_STEP:+.2f}mm\n',
    f'; Y={T0_Y:.0f}mm | X sinistra→destra (200→{int(X_START+(N-1)*X_STEP)})\n',
    '; ============================================================\n',
]

t0_dy = T0_Y - ORIG_MINY
for i, baby in enumerate(BABYSTEPS_T0):
    t0_dx = (X_START + i * X_STEP) - ORIG_MINX
    sign  = '+' if baby >= 0 else ''
    out.append(f'\n; --- T0 copia {i+1}/{N} | babystep {sign}{baby:.2f}mm ---\n')
    out += m290_block(i, baby, +BS_STEP)
    out.append(f'M117 T0 {sign}{baby:.2f}mm [{i+1}/{N}]\n')
    for line in t0_body:
        out.append(shift_xy(line, t0_dx, t0_dy))

# — Transizione T1 (init: T1 + M82 + M141 + M83 + retract) —
out += [
    '\n',
    '; ============================================================\n',
    '; SWITCH → T1\n',
    '; ============================================================\n',
]
out += t1_init   # T1, M82, M141 S28, M83, G1 F1020 E-0.8

# — Sezione T1 —
out += [
    '\n',
    '; ============================================================\n',
    '; TEST BABYSTEP - T1 (2.85mm / nozzle 0.6)\n',
    f'; {N} copie | babystep {BS_MAX:+.2f} → {BS_MIN:+.2f}mm | passo {-BS_STEP:+.2f}mm\n',
    f'; Y={T1_Y:.0f}mm | X destra→sinistra ({int(X_START+(N-1)*X_STEP)}→200)\n',
    '; ============================================================\n',
]

t1_dy = T1_Y - ORIG_MINY
for i, baby in enumerate(BABYSTEPS_T1):
    # T1 va da destra a sinistra: copia 0 parte da X_START+(N-1)*X_STEP
    t1_x_left = X_START + (N - 1 - i) * X_STEP
    t1_dx     = t1_x_left - ORIG_MINX
    sign      = '+' if baby >= 0 else ''
    out.append(f'\n; --- T1 copia {i+1}/{N} | babystep {sign}{baby:.2f}mm ---\n')
    out += m290_block(i, baby, -BS_STEP)
    out.append(f'M117 T1 {sign}{baby:.2f}mm [{i+1}/{N}]\n')
    for line in t1_body:
        out.append(shift_xy(line, t1_dx, t1_dy))

# — Reset babystep e footer —
out += [
    '\n',
    '; fine test - reset babystep\n',
    'M290 R0 Z0\n',
    'M117 BABY MERGE DONE\n',
    '\n',
]
out += t0_footer

# ── Scrittura ──────────────────────────────────────────────────────────────
with open(OUT_FILE, 'w') as f:
    f.writelines(out)

print(f'Generato: {OUT_FILE}')
print(f'Righe: {len(out)}')
print(f'Copie T0: {N}  |  Copie T1: {N}  |  Totale: {N*2}')
print()
print('Layout bed:')
print(f'  T0 row Y={T0_Y:.0f}-{T0_Y+(ORIG_MAXY-ORIG_MINY):.1f}:')
for i, b in enumerate(BABYSTEPS_T0):
    x = X_START + i * X_STEP
    sign = '+' if b >= 0 else ''
    print(f'    copia {i+1}: babystep {sign}{b:.2f}  X {x:.0f}-{x+(ORIG_MAXX-ORIG_MINX):.1f}')
print(f'  T1 row Y={T1_Y:.0f}-{T1_Y+(ORIG_MAXY-ORIG_MINY):.1f}:')
for i, b in enumerate(BABYSTEPS_T1):
    x = X_START + (N - 1 - i) * X_STEP
    sign = '+' if b >= 0 else ''
    print(f'    copia {i+1}: babystep {sign}{b:.2f}  X {x:.0f}-{x+(ORIG_MAXX-ORIG_MINX):.1f}')
