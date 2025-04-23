G91                ; relative positioning
M913 C60
G1 H1 C-200 F2000 ; move quickly to X axis endstop and stop there (first pass)
G1 H2 C5 F1000     ; go back a few mm
G1 H1 C-200 F2000  ; move slowly to X axis endstop once more (second pass)
G90                ; absolute positioning
M913 C100
G0 C0 F18000
;G92 C0

