; Tool_offset.g
; Calibrazione Z offset per singolo tool con selezione interattiva

; Passi di movimento Z
var zCoarseStep    = 5
var zMediumStep    = 1
var zFineStep      = 0.2
var zUltraFineStep = 0.05

M104 T0 S150
M104 T1 S150

; ========================================
; PREPARAZIONE (eseguita una sola volta)
; ========================================

M291 P"[I] Sequenza: 1) Reset offset  2) Tilt bed  3) Riferimento G30  4) Calibrazione tool." R"Calibrazione Z Offset" S2

; Reset offset, baby steps e compensazione bed
M290 S0 R0
M561
M501
;G29 S2

; Calibrazione tilt fisico
T-1
M18 C
G32

if abs(move.calibration.initial.deviation) < 0.05
    M291 P{"[S] Tilt eccellente: " ^ move.calibration.initial.deviation ^ "mm."} R"Tilt OK" S0 T3
elif abs(move.calibration.initial.deviation) < 0.1
    M291 P{"[I] Tilt buono: " ^ move.calibration.initial.deviation ^ "mm. Calibrazione precisa possibile."} R"Tilt Accettabile" S0 T3
else
    M291 P{"[W] Tilt elevato: " ^ move.calibration.initial.deviation ^ "mm. Considerare regolazione meccanica. Continuare?"} R"Attenzione Tilt" S2
    if input = 1
        abort "Calibrazione interrotta: tilt troppo elevato."

; Riferimento Z unificato: stessa procedura di homez.g (T-1, centro, G30)
G28 Z
;G29 S2

M291 P"[S] Riferimento G30 stabilito. Seleziona il tool da calibrare." R"Riferimento Creato" S0 T3

; ========================================
; LOOP CALIBRAZIONE TOOL
; ========================================
var again = true

while var.again

    ; Selezione tool
    M291 P"[I] Seleziona il tool da calibrare:" R"Calibrazione Z Offset" S4 K{"T0","T1","[W] Esci"}
    if input = 2
        abort "Calibrazione terminata."
    var tool = input

    ; Posiziona il tool al centro del bed
    G1 Z50 F600
    T{var.tool} P0
    M18 C
    G28 C
    G1 Z50 F600
    T-1 P0
    T{var.tool}
    G1 X{move.axes[0].max/2} Y{move.axes[1].max/2} F2000
    G1 Z45 F600
    M564 H0 S0

    M291 P{"[I] T" ^ var.tool ^ " posizionato. Avvicina il nozzle al bed usando i pulsanti."} R{"Calibrazione T" ^ var.tool} S0 T3

    ; --- Fasi di calibrazione Z ---
    var phase = 1
    while var.phase <= 4

        if var.phase = 1
            ; Fase 1/4 - Grossolana: passi da 5mm, no fase precedente
            var s = var.zCoarseStep
            while true
                M291 R{"T" ^ var.tool ^ " - Fase 1/4: Grossolana " ^ var.s ^ "mm"} P"[M] Avvicina il nozzle al bed:" S4 K{"-" ^ var.s ^ "mm","+" ^ var.s ^ "mm","[O] Fase Successiva >>","[W] Annulla"}
                if input = 0
                    G91
                    G1 Z{-var.zCoarseStep} F600
                    G90
                    M400
                elif input = 1
                    G91
                    G1 Z{var.zCoarseStep} F600
                    G90
                    M400
                elif input = 2
                    set var.phase = 2
                    break
                elif input = 3
                    abort {"Calibrazione T" ^ var.tool ^ " annullata."}

        elif var.phase = 2
            ; Fase 2/4 - Media: passi da 1mm
            var s = var.zMediumStep
            while true
                M291 R{"T" ^ var.tool ^ " - Fase 2/4: Media " ^ var.s ^ "mm"} P"[M] Regola posizione:" S4 K{"-" ^ var.s ^ "mm","+" ^ var.s ^ "mm","[K] << Fase Prec.","[O] Fase Succ. >>","[W] Annulla"}
                if input = 0
                    G91
                    G1 Z{-var.zMediumStep} F100
                    G90
                    M400
                elif input = 1
                    G91
                    G1 Z{var.zMediumStep} F100
                    G90
                    M400
                elif input = 2
                    set var.phase = 1
                    break
                elif input = 3
                    set var.phase = 3
                    break
                elif input = 4
                    abort {"Calibrazione T" ^ var.tool ^ " annullata."}

        elif var.phase = 3
            ; Fase 3/4 - Fine: passi da 0.2mm
            var s = var.zFineStep
            while true
                M291 R{"T" ^ var.tool ^ " - Fase 3/4: Fine " ^ var.s ^ "mm"} P"[M] Regola posizione:" S4 K{"-" ^ var.s ^ "mm","+" ^ var.s ^ "mm","[K] << Fase Prec.","[O] Fase Succ. >>","[W] Annulla"}
                if input = 0
                    G91
                    G1 Z{-var.zFineStep} F50
                    G90
                    M400
                elif input = 1
                    G91
                    G1 Z{var.zFineStep} F50
                    G90
                    M400
                elif input = 2
                    set var.phase = 2
                    break
                elif input = 3
                    set var.phase = 4
                    break
                elif input = 4
                    abort {"Calibrazione T" ^ var.tool ^ " annullata."}

        elif var.phase = 4
            ; Fase 4/4 - Ultra-fine: passi da 0.05mm, nozzle a contatto leggero
            var s = var.zUltraFineStep
            while true
                M291 R{"T" ^ var.tool ^ " - Fase 4/4: Ultra-Fine " ^ var.s ^ "mm"} P"[M] Nozzle a contatto leggero:" S4 K{"-" ^ var.s ^ "mm","+" ^ var.s ^ "mm","[K] << Fase Prec.","[O] SALVA T" ^ var.tool,"[W] Annulla"}
                if input = 0
                    G91
                    G1 Z{-var.zUltraFineStep} F25
                    G90
                    M400
                elif input = 1
                    G91
                    G1 Z{var.zUltraFineStep} F25
                    G90
                    M400
                elif input = 2
                    set var.phase = 3
                    break
                elif input = 3
                    G10 L1 P{var.tool} Z{-(move.axes[2].machinePosition)}
                    M500 P10
                    M501
					G1 Z50 F600
					T-1
                    echo >>"eventlog.txt" "Z OFFSET SALVATO - T" ^ var.tool ^ ": " ^ -(move.axes[2].machinePosition) ^ "mm a " ^ state.time
                    set var.phase = 5
                    break
                elif input = 4
                    abort {"Calibrazione T" ^ var.tool ^ " annullata."}

    ; Calibrare un altro tool?
    M291 P"[I] Vuoi calibrare un altro tool?" R"Calibrazione Z Offset" S4 K{"[O] Si, calibra altro tool","[K] No, mostra risultati"}
    if input = 1
        set var.again = false

; ========================================
; RIEPILOGO FINALE
; ========================================
G1 Z50 F600
T-1

M291 P{"[S] T0 offset Z: " ^ tools[0].offsets[2] ^ " mm\nT1 offset Z: " ^ tools[1].offsets[2] ^ " mm\nDelta T0-T1:  " ^ (tools[0].offsets[2] - tools[1].offsets[2]) ^ " mm"} R"Riepilogo Calibrazione Z" S1
