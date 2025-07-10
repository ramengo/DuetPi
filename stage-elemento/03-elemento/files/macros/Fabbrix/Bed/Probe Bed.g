; ========================================
; PROCEDURA PROBING SENSORE IR
; ========================================
; Versione: 1.0
; Data: 7 Luglio 2025
; Configurazione: Mesh leveling completo con sensore IR
; ========================================

; Inizializzazione file di log
echo "=========================================="
echo "AVVIO PROCEDURA PROBING SENSORE IR"
echo "Sistema: Mesh Leveling con Sensore IR"
echo "Metodo: Compensazione mesh completa"
echo "=========================================="
echo "AVVIO PROCEDURA PROBING IR: ", state.time

; ========================================
; FASE 1: CONFIGURAZIONE GRIGLIA
; ========================================
M291 P"FASE 1: CONFIGURAZIONE GRIGLIA. Definizione area di probing..." R"Fase 1: Configurazione" S0 T5

; Definizione griglia per la compensazione mesh del bed
M557 X0:200 Y20:200 P10:5

echo "=========================================="
echo "FASE 1: CONFIGURAZIONE GRIGLIA"
echo "Area X: 0 - 1080 mm"
echo "Area Y: -10 - 565 mm"
echo "Punti: 10x5 (50 totali)"
echo "=========================================="
echo "FASE 1: CONFIGURAZIONE GRIGLIA - Area X:0-1080mm Y:-10-565mm Punti:10x5"

; ========================================
; FASE 2: CALIBRAZIONE TILT BED
; ========================================
M291 P"FASE 2: CALIBRAZIONE TILT. Avvio calibrazione tilt del bed..." R"Fase 2: Tilt Bed" S0 T5

T-1
G32

echo "=========================================="
echo "FASE 2: CALIBRAZIONE TILT BED"
echo "Stato: Calibrazione tilt completata"
if abs(move.calibration.initial.deviation) < 0.05
    echo "Deviazione: ", move.calibration.initial.deviation, "mm (ECCELLENTE)"
    echo "FASE 2: TILT BED - Deviazione:", move.calibration.initial.deviation, "mm (ECCELLENTE)"
elif abs(move.calibration.initial.deviation) < 0.1
    echo "Deviazione: ", move.calibration.initial.deviation, "mm (BUONA)"
    echo "FASE 2: TILT BED - Deviazione:", move.calibration.initial.deviation, "mm (BUONA)"
else
    echo "Deviazione: ", move.calibration.initial.deviation, "mm (ATTENZIONE)"
    echo "FASE 2: TILT BED - Deviazione:", move.calibration.initial.deviation, "mm (ATTENZIONE)"
echo "=========================================="

G1 Z50 F600

; ========================================
; FASE 3: CONFIGURAZIONE SENSORE IR
; ========================================
M291 P"FASE 3: CONFIGURAZIONE SENSORE IR. Impostazione parametri sensore..." R"Fase 3: Sensore IR" S0 T5

; Configurazione sensore IR
M558 A2 Z1 K0 B1 P8 C"io4.in" H5 F300:150 T9000 S0.05 R0.5

echo "=========================================="
echo "FASE 3: CONFIGURAZIONE SENSORE IR"
echo "Tipo sensore: IR (io4.in)"
echo "Altezza di immersione: 5 mm"
echo "Velocita: 300:150 mm/min"
echo "Timeout: 9000 ms"
echo "Precisione: 0.05 mm"
echo "Raggio: 0.5 mm"
echo "=========================================="
echo "FASE 3: CONFIGURAZIONE SENSORE IR - Altezza:5mm Velocita:300:150 Precisione:0.05mm"

; ========================================
; FASE 4: PREPARAZIONE PROBING
; ========================================
M291 P"FASE 4: PREPARAZIONE PROBING. Ripristino parametri e posizionamento..." R"Fase 4: Preparazione" S0 T5

; Disabilitazione compensazione precedente
M561
G29 S2

echo "=========================================="
echo "FASE 4: PREPARAZIONE PROBING"
echo "Compensazione precedente: DISABILITATA"
echo "Heightmap: CANCELLATA"
echo "=========================================="
echo "FASE 4: PREPARAZIONE PROBING - Compensazione disabilitata, heightmap cancellata"

; ========================================
; FASE 5: RIFERIMENTO Z
; ========================================
M291 P"FASE 5: RIFERIMENTO Z. Creazione punto di riferimento Z..." R"Fase 5: Riferimento Z" S0 T5

; Impostazione riferimento Z
T0 P0
G1 X550 Y300 F1000
G30 K0 S-2

echo "=========================================="
echo "FASE 5: RIFERIMENTO Z"
echo "Posizione X: 550 mm"
echo "Posizione Y: 300 mm"
echo "Riferimento Z creato con trigger height"
echo "=========================================="
echo "FASE 5: RIFERIMENTO Z - Posizione X:550 Y:300"

; ========================================
; FASE 6: PROBING MESH
; ========================================
M291 P"FASE 6: PROBING MESH. Avvio scansione mesh completa..." R"Fase 6: Probing Mesh" S0 T5

; Avvio scansione mesh
G29 S0 K0

echo "=========================================="
echo "FASE 6: PROBING MESH"
echo "Stato: AVVIATO"
echo "Punti da scansionare: 50"
echo "Metodo: Mesh completa"
echo "=========================================="
echo "FASE 6: PROBING MESH - Avviato a ", state.time

; ========================================
; FASE 7: SALVATAGGIO DATI
; ========================================
M291 P"FASE 7: SALVATAGGIO DATI. Creazione heightmap e CSV..." R"Fase 7: Salvataggio" S0 T5

; Salvataggio heightmap e CSV
G29 S3 K0 P"probe_leveling.csv"

echo "=========================================="
echo "FASE 7: SALVATAGGIO DATI"
echo "Heightmap salvata in memoria"
echo "CSV salvato: probe_leveling.csv"
echo "Deviazione massima: ",move.compensation.meshDeviation.deviation ,"RMS deviation (in mm)" ,move.compensation.meshDeviation.mean,"Mean deviation (in mm)"
echo "FASE 7: SALVATAGGIO DATI"
echo "=========================================="

; ========================================
; FASE 8: FINALIZZAZIONE
; ========================================
M291 P"FASE 8: FINALIZZAZIONE. Ripristino posizione sicura..." R"Fase 8: Finalizzazione" S0 T5

; Ritorno a posizione sicura
T-1 P0
G1 Z50 F600  
M18 C
G1 X550 Y300 F2000
G30

echo "=========================================="
echo "FASE 8: FINALIZZAZIONE"
echo "Posizione finale X: 550 mm"
echo "Posizione finale Y: 300 mm"
echo "Altezza Z: 50 mm"
echo "Stato: Probing completato"
echo "=========================================="
echo "FASE 8: FINALIZZAZIONE - Posizione finale X:550 Y:300 Z:50"

; ========================================
; FASE 9: RIPRISTINO CONFIGURAZIONE
; ========================================
M291 P"FASE 9: RIPRISTINO. Caricamento configurazione..." R"Fase 9: Ripristino" S0 T5

; Ripristino configurazione e impostazione finale sensore
M501
M558 A2 Z1 K0 B1 P8 C"io4.in" H35 F300:150 T9000 S0.05 R0.5

echo "=========================================="
echo "FASE 9: RIPRISTINO CONFIGURAZIONE"
echo "Configurazione: RIPRISTINATA"
echo "Altezza sensore IR: 35 mm"
echo "=========================================="
echo "FASE 9: RIPRISTINO CONFIGURAZIONE - Altezza sensore finale: 35mm"