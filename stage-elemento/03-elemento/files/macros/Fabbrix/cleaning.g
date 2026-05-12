; Cleaning nozzle - T0 e T1
; Purge + wipe del tool attivo. Attivo solo durante stampa in corso.

if state.status == "processing" && job.duration != null
    if state.currentTool == 0
        M591 D0 S0
        if heat.heaters[1].active > 160
            M83
            G1 E5 F200
        M564 H1 S0
        G0 X{global.xPT0Position} Y{-global.yPT0Position+11} F5000
        G0 Y{move.axes[1].min - 40} F6000
        G0 Y{move.axes[1].min - 70} F6000
        G0 Y{move.axes[1].min - 40} F6000
        G0 Y{move.axes[1].min - 70} F6000
        M400
        M564 H1 S1
    elif state.currentTool == 1
        M591 D1 S0
        if heat.heaters[2].active > 160
            M83
            G1 E5 F200
        M564 H1 S0
        G0 X{global.xPT1Position} Y{-global.yPT1Position+11} F5000
        G0 Y{move.axes[1].min - 40} F6000
        G0 Y{move.axes[1].min - 70} F6000
        G0 Y{move.axes[1].min - 40} F6000
        G0 Y{move.axes[1].min - 70} F6000
        M400
        M564 H1 S1
M703
