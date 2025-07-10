; ========================================
; MACRO CALIBRAZIONE K1
; ========================================
; Versione: 1.0
; Data: 7 Luglio 2025
; Configurazione: Calibrazione K1 con mesh bed compensation
; ========================================



echo "=========================================="
echo "AVVIO CALIBRAZIONE K1"
echo "Sistema: Mesh Leveling K1"
echo "Metodo: Compensazione bed completa"
echo "=========================================="
echo  "AVVIO CALIBRAZIONE K1: ", state.time

; ========================================
; FASE 1: CONFIGURAZIONE INIZIALE
; ========================================
M291 P"FASE 1: CONFIGURAZIONE INIZIALE. Preparazione sistema..." R"Fase 1: Configurazione" S0 T5

; Disattivazione riscaldamento e preparazione
M190 S0
T-1

echo "=========================================="
echo "FASE 1: CONFIGURAZIONE INIZIALE"
echo "Riscaldamento bed: DISATTIVATO"
echo "Tool attivo: NESSUNO (T-1)"
echo "=========================================="
echo  "FASE 1: CONFIGURAZIONE INIZIALE - Bed disattivato, tool deselezionato"

; ========================================
; FASE 2: INPUT SHAPING
; ========================================
M291 P"FASE 2: INPUT SHAPING. Caricamento parametri..." R"Fase 2: Input Shaping" S0 T5

; Esecuzione macro di input shaping
M98 P"0:/macros/Calibration/inputshaping.g"

echo "=========================================="
echo "FASE 2: INPUT SHAPING"
echo "Macro: 0:/macros/Calibration/inputshaping.g"
echo "Stato: ESEGUITA"
echo "=========================================="
echo  "FASE 2: INPUT SHAPING - Macro eseguita"

; ========================================
; FASE 3: CONFIGURAZIONE GRIGLIA
; ========================================
M291 P"FASE 3: CONFIGURAZIONE GRIGLIA. Definizione area probing..." R"Fase 3: Griglia" S0 T5

; Definizione griglia di probing
M557 X0:1080 Y26:520 P20:10

echo "=========================================="
echo "FASE 3: CONFIGURAZIONE GRIGLIA"
echo "Area X: 0 - 1080 mm"
echo "Area Y: 26 - 520 mm"
echo "Punti: 20x10 (200 totali)"
echo "=========================================="
echo  "FASE 3: CONFIGURAZIONE GRIGLIA - Area X:0-1080mm Y:26-520mm Punti:20x10"

; ========================================
; FASE 4: CALIBRAZIONE TILT BED
; ========================================
M291 P"FASE 4: CALIBRAZIONE TILT. Avvio calibrazione tilt del bed..." R"Fase 4: Tilt Bed" S0 T5

; Calibrazione tilt
G32

echo "=========================================="
echo "FASE 4: CALIBRAZIONE TILT BED"
echo "Stato: Calibrazione tilt completata"
if abs(move.calibration.initial.deviation) < 0.05
    echo "Deviazione: ", move.calibration.initial.deviation, "mm (ECCELLENTE)"
    echo  "FASE 4: TILT BED - Deviazione:", move.calibration.initial.deviation, "mm (ECCELLENTE)"
elif abs(move.calibration.initial.deviation) < 0.1
    echo "Deviazione: ", move.calibration.initial.deviation, "mm (BUONA)"
    echo  "FASE 4: TILT BED - Deviazione:", move.calibration.initial.deviation, "mm (BUONA)"
else
    echo "Deviazione: ", move.calibration.initial.deviation, "mm (ATTENZIONE)"
    echo  "FASE 4: TILT BED - Deviazione:", move.calibration.initial.deviation, "mm (ATTENZIONE)"
echo "=========================================="

; ========================================
; FASE 5: PROBING INIZIALE K1
; ========================================
M291 P"FASE 5: PROBING INIZIALE K1. Configurazione riferimento Z..." R"Fase 5: Probing Iniziale" S0 T5

; Avviso di probing e posizionamento
M117 "K1 CALIB"
echo "K1 CALIB - Avvio probing iniziale"
echo  "FASE 5: PROBING INIZIALE K1 - Avvio"

; Posizionamento e probing iniziale
G1 Z50 F2000
G1 X550 Y300 F3000
M18 C
G30 K0 S-3

echo "=========================================="
echo "FASE 5: PROBING INIZIALE K1"
echo "Posizione X: 550 mm"
echo "Posizione Y: 300 mm"
echo "Tipo: Trigger height con offset -3"
echo "=========================================="
echo  "FASE 5: PROBING INIZIALE K1 - Posizione X:550 Y:300 Z:50"

; ========================================
; FASE 6: CONFIGURAZIONE SENSORE K1
; ========================================
M291 P"FASE 6: CONFIGURAZIONE SENSORE K1. Impostazione parametri..." R"Fase 6: Config Sensore" S0 T5

; Configurazione sensore K1
M558.1 K1 S0.5
M558.2 K1 S-1
G28 C
G1 Z50 F1000

echo "=========================================="
echo "FASE 6: CONFIGURAZIONE SENSORE K1"
echo "Sensore: K1"
echo "Fattore sensibilita 1: 0.5"
echo "Fattore sensibilita 2: -1"
echo "Asse C: Home eseguito"
echo "Altezza Z: 50 mm"
echo "=========================================="
echo  "FASE 6: CONFIGURAZIONE SENSORE K1 - Sensibilita:0.5/-1"

