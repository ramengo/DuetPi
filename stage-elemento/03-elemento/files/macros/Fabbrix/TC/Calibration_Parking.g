; Calibration_Parking.g
; Calibrazione del parcheggio per singolo tool con selezione interattiva

var again = true

while var.again

    ; Selezione tool
    M291 P"[I] Seleziona il tool da calibrare:" R"Calibrazione Parcheggio" S4 K{"T0","T1","[W] Esci"}
    if input = 2
        abort "Procedura terminata."
    var tool = input

    ; Avviso reset offset
    M291 P{"[W] L'offset attuale di T" ^ var.tool ^ " sarà azzerato. Procedere solo se necessario e con assistenza tecnica."} R{"Attenzione - T" ^ var.tool} S2

    ; Reset offset e homing completo
    T-1
    if var.tool = 0
        M30 sys/yPT0-offset.g
    else
        M30 sys/yPT1-offset.g
    G28
    G0 C0 F6000

    ; Posizionamento sopra il parcheggio del tool selezionato
    G0 Z200 F1500
    M564 H0 S0
    if var.tool = 0
        G0 X{global.xPT0Position} Y200 F10000
    else
        G0 X{global.xPT1Position} Y200 F10000

    ; Inserimento manuale tool sul TC
    M291 P{"[M] Inserisci manualmente T" ^ var.tool ^ " sul TC. Controlla l'allineamento e premi OK."} R{"Posiziona T" ^ var.tool ^ " sul TC"} S2
    G0 C60 F6000
    M291 P{"[W] Verifica che T" ^ var.tool ^ " sia stabile. RIMUOVI LE MANI dall'area prima di premere OK."} R"Rimuovi le mani" S2
    G0 Y{move.axes[1].min} F3000
    M564 H0 S0
    G90

    ; --- Fasi di calibrazione ---
    ; Pulsanti di movimento sempre separati dalla navigazione tra fasi
    var phase = 1
    while var.phase <= 3

        if var.phase = 1
            ; Fase 1/3 - Grossolana: passi da 5mm
            while true
                M291 P{"[M] T" ^ var.tool ^ " - Avvicinati a circa 5mm dalle spine di parcheggio."} R{"T" ^ var.tool ^ " - Fase 1/3: Grossolana"} S4 K{"-5mm","+5mm","[O] Fase Successiva >>","[W] Annulla"}
                if input = 0
                    G91
                    G1 Y-5 F600
                    G90
                    M400
                elif input = 1
                    G91
                    G1 Y5 F600
                    G90
                    M400
                elif input = 2
                    set var.phase = 2
                    break
                elif input = 3
                    abort {"Calibrazione T" ^ var.tool ^ " annullata."}

        elif var.phase = 2
            ; Fase 2/3 - Media: passi da 1mm
            while true
                M291 P{"[M] T" ^ var.tool ^ " - Centra le spine: inserisci metà spina nel tool."} R{"T" ^ var.tool ^ " - Fase 2/3: Media"} S4 K{"-1mm","+1mm","[K] << Fase Prec.","[O] Fase Succ. >>","[W] Annulla"}
                if input = 0
                    G91
                    G1 Y-1 F400
                    G90
                    M400
                elif input = 1
                    G91
                    G1 Y1 F400
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
            ; Fase 3/3 - Fine: passi da 0.1mm con spessimetro
            while true
                M291 P{"[M] T"^ var.tool ^ " - Inserisci spessimetro fino a sentire resistenza. Serra il parcheggio"} R{"T" ^ var.tool ^ " - Fase 3/3: Fine"} S4 K{"-0.1mm","+0.1mm","[K] << Fase Prec.","[O] Salva Parcheggio","[W] Annulla"}
                if input = 0
                    G91
                    G1 Y-0.1 F200
                    G90
                    M400
                elif input = 1
                    G91
                    G1 Y0.1 F200
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

    ; Salvataggio offset di parcheggio
    M400
    G90
    if var.tool = 0
        echo >>"yPT0-offset.g" "set global.yPT0Position = " ^ (move.axes[1].min - move.axes[1].machinePosition)
    else
        echo >>"yPT1-offset.g" "set global.yPT1Position = " ^ (move.axes[1].min - move.axes[1].machinePosition)
    G0 C0 F6000
    M400

    ; Test verifica: ciclo di aggancio e parcheggio
    M291 P{"[I] Offset salvato. Avvio test di aggancio e parcheggio per T" ^ var.tool ^ "."} R{"Test T" ^ var.tool} S1
    if var.tool = 0
        M98 P"yPT0-offset.g"
    else
        M98 P"yPT1-offset.g"
    G90
    G0 Y{move.axes[1].min} F4000
    G28 Y
    T{var.tool}
    M400
    G0 Y0
    M291 P{"[I] L'utensile T" ^ var.tool ^ " risulta correttamente agganciato?"} R{"Verifica aggancio T" ^ var.tool} S2
    T-1
    M291 P{"[I] L'utensile T" ^ var.tool ^ " risulta correttamente parcheggiato?"} R{"Verifica parcheggio T" ^ var.tool} S2
    M291 P{"[S] Calibrazione parcheggio T" ^ var.tool ^ " completata con successo."} R{"T" ^ var.tool ^ " - Completato!"} S1

    ; Calibrare un altro tool?
    M291 P"[I] Vuoi calibrare un altro tool?" R"Calibrazione Parcheggio" S4 K{"[O] Si, calibra altro tool","[K] No, esci"}
    if input = 1
        set var.again = false
