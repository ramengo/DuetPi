; ========================================
; CALIBRAZIONE Z SEQUENZIALE OTTIMIZZATA
; ========================================
; Versione: 1.0
; Data: 7 Luglio 2025
; Configurazione: Tilt bed -> Riferimento G30 unico -> T0 -> T1

; Inizializzazione file di log
if fileexists("eventlog.txt")
    M291 P"File di log esistente. Sovrascrivere o aggiungere?" R"Gestione Log" S4 K{"Sovrascrivi", "Aggiungi"}
    if input = 0
        M30 "eventlog.txt"
        echo >"eventlog.txt" "=========================================="
        echo >>"eventlog.txt" "CALIBRAZIONE Z OFFSET T0-T1"
        echo >>"eventlog.txt" "Data: ", state.time
        echo >>"eventlog.txt" "=========================================="
    else
        echo >>"eventlog.txt" " "
        echo >>"eventlog.txt" "=========================================="
        echo >>"eventlog.txt" "NUOVA CALIBRAZIONE Z OFFSET T0-T1"
        echo >>"eventlog.txt" "Data: ", state.time
        echo >>"eventlog.txt" "=========================================="
else
    echo >"eventlog.txt" "=========================================="
    echo >>"eventlog.txt" "CALIBRAZIONE Z OFFSET T0-T1"
    echo >>"eventlog.txt" "Data: ", state.time
    echo >>"eventlog.txt" "=========================================="

echo "=========================================="
echo "AVVIO CALIBRAZIONE Z OFFSET SEQUENZIALE"
echo "Sistema: Calibrazione Offset Z T0-T1"
echo "Metodo: Riferimento G30 singolo"
echo "=========================================="
echo >>"eventlog.txt" "AVVIO CALIBRAZIONE Z OFFSET SEQUENZIALE: ", state.time

M291 P"CALIBRAZIONE Z OFFSET. Sequenza: 1) Tilt bed 2) Riferimento G30 unico 3) T0 4) T1" R"Calibrazione Z Offset T0 - T1" S2

; Definizione variabili per movimenti
; Movimenti Z disponibili: 0.1mm, 0.05mm, 0.02mm, 0.01mm
var zCoarseStep = 5    ; Movimento grossolano
var zMediumStep = 1    ; Movimento medio  
var zFineStep = 0.2    ; Movimento fine
var zUltraFineStep = 0.05 ; Movimento ultra-fine

; ========================================
; FASE 1: PREPARAZIONE SISTEMA
; ========================================
M291 P"FASE 1: PREPARAZIONE. Riscaldamento bed a 65 gradi C..." R"Fase 1: Preparazione" S0 T10

M190 S0
M290 S0 R0
M561                                            ; DISABILITA compensazione bed (CRUCIALE!)
M501
G29 S2                                          ; Cancella heightmap esistente
M104 T0 S180
M104 T1 S180

echo "=========================================="
echo "FASE 1: PREPARAZIONE COMPLETATA"
echo "Bed: 50 gradi C"
echo "Offset: Azzerati"
echo "Compensazione bed: DISABILITATA"
echo "=========================================="
echo >>"eventlog.txt" "FASE 1 COMPLETATA - Preparazione sistema: ", state.time

M291 P"Sistema pronto. Bed a 50 gradi C, offset azzerati, LIVELLAMENTO DISABILITATO per calibrazione precisa." R"Preparazione Completata" S0 T3

; ========================================
; FASE 2: CALIBRAZIONE TILT BED (SENZA COMPENSAZIONE)
; ========================================
M291 P"FASE 2: CALIBRAZIONE TILT. Calibrazione tilt fisico senza compensazione attiva per massima precisione." R"Fase 2: Tilt Fisico" S0 T5

T-1
M18 C
G32                                             ; Calibra tilt ma NON attiva compensazione
;G28
; Verifica risultati tilt
if abs(move.calibration.initial.deviation) < 0.05
    echo "=========================================="
    echo "FASE 2: TILT BED COMPLETATO"
    echo "Stato: ECCELLENTE"
    echo "Deviazione: ", move.calibration.initial.deviation, "mm"
    echo "=========================================="
    echo >>"eventlog.txt" "FASE 2 COMPLETATA - Tilt ECCELLENTE, deviazione: ", move.calibration.initial.deviation, "mm"
    M291 P{"Tilt fisico ECCELLENTE! Deviazione: " ^ move.calibration.initial.deviation ^ "mm - Procedura su bed piano"} R"Tilt Perfetto" S0 T3
elif abs(move.calibration.initial.deviation) < 0.1
    echo "=========================================="
    echo "FASE 2: TILT BED COMPLETATO"
    echo "Stato: BUONO"
    echo "Deviazione: ", move.calibration.initial.deviation, "mm"
    echo "=========================================="
    echo >>"eventlog.txt" "FASE 2 COMPLETATA - Tilt BUONO, deviazione: ", move.calibration.initial.deviation, "mm"
    M291 P{"Tilt fisico BUONO. Deviazione: " ^ move.calibration.initial.deviation ^ "mm - Calibrazione precisa possibile"} R"Tilt Accettabile" S0 T3
else
    echo "=========================================="
    echo "FASE 2: TILT BED COMPLETATO"
    echo "Stato: ATTENZIONE"
    echo "Deviazione: ", move.calibration.initial.deviation, "mm"
    echo "=========================================="
    echo >>"eventlog.txt" "FASE 2 COMPLETATA - Tilt ELEVATO, deviazione: ", move.calibration.initial.deviation, "mm"
    M291 P{"Tilt fisico elevato: " ^ move.calibration.initial.deviation ^ "mm. Considerare regolazione meccanica bed. Continuare?"} R"Attenzione Tilt" S2
    if input = 1  ; No
        echo >>"eventlog.txt" "CALIBRAZIONE INTERROTTA - Deviazione tilt troppo elevata: ", state.time
        abort "Calibrazione interrotta per deviazione tilt elevata"

; ========================================
; FASE 3: RIFERIMENTO G30 SU BED FISICO
; ========================================
M291 P"FASE 3: RIFERIMENTO G30. Creazione riferimento Z sul bed reale senza compensazioni." R"Fase 3: Riferimento Base" S0 T5

G1 Z50 F1000
M400
G1 X{move.axes[0].max/2} Y{move.axes[1].max/2} F2000
M18 C
T0 P0
G30                                      ; Riferimento sul bed FISICO non compensato
T-1 P0
G29 S2

echo "=========================================="
echo "FASE 3: RIFERIMENTO G30 CREATO"
echo "Posizione: X", move.axes[0].max/2, " Y", move.axes[1].max/2
echo "Stato: Completato senza compensazione"
echo "=========================================="
echo >>"eventlog.txt" "FASE 3 COMPLETATA - Riferimento G30 creato a X", move.axes[0].max/2, " Y", move.axes[1].max/2, ": ", state.time

M291 P"Riferimento G30 stabilito sul bed fisico. Offset calcolati sulla geometria reale del sistema." R"Riferimento Creato" S0 T3

; ========================================
; FASE 4: CALIBRAZIONE Z OFFSET T0
; ========================================
M291 P"FASE 4: CALIBRAZIONE T0. Posizionamento T0 senza re-probing..." R"Fase 4: Offset T0" S0 T5

; Preparazione T0 SENZA G30 aggiuntivo
T0 P0
M18 C
G28 C
G1 Z50 F600
T-1 P0
T0
G1 X{move.axes[0].max/2} Y{move.axes[1].max/2} F2000
G1 Z45 F600
M564 H0 S0

M291 P{"T0 - AVVICINAMENTO GROSSOLANO. MOVIMENTO:" ^ var.zCoarseStep ^ "mm"} R"T0: Avvicinamento" S0 T3

; Loop calibrazione grossolana T0
while true
    M291 R{"T0 - Movimento Grossolano " ^ var.zCoarseStep ^ "mm"} P"Regolare posizione:" S4 K{"-" ^ var.zCoarseStep ^ "mm","+" ^ var.zCoarseStep ^ "mm","Prossima Fase","Annulla"}
    
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
        break
    elif input = 3
        abort "Calibrazione T0 annullata"

M291 P{"T0 - REGOLAZIONE MEDIA. MOVIMENTO:" ^ var.zMediumStep ^ "mm"} R"T0: Regolazione Media" S0 T3

