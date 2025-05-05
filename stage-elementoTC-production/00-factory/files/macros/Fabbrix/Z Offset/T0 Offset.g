;Calibrate BL Touch
 
; Reprap firmware version 3.3b2 or later required!
 
 
 
; if two speed probing is configured in M558,we probably want to reduce the speed for this test
 
var ProbeSpeedHigh = sensors.probes[0].speeds[0]*60 ; Speeds are saved in mm/sec in the object model but M558 uses mm/min
 
var ProbeSpeedLow = sensors.probes[0].speeds[1]*60
 
 
 
;define some variables to store readings 

 
var NumTests=10 ; modify this value to define number of tests
 
 
 
; Do not change below this line
 
var RunningTotal=0
 
var Average=0
 
var Lowest=0
 
var Highest=0
  
G28
M561 ; clear any bed transform
M290 R0 S0 ; clear babystepping
G10 P0 Z0
if move.axes[2].machinePosition < sensors.probes[0].diveHeights[0]
 
	G1 Z{sensors.probes[0].diveHeights[0]}

T0

G1 X{(move.axes[0].max)/2} Y{(move.axes[1].max)/2} F2000
  
M564 S0 H0 ; Allow movement beyond limits
 
M561 ; clear any bed transform
G29 S2
 
; Jog head to position

M203 Z300

M291 P"Jog nozzle to touch bed" R"Set nozzle to zero" S3 Z1
 
G92 Z0.2 ; set Z position to zero

;G1 H3 Z700 F1500

M291 P"Press OK to begin" R"Ready?" S3;

G91
G1 H1 Z10 F1500 
G90 
T-1 
G91
G1 H1 Z-10 F1500
G90
; Move probe over top of same point that nozzle was when zero was set

;G1 X550 Y300 F2000

;G30 S-1
 
G1 Z{sensors.probes[0].diveHeights[0]}; lift head
 
;G1 X{move.axes[0].machinePosition - sensors.probes[0].offsets[0]} Y{move.axes[1].machinePosition - sensors.probes[0].offsets[1]} F1800
 
G1 X550 Y300 F1800
 
M558 K0 H10

 echo "Current probe offset = " ^ sensors.probes[0].triggerHeight ^ "mm"
 
; carry out 10 probes (or what is set in NumTests variable)
 
 
 
while iterations < var.NumTests
 
	G1 Z{sensors.probes[0].diveHeights[0]} ; move to dive height
 
	G30 K0 S-1
 
	;M118 P2 S{"Test # " ^ (iterations+1) ^ " Triggered @ " ^ move.axes[2].machinePosition ^ "mm"} ; send trigger height to Paneldue console
 
	;M118 P3 S{"Test # " ^ (iterations+1) ^ " Triggered @ " ^ move.axes[2].machinePosition ^ "mm"} ; send trigger height to DWC console
 
 
 
	if iterations == 0
 
		set var.Lowest={move.axes[2].machinePosition} ; set the new lowest reading to first probe height
 
		set var.Highest={move.axes[2].machinePosition} ; set the new highest reading to first probe height
 
 
	if move.axes[2].machinePosition < var.Lowest

		set var.Lowest={move.axes[2].machinePosition} ; set the new lowest reading
 
		;M118 P3 S{"new low reading = " ^ move.axes[2].machinePosition} ; send trigger height to DWC console
 

	if move.axes[2].machinePosition > var.Highest
	
		set var.Highest={move.axes[2].machinePosition} ; set the new highest reading
 
		;M118 P3 S{"new high reading = " ^ move.axes[2].machinePosition} ; send trigger height to DWC console
 
	set var.RunningTotal={var.RunningTotal + move.axes[2].machinePosition} ; set new running total
 
	;M118 P3 S{"running total = " ^ var.RunningTotal} ; send running total to DWC console
 
	G4 S0.5
 
set var.Average = {(var.RunningTotal - var.Highest - var.Lowest) / (var.NumTests - 2)} 	; calculate the average after discarding th ehigh & low reading
 
 
 
;M118 P3 S{"running total = " ^ var.RunningTotal} ; send running total to DWC console
 
;M118 P3 S{"low reading = " ^ var.Lowest} ; send low reading to DWC console
 
;M118 P3 S{"high reading = " ^ var.Highest} ; send high reading to DWC console
 
M118 P2 S{"Average excluding high and low reading = " ^ var.Average} ; send average to PanelDue console
 
M118 P3 S{"Average excluding high and low reading = " ^ var.Average} ; send average to DWC console
 
 
 
G31 P500 Z{var.Average} ; set Z probe offset to the average reading
 
M564 S0 H1 ; Reset limits
 
M558 F{var.ProbeSpeedHigh}:{var.ProbeSpeedLow} ; reset probe speed to original
 
G1 Z{sensors.probes[0].diveHeights[0]} F360 ; move head back to dive height
 
M291 P{"Trigger height set to : " ^ sensors.probes[0].triggerHeight  ^ " OK to save to config-overide.g, cancel to use until next restart"} R"Finished" S3
;G10 P0 Z{-sensors.probes[0].triggerHeight}

M500 P31 ; optionally save result to config-overide.g

M203 Z2000