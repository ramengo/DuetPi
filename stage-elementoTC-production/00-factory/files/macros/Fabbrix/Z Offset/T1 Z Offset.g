T0
G28 
T1
M291 P"Jog nozzle to touch bed" R"Set nozzle to zero" S3 Z1
G10 L1 P1 Z{-(move.axes[2].machinePosition)}
M500 P10:31