; ========================================
; FASE 7: PREPARAZIONE MESH K1
; ========================================
M291 P"FASE 7: PREPARAZIONE MESH K1. Inizializzazione scansione mesh..." R"Fase 7: Prep Mesh" S0 T5

; Preparazione mesh bed calibration
M117 "K1 BED CALIBRATING"
echo "K1 BED CALIBRATING - Avvio preparazione mesh"
echo  "FASE 7: PREPARAZIONE MESH K1 - Avvio"

; Reset e preparazione sistema
M18 C
G29 S2
M290 S0 R0
M561
M18 C

echo "=========================================="
echo "FASE 7: PREPARAZIONE MESH K1"
echo "Heightmap precedente: CANCELLATA"
echo "Offset baby stepping: AZZERATI"
echo "Compensazione: DISABILITATA"
echo "=========================================="
echo  "FASE 7: PREPARAZIONE MESH K1 - Sistema resettato"

; ========================================
; FASE 8: RIFERIMENTO Z PER K1
; ========================================
M291 P"FASE 8: RIFERIMENTO Z PER K1. Creazione punto riferimento..." R"Fase 8: Riferimento Z" S0 T5

; Creazione riferimento Z per K1
G1 X550 Y300 F2000
T0 P0
G30 K0 S-2
G92 C0

echo "=========================================="
echo "FASE 8: RIFERIMENTO Z PER K1"
echo "Posizione X: 550 mm"
echo "Posizione Y: 300 mm"
echo "Tool: T0"
echo "Trigger height: -2"
echo "Asse C: Azzerato (G92 C0)"
echo "=========================================="
echo  "FASE 8: RIFERIMENTO Z PER K1 - Posizione X:550 Y:300 Tool:T0"

; ========================================
; FASE 9: SCANSIONE MESH K1
; ========================================
M291 P"FASE 9: SCANSIONE MESH K1. Avvio scansione completa..." R"Fase 9: Scansione Mesh" S0 T5

; Scansione mesh K1
G29 S0 K1

echo "=========================================="
echo "FASE 9: SCANSIONE MESH K1"
echo "Tipo: Scansione mesh completa"
echo "Kinematic: K1"
echo "Punti da scansionare: 200 (20x10)"
echo "=========================================="
echo  "FASE 9: SCANSIONE MESH K1 - Avviata a ", state.time

; ========================================
; FASE 10: SALVATAGGIO DATI K1
; ========================================
M291 P"FASE 10: SALVATAGGIO DATI K1. Creazione heightmap e CSV..." R"Fase 10: Salvataggio" S0 T5

; Salvataggio dati mesh K1
G29 S3 K1 P"scan_leveling.csv"

echo "=========================================="
echo "FASE 7: SALVATAGGIO DATI"
echo "Heightmap salvata in memoria"
echo "CSV salvato: probe_leveling.csv"
echo "Deviazione massima: ",move.compensation.meshDeviation.deviation ,"RMS deviation (in mm)" ,move.compensation.meshDeviation.mean,"Mean deviation (in mm)"
echo "FASE 7: SALVATAGGIO DATI"
echo "=========================================="

; ========================================
; FASE 11: FINALIZZAZIONE
; ========================================
M291 P"FASE 11: FINALIZZAZIONE. Ripristino posizione sicura..." R"Fase 11: Finalizzazione" S0 T5

; Finalizzazione procedura
G1 Z50
T-1 P0
M18 C
G1 X550 Y300 F2000
G30
M501

echo "=========================================="
echo "FASE 11: FINALIZZAZIONE"
echo "Altezza Z: 50 mm"
echo "Tool: NESSUNO (T-1)"
echo "Posizione X: 550 mm"
echo "Posizione Y: 300 mm"
echo "Riferimento G30: ESEGUITO"
echo "Configurazione: RIPRISTINATA (M501)"
echo "=========================================="
echo  "FASE 11: FINALIZZAZIONE - Posizione finale X:550 Y:300 Z:50"

; ========================================
; RIEPILOGO FINALE
; ========================================
echo "=========================================="
echo "RIEPILOGO FINALE CALIBRAZIONE K1"
echo "=========================================="
echo "Stato: Procedura completata con successo"
echo "Punti scansionati: 200 (20x10)"
echo "File CSV: scan_leveling.csv"
echo "=========================================="
echo "FASE 7: SALVATAGGIO DATI"
echo "Heightmap salvata in memoria"
echo "CSV salvato: probe_leveling.csv"
echo "Deviazione massima: ",move.compensation.meshDeviation.deviation ,"RMS deviation (in mm)" ,move.compensation.meshDeviation.mean,"Mean deviation (in mm)"
echo "FASE 7: SALVATAGGIO DATI"
echo "=========================================="
echo "=========================================="

echo  "=========================================="
echo  "RIEPILOGO FINALE CALIBRAZIONE K1"
echo  "Stato: Procedura completata con successo"
echo  "Punti scansionati: 200 (20x10)"
echo  "File CSV: scan_leveling.csv"
echo "=========================================="
echo "FASE 7: SALVATAGGIO DATI"
echo "Heightmap salvata in memoria"
echo "CSV salvato: probe_leveling.csv"
echo "Deviazione massima: ",move.compensation.meshDeviation.deviation ,"RMS deviation (in mm)" ,move.compensation.meshDeviation.mean,"Mean deviation (in mm)"
echo "FASE 7: SALVATAGGIO DATI"
echo "=========================================="
echo  "Data completamento: ", state.time
echo  "=========================================="

M291 P"CALIBRAZIONE K1 COMPLETATA! La mesh bed compensation e' stata creata e salvata correttamente." R"Calibrazione Completata" S0