; Loop calibrazione media T0
while true
    M291 R{"T0 - Movimento Medio " ^ var.zMediumStep ^ "mm"} P"Regolare posizione:" S4 K{"-" ^ var.zMediumStep ^ "mm","+" ^ var.zMediumStep ^ "mm","Prossima Fase","Fase Precedente","Annulla"}
    
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
        break
    elif input = 3
        M291 P"Ritorno fase grossolana..." R"Ritorno" S0 T2
        continue
    elif input = 4
        abort "Calibrazione T0 annullata"

M291 P{"T0 - REGOLAZIONE FINE. MOVIMENTO:" ^ var.zFineStep ^ "mm"} R"T0: Regolazione Fine" S0 T3

; Loop calibrazione fine T0
while true
    M291 R{"T0 - Movimento Fine " ^ var.zFineStep ^ "mm"} P"Regolare posizione:" S4 K{"-" ^ var.zFineStep ^ "mm","+" ^ var.zFineStep ^ "mm","Prossima Fase","Fase Precedente","Annulla"}
    
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
        break
    elif input = 3
        M291 P"Ritorno fase media..." R"Ritorno" S0 T2
        continue
    elif input = 4
        abort "Calibrazione T0 annullata"

M291 P{"T0 - REGOLAZIONE ULTRA-FINE. MOVIMENTO:" ^ var.zUltraFineStep ^ "mm"} R"T0: Ultra-Fine" S0 T3

; Loop calibrazione ultra-fine T0
while true
    M291 R{"T0 - Ultra-Fine " ^ var.zUltraFineStep ^ "mm"} P"Nozzle deve toccare LEGGERMENTE il bed:" S4 K{"-" ^ var.zUltraFineStep ^ "mm","+" ^ var.zUltraFineStep ^ "mm","SALVA T0","Fase Precedente","Annulla"}
    
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
        M291 P"Salvataggio offset Z per T0..." R"Salvataggio T0" S0 T3
        G10 L1 P0 Z{-(move.axes[2].machinePosition)}
        M500 P10
        
        echo "=========================================="
        echo "FASE 4: OFFSET T0 SALVATO"
        echo "Valore Z: ", -(move.axes[2].machinePosition), "mm"
        echo "Posizione Assoluta: ", move.axes[2].machinePosition, "mm"
        echo "=========================================="
        echo >>"eventlog.txt" "FASE 4 COMPLETATA - Offset T0 salvato: ", -(move.axes[2].machinePosition), "mm a ", state.time
        
        break
    elif input = 3
        M291 P"Ritorno fase fine..." R"Ritorno" S0 T2
        continue
    elif input = 4
        abort "Calibrazione T0 annullata"

M291 P"OFFSET T0 SALVATO! Passaggio a calibrazione T1..." R"T0 Completato" S0 T5


M501

G1 Z50 F600

T1





; ========================================
; FASE 5: CALIBRAZIONE Z OFFSET T1
; ========================================
M291 P"FASE 5: CALIBRAZIONE T1. Posizionamento usando stesso riferimento..." R"Fase 5: Offset T1" S0 T5

G1 X{move.axes[0].max/2} Y{move.axes[1].max/2} F2000

M291 P{"T1 - AVVICINAMENTO GROSSOLANO. MOVIMENTO:" ^ var.zCoarseStep ^ "mm"} R"T1: Avvicinamento" S0 T3

; Loop calibrazione grossolana T1
while true
    M291 R{"T1 - Movimento Grossolano " ^ var.zCoarseStep ^ "mm"} P"Regolare posizione:" S4 K{"-" ^ var.zCoarseStep ^ "mm","+" ^ var.zCoarseStep ^ "mm","Prossima Fase","Annulla"}
    
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
        break
    elif input = 3
        abort "Calibrazione T1 annullata"

M291 P{"T1 - REGOLAZIONE MEDIA. MOVIMENTO:" ^ var.zMediumStep ^ "mm"} R"T1: Regolazione Media" S0 T3

; Loop calibrazione media T1
while true
    M291 R{"T1 - Movimento Medio " ^ var.zMediumStep ^ "mm"} P"Regolare posizione:" S4 K{"-" ^ var.zMediumStep ^ "mm","+" ^ var.zMediumStep ^ "mm","Prossima Fase","Fase Precedente","Annulla"}
    
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
        break
    elif input = 3
        M291 P"Ritorno fase grossolana..." R"Ritorno" S0 T2
        continue
    elif input = 4
        abort "Calibrazione T1 annullata"

M291 P{"T1 - REGOLAZIONE FINE. MOVIMENTO:" ^ var.zFineStep ^ "mm"} R"T1: Regolazione Fine" S0 T3

; Loop calibrazione fine T1
while true
    M291 R{"T1 - Movimento Fine " ^ var.zFineStep ^ "mm"} P"Regolare posizione:" S4 K{"-" ^ var.zFineStep ^ "mm","+" ^ var.zFineStep ^ "mm","Prossima Fase","Fase Precedente","Annulla"}
    
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
        break
    elif input = 3
        M291 P"Ritorno fase media..." R"Ritorno" S0 T2
        continue
    elif input = 4
        abort "Calibrazione T1 annullata"

M291 P{"T1 - REGOLAZIONE ULTRA-FINE. MOVIMENTO:" ^ var.zUltraFineStep ^ "mm"} R"T1: Ultra-Fine" S0 T3

; Loop calibrazione ultra-fine T1
while true
    M291 R{"T1 - Ultra-Fine " ^ var.zUltraFineStep ^ "mm"} P"Nozzle deve toccare LEGGERMENTE il bed:" S4 K{"-" ^ var.zUltraFineStep ^ "mm","+" ^ var.zUltraFineStep ^ "mm","SALVA T1","Fase Precedente","Annulla"}
    
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
        M291 P"Salvataggio offset Z per T1..." R"Salvataggio T1" S0 T3
        G10 L1 P1 Z{-(move.axes[2].machinePosition)}
        M500 P10
        
        echo "=========================================="
        echo "FASE 5: OFFSET T1 SALVATO"
        echo "Valore Z: ", -(move.axes[2].machinePosition), "mm"
        echo "Posizione Assoluta: ", move.axes[2].machinePosition, "mm"
        echo "=========================================="
        echo >>"eventlog.txt" "FASE 5 COMPLETATA - Offset T1 salvato: ", -(move.axes[2].machinePosition), "mm a ", state.time
        
        break
    elif input = 3
        M291 P"Ritorno fase fine..." R"Ritorno" S0 T2
        continue
    elif input = 4
        abort "Calibrazione T1 annullata"

M291 P"OFFSET T1 SALVATO!" R"T1 Completato" S0 T5

; ========================================
; FASE 6: FINALIZZAZIONE E RIATTIVAZIONE COMPENSAZIONE
; ========================================
M291 P"FINALIZZAZIONE: Ripristino configurazione e riattivazione compensazione bed..." R"Finalizzazione" S0 T5

M501

; Riattiva la compensazione bed se disponibile
M291 P"Riattivare la compensazione automatica del bed per le stampe future?" R"Riattivazione Compensazione" S4 K{"Si", "No"}
if input = 0  ; Yes
    G29 S1                                      ; Riattiva la heightmap esistente
    echo "=========================================="
    echo "FASE 6: COMPENSAZIONE RIATTIVATA"
    echo "Stato: Compensazione bed ATTIVA"
    echo "=========================================="
    echo >>"eventlog.txt" "FASE 6 COMPLETATA - Compensazione bed riattivata a ", state.time
    M291 P"Compensazione bed riattivata per le stampe." R"Compensazione Attiva" S0 T3
else
    echo "=========================================="
    echo "FASE 6: COMPENSAZIONE NON ATTIVATA"
    echo "Stato: Compensazione bed DISATTIVA"
    echo "Nota: Ricordare di attivare con G29 S1 prima di stampare"
    echo "=========================================="
    echo >>"eventlog.txt" "FASE 6 COMPLETATA - Compensazione bed NON riattivata a ", state.time
    M291 P"Compensazione bed rimane disattivata. Ricordare di attivarla prima delle stampe con G29 S1." R"Compensazione Disattiva" S0 T5

G1 Z100 F1000

T-1

; Test di verifica rapido opzionale
M291 P"Eseguire un test di verifica rapido per entrambi i tool?" R"Test Verifica Finale" S4 K{"Si", "No"}

if input = 0  ; Yes
    echo "=========================================="
    echo "AVVIO TEST FINALE DI VERIFICA"
    echo "Test: Verifica altezza nozzle-bed"
    echo "=========================================="
    echo >>"eventlog.txt" "AVVIO TEST FINALE - Test altezza nozzle-bed a ", state.time
    
    M291 P"TEST DI VERIFICA RAPIDO in corso..." R"Test Finale" S0 T5
    
    ; Test T0
    T0
    G1 Z15 F250
    G1 X{move.axes[0].max/2} Y{move.axes[1].max/2} F2000
    G1 Z0.2 F100
    M291 P"TEST T0: Verificare distanza nozzle-bed. OK?" R"Verifica T0" S4 K{"Si", "No"}
    var t0TestResult = input
    G1 Z15 F250
    
    ; Test T1
    T1
    G1 Z15 F250
    G1 X{move.axes[0].max/2} Y{move.axes[1].max/2} F2000
    G1 Z0.2 F100
    M291 P"TEST T1: Verificare distanza nozzle-bed. OK?" R"Verifica T1" S4 K{"Si", "No"}
    var t1TestResult = input
    
    G1 Z50 F1000
    T-1
    
    ; Risultati test
    if var.t0TestResult = 0 && var.t1TestResult = 0
        echo "=========================================="
        echo "RISULTATI TEST FINALE"
        echo "Stato: PERFETTO"
        echo "T0: Calibrazione corretta"
        echo "T1: Calibrazione corretta"
        echo "=========================================="
        echo >>"eventlog.txt" "TEST FINALE SUPERATO - Entrambi i tool calibrati perfettamente"
        M291 P"TEST SUPERATO! Entrambi i tool sono perfettamente calibrati!" R"Test Perfetto" S0
    elif var.t0TestResult = 1 && var.t1TestResult = 0
        echo "=========================================="
        echo "RISULTATI TEST FINALE"
        echo "Stato: ATTENZIONE"
        echo "T0: Calibrazione NON corretta"
        echo "T1: Calibrazione corretta"
        echo "=========================================="
        echo >>"eventlog.txt" "TEST FINALE PARZIALE - T0 necessita ricalibrare, T1 OK"
        M291 P"T0 necessita ricalibrare, T1 OK" R"Attenzione T0" S0
    elif var.t0TestResult = 0 && var.t1TestResult = 1
        echo "=========================================="
        echo "RISULTATI TEST FINALE"
        echo "Stato: ATTENZIONE"
        echo "T0: Calibrazione corretta"
        echo "T1: Calibrazione NON corretta"
        echo "=========================================="
        echo >>"eventlog.txt" "TEST FINALE PARZIALE - T1 necessita ricalibrare, T0 OK"
        M291 P"T1 necessita ricalibrare, T0 OK" R"Attenzione T1" S0
    else
        echo "=========================================="
        echo "RISULTATI TEST FINALE"
        echo "Stato: CALIBRAZIONE NON CORRETTA"
        echo "T0: Calibrazione NON corretta"
        echo "T1: Calibrazione NON corretta"
        echo "=========================================="
        echo >>"eventlog.txt" "TEST FINALE FALLITO - Entrambi i tool necessitano ricalibrare"
        M291 P"Entrambi i tool potrebbero necessitare ricalibrare" R"Attenzione Entrambi" S0
else
    echo "=========================================="
    echo "TEST FINALE NON ESEGUITO"
    echo "Stato: Omesso su richiesta utente"
    echo "=========================================="
    echo >>"eventlog.txt" "TEST FINALE NON ESEGUITO - Omesso su richiesta utente"

; Messaggio finale
echo "=========================================="
echo "CALIBRAZIONE Z OFFSET COMPLETATA"
echo "T0 Offset: ", tools[0].offsets[2], "mm"
echo "T1 Offset: ", tools[1].offsets[2], "mm"
echo "Differenza T0-T1: ", tools[0].offsets[2] - tools[1].offsets[2], "mm"
echo "Data completamento: ", state.time
echo "=========================================="
echo >>"eventlog.txt" "CALIBRAZIONE Z COMPLETATA - T0: ", tools[0].offsets[2], "mm, T1: ", tools[1].offsets[2], "mm, Diff: ", tools[0].offsets[2] - tools[1].offsets[2], "mm a ", state.time

M291 P"CALIBRAZIONE T0 E T1 COMPLETATA!" R"Calibrazione Offset" S0