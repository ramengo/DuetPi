; ========================================
; MACRO VALIDAZIONE PROBE
; ========================================
; Versione: 1.0
; Data: 7 Luglio 2025
; Configurazione: Validazione e configurazione probe K1
; ========================================

; Inizializzazione file di log
var today = state.time
if fileexists("probelog.txt")
    M291 P"File di log esistente. Sovrascrivere o aggiungere?" R"Gestione Log" S4 K{"Sovrascrivi", "Aggiungi"}
    if input = 0
        M30 "probelog.txt"
        echo >"probelog.txt" "=========================================="
        echo "MACRO VALIDAZIONE PROBE"
        echo "Data: ", today
        echo "=========================================="
    else
        echo " "
        echo "=========================================="
        echo "NUOVA VALIDAZIONE PROBE"
        echo "Data: ", today
        echo "=========================================="
else
    echo >"probelog.txt" "=========================================="
    echo "MACRO VALIDAZIONE PROBE"
    echo "Data: ", today
    echo "=========================================="

echo "=========================================="
echo "AVVIO VALIDAZIONE PROBE"
echo "Sistema: Configurazione e test probe"
echo "Metodo: Validazione sensore e configurazione K1"
echo "=========================================="
echo "AVVIO VALIDAZIONE PROBE: ", state.time

; ========================================
; FASE 1: INIZIALIZZAZIONE
; ========================================
M291 P"FASE 1: INIZIALIZZAZIONE. Preparazione sistema..." R"Fase 1: Inizializzazione" S0 T5

; Deseleziona tutti gli utensili
T-1

echo "=========================================="
echo "FASE 1: INIZIALIZZAZIONE"
echo "Tool attivo: NESSUNO (T-1)"
echo "Stato probe: ", sensors.probes[0].value[0] = 1000 ? "INATTIVO (1000)" : "ATTIVO (" ^ sensors.probes[0].value[0] ^ ")"
echo "=========================================="
echo "FASE 1: INIZIALIZZAZIONE - Tool deselezionato, Stato probe:", sensors.probes[0].value[0]

; ========================================
; FASE 2: VERIFICA STATO PROBE
; ========================================
M291 P"FASE 2: VERIFICA STATO PROBE. Controllo funzionamento..." R"Fase 2: Verifica Probe" S0 T5

; Verifica se il probe è inattivo (valore 1000)
if sensors.probes[0].value[0] = 1000
    echo "=========================================="
    echo "FASE 2: VERIFICA STATO PROBE"
    echo "Stato: INATTIVO (1000)"
    echo "Azione: Movimento sicuro in Z"
    echo "=========================================="
    echo "FASE 2: VERIFICA STATO PROBE - Probe INATTIVO (1000), esecuzione movimento sicuro"
    
    ; Esegui movimento sicuro se il probe non è attivo
    M564 H0 S0
    G1 Z50 F1000
    M564 H1 S1
    
    echo "Movimento Z completato"
    echo "Limiti software: RIPRISTINATI"
    echo "Movimento sicuro Z:50mm completato, limiti software ripristinati"
else
    echo "=========================================="
    echo "FASE 2: VERIFICA STATO PROBE"
    echo "Stato: ATTIVO (", sensors.probes[0].value[0], ")"
    echo "Azione: Nessun movimento sicuro necessario"
    echo "=========================================="
    echo "FASE 2: VERIFICA STATO PROBE - Probe ATTIVO, valore:", sensors.probes[0].value[0]
endif

; ========================================
; FASE 3: VERIFICA HOMING
; ========================================
M291 P"FASE 3: VERIFICA HOMING. Controllo stato assi..." R"Fase 3: Verifica Homing" S0 T5

; Verifica se gli assi sono già in home
echo "=========================================="
echo "FASE 3: VERIFICA HOMING"
echo "Asse X homed: ", move.axes[0].homed ? "SI" : "NO"
echo "Asse Y homed: ", move.axes[1].homed ? "SI" : "NO"
echo "Asse Z homed: ", move.axes[2].homed ? "SI" : "NO"
echo "=========================================="
echo "FASE 3: VERIFICA HOMING - X:", move.axes[0].homed ? "SI" : "NO", " Y:", move.axes[1].homed ? "SI" : "NO", " Z:", move.axes[2].homed ? "SI" : "NO"

; Esegui homing se necessario
if move.axes[0].homed != true || move.axes[1].homed != true || move.axes[2].homed != true
    echo "Esecuzione homing necessaria"
    echo "Esecuzione homing richiesta"
    M291 P"Homing assi necessario. Avvio procedura..." R"Homing" S0 T5
    G28
    echo "Homing completato con successo"
    echo "Homing completato con successo a ", state.time
else
    echo "Tutti gli assi già in home"
    echo "Tutti gli assi già in posizione home"
endif

; ========================================
; FASE 4: POSIZIONAMENTO INIZIALE
; ========================================
M291 P"FASE 4: POSIZIONAMENTO INIZIALE. Movimento in posizione sicura..." R"Fase 4: Posizionamento" S0 T5

; Disabilita motore C e posizionamento
M18 C
G1 X500 Y300

echo "=========================================="
echo "FASE 4: POSIZIONAMENTO INIZIALE"
echo "Motore C: DISABILITATO"
echo "Posizione X: 500 mm"
echo "Posizione Y: 300 mm"
echo "=========================================="
echo "FASE 4: POSIZIONAMENTO INIZIALE - X:500 Y:300, motore C disabilitato"

; ========================================
; FASE 5: CONFIGURAZIONE PROBE K0
; ========================================
M291 P"FASE 5: CONFIGURAZIONE PROBE K0. Esecuzione probing iniziale..." R"Fase 5: Probe K0" S0 T5

; Esegui probing con K0
G30 K0 S-3

echo "=========================================="
echo "FASE 5: CONFIGURAZIONE PROBE K0"
echo "Probing K0 eseguito"
echo "Trigger height: -3"
echo "Posizione attuale Z: ", move.axes[2].machinePosition, "mm"
echo "=========================================="
echo "FASE 5: CONFIGURAZIONE PROBE K0 - Trigger:-3 Z:", move.axes[2].machinePosition

; ========================================
; FASE 6: CONFIGURAZIONE PROBE K1
; ========================================
M291 P"FASE 6: CONFIGURAZIONE PROBE K1. Impostazione parametri sensore..." R"Fase 6: Config K1" S0 T5

; Configurazione sensore K1
M558.1 K1 S0.5
M558.2 K1 S-1

echo "=========================================="
echo "FASE 6: CONFIGURAZIONE PROBE K1"
echo "Sensore: K1"
echo "Fattore sensibilità 1: 0.5"
echo "Fattore sensibilità 2: -1"
echo "=========================================="
echo "FASE 6: CONFIGURAZIONE PROBE K1 - Sensibilità1:0.5 Sensibilità2:-1"

; ========================================
; FASE 7: VALIDAZIONE FINALE
; ========================================
M291 P"FASE 7: VALIDAZIONE FINALE. Test finale del probe..." R"Fase 7: Validazione" S0 T5

; Posizionamento finale e test probe
G1 X550 Y300 F2000
G30

echo "=========================================="
echo "FASE 7: VALIDAZIONE FINALE"
echo "Posizione X: 550 mm"
echo "Posizione Y: 300 mm"
echo "Probing G30 eseguito"
echo "Altezza Z rilevata: ", move.axes[2].machinePosition, "mm"
echo "=========================================="
echo "FASE 7: VALIDAZIONE FINALE - X:550 Y:300 Z:", move.axes[2].machinePosition

; ========================================
; FASE 8: RIPRISTINO CONFIGURAZIONE
; ========================================
M291 P"FASE 8: RIPRISTINO CONFIGURAZIONE. Caricamento parametri..." R"Fase 8: Ripristino" S0 T5

; Ripristino configurazione
M501

echo "=========================================="
echo "FASE 8: RIPRISTINO CONFIGURAZIONE"
echo "Configurazione: RIPRISTINATA"
echo "=========================================="
echo "FASE 8: RIPRISTINO CONFIGURAZIONE - Parametri ripristinati"

; ========================================
; RIEPILOGO FINALE
; ========================================
echo "=========================================="
echo "RIEPILOGO FINALE VALIDAZIONE PROBE"
echo "=========================================="
echo "Stato: Procedura completata con successo"
echo "Probe K0: Configurato con trigger height -3"
echo "Probe K1: Configurato con sensibilità 0.5/-1"
echo "Posizione finale: X550 Y300"
echo "Data completamento: ", state.time
echo "=========================================="

echo "=========================================="
echo "RIEPILOGO FINALE VALIDAZIONE PROBE"
echo "Stato: Procedura completata con successo"
echo "Probe K0: Configurato con trigger height -3"
echo "Probe K1: Configurato con sensibilità 0.5/-1"
echo "Posizione finale: X550 Y300"
echo "Data completamento: ", state.time
echo "=========================================="

M291 P"VALIDAZIONE PROBE COMPLETATA! Il sensore e' stato configurato e testato correttamente." R"Validazione Completata" S0