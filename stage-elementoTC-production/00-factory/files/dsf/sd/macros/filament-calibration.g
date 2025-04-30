if !exists(global.ignoreMFMevents)
  global ignoreMFMevents = true
else
  set global.ignoreMFMevents = true

var filamentMonitorPin = "121.io1.in"
var filamentMonitorCircumference = 25.3

var extrusionDistance = 20                  ; distance for e-step calibration

; speeds in mm/s for NLE to test
var extrusionSpeeds = {0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5}

M107                                        ; fan off
G28 
G1 Z100
T0                                          ; select tool 0
G29 S1                                      ; load stored hight map

M83 ; use relative distances for extrusion
G90 ; use absolute coordinates
G21 ; set units to millimeters

var currentTool = state.currentTool
var currentHeater = tools[0].heaters[var.currentTool]
var currentTemp = heat.heaters[var.currentHeater].active

if var.currentTemp < 180 || var.currentTemp > 355
  set var.currentTemp = 180 

M291 P"Please set desired filament temperature" R"Filament Temp" S6 L180 H355 F{var.currentTemp}
set var.currentTemp = input
G10 P0 S{var.currentTemp}

M116                                        ; wait for all heaters

G11 ; unretract

G1 Z{((move.axes[2].max-move.axes[2].min)/3*2+move.axes[2].min)} F3600  ; raise z=2/3
G53 G1 X{((move.axes[0].max-move.axes[0].min)/2+move.axes[0].min)} Y{((move.axes[1].max-move.axes[1].min)/2+move.axes[1].min)} F14400                       ; move printhead to center

G92 E0                                       ; reset e-steps

M220 S100                                    ; Set speed factor override percentage
M221 S100                                    ; Set extrude factor override percentage
M572 D0 S0.0                                 ; disable pressure advance
M592 D0 A0.0 B0.0                            ; disable non-linear-extrusion

M591 D0 P0
G4 S1
M591 D0 P3 C{var.filamentMonitorPin} S2 R98:102 E0.2 L{var.filamentMonitorCircumference}    ; enable MFM on all moves

G4 S5 ; wait for restart of MFM

G91 ; relative moves
; 15mm
G1 X15 E15 F30

; the mfm should be calibrated now

if sensors.filamentMonitors[0].calibrated == null
  echo "Cannot calibrate filament monitor within 15mm - error!"
  set global.ignoreMFMevents = false
  M591 D0 P0                                              ; reset filament sensor
  M99

G4 S1 ; wait for filament monitor send timeout

; start e-step calibration
var totalDistanceBase = (sensors.filamentMonitors[0].calibrated.totalDistance / sensors.filamentMonitors[0].calibrated.mmPerRev * sensors.filamentMonitors[0].configured.mmPerRev)

G1 X{var.extrusionDistance} E{var.extrusionDistance} F30

G4 S1 ; wait for filament monitor send timeout

var currentMeasured = (sensors.filamentMonitors[0].calibrated.totalDistance / sensors.filamentMonitors[0].calibrated.mmPerRev * sensors.filamentMonitors[0].configured.mmPerRev)

var newESteps = {floor(move.extruders[0].stepsPerMm / ((var.currentMeasured-var.totalDistanceBase)/var.extrusionDistance)*100)/100}

set var.totalDistanceBase = (sensors.filamentMonitors[0].calibrated.totalDistance / sensors.filamentMonitors[0].calibrated.mmPerRev * sensors.filamentMonitors[0].configured.mmPerRev)

G1 X{var.extrusionDistance} E{var.extrusionDistance} F30

G4 S1 ; wait for filament monitor send timeout

set var.currentMeasured = (sensors.filamentMonitors[0].calibrated.totalDistance / sensors.filamentMonitors[0].calibrated.mmPerRev * sensors.filamentMonitors[0].configured.mmPerRev)

set var.newESteps = var.newESteps + {floor(move.extruders[0].stepsPerMm / ((var.currentMeasured-var.totalDistanceBase)/var.extrusionDistance)*100)/100}

set var.totalDistanceBase = (sensors.filamentMonitors[0].calibrated.totalDistance / sensors.filamentMonitors[0].calibrated.mmPerRev * sensors.filamentMonitors[0].configured.mmPerRev)

G1 X{var.extrusionDistance} E{var.extrusionDistance} F30

G4 S1 ; wait for filament monitor send timeout

set var.currentMeasured = (sensors.filamentMonitors[0].calibrated.totalDistance / sensors.filamentMonitors[0].calibrated.mmPerRev * sensors.filamentMonitors[0].configured.mmPerRev)

echo "Current E-Steps: " ^ {move.extruders[0].stepsPerMm}
set var.newESteps = (var.newESteps + {floor(move.extruders[0].stepsPerMm / ((var.currentMeasured-var.totalDistanceBase)/var.extrusionDistance)*100)/100})
set var.newESteps = floor(var.newESteps / 3.0 * 100)/100

if var.newESteps < 600 && var.newESteps > 1000
  echo "Calculated E-Steps out of range - " ^ var.newESteps
  set global.ignoreMFMevents = false
  M591 D0 P0                                              ; reset filament sensor
  M99

echo "New E-Steps: " ^ var.newESteps

echo >{"0:/filaments/" ^ {move.extruders[0].filament} ^ "/config-auto-esteps.g"} "; calibration temperature: " ^ var.currentTemp
echo >>{"0:/filaments/" ^ {move.extruders[0].filament} ^ "/config-auto-esteps.g"} "M92 E" ^ var.newESteps

M92 E{var.newESteps} ; activate new e-steps

; start non linear calibration

G92 E0                                       ; reset e-steps

; https://www.bragitoff.com/2018/06/polynomial-fitting-c-program/
; speed to test
var x = var.extrusionSpeeds
; number of data points
var N = #var.x
; degree of polynomial
var n = 2
; echo "x: " ^ var.x
; echo "N: " ^ var.N
; echo "n: " ^ var.n

; array to store the y-axis data points
var y = vector(var.N, 0.0)

; gather y data points
;set var.y = {0.0, 0.0, 0.0118, 0.0207, 0.0247, 0.0356, 0.0507, 0.0613, 0.0751, 0.0922, 0.1234, 0.1438}

M591 D0 P0
G4 S1
M591 D0 P3 C{var.filamentMonitorPin} S2 R98:102 E0.2 L{var.filamentMonitorCircumference}    ; enable MFM on all moves

G4 S5 ; wait for restart of MFM

G91 ; relative moves
; 15mm
G1 X15 E15 F30

; the mfm should be calibrated now

if sensors.filamentMonitors[0].calibrated == null
  echo "Cannot calibrate filament monitor within 15mm - error!"
  set global.ignoreMFMevents = false
  M99

G4 S1 ; wait for filament monitor send timeout

; sensors.filamentMonitors[0].calibrated.totalDistance is including extrusion correction like pressure advance, non linear extrusion and so on ...
; move.extruders[0].rawPosition is the extrusion without correction values
; sensors.filamentMonitors[0].calibrated.totalDistance / sensors.filamentMonitors[0].calibrated.mmPerRev is the number of measured revolutions

var i = 0

var first = true
var check = false
var nle_a = 0
var nle_b = 0
var nn = var.n
var success = false
var mean_error = 0.0
var min_error = 100.0
var max_error = 0.0
var s = 0.0

while true
  ; gather y-values for the compensated x-values
  set var.i = 0
  set var.n = var.nn
  set var.mean_error = 0.0
  set var.min_error = 100.0
  set var.max_error = 0.0
  var errors = vector(var.N, 0.0)

  while {var.i < var.N}
    set var.totalDistanceBase = (sensors.filamentMonitors[0].calibrated.totalDistance / sensors.filamentMonitors[0].calibrated.mmPerRev * sensors.filamentMonitors[0].configured.mmPerRev)
    var comp_f = var.x[var.i] * 60
    if var.check == false && var.first == false
      set var.comp_f = var.comp_f * (1 + var.y[var.i])
    
    var currentCommanded = 50
    if var.comp_f < 100
      set var.currentCommanded = 25
    G1 X{mod(var.i,2)=0?var.currentCommanded:(var.currentCommanded*-1)} E{var.currentCommanded} F{var.comp_f}
    
    G4 S1 ; wait for filament monitor send timeout
    
    set var.currentMeasured = (sensors.filamentMonitors[0].calibrated.totalDistance / sensors.filamentMonitors[0].calibrated.mmPerRev * sensors.filamentMonitors[0].configured.mmPerRev)
  
    var error = (1.0-((var.currentMeasured-var.totalDistanceBase)/var.currentCommanded))
    set var.min_error = min(var.min_error, var.error)
    set var.max_error = max(var.max_error, var.error)
    set var.errors[var.i] = var.error

    echo "F" ^ {var.comp_f} ^ ": " ^ {var.error*100.0} ^ "% error."

    if var.comp_f < 60 && var.error >= 0.1
      echo "The filament error exceeds the expected value at low speed. This may be due to grinding. Repeating!"
      G1 E-10 F60 ; backoff some filament
      G1 E15 F60 ; extrude some material to get pass the grinding
      continue

    if var.check == false
      set var.y[var.i] = var.error
      if var.y[var.i] < 0.01
        if var.first == true && var.i < 1 && var.y[var.i] < -0.01
          echo "Calibrate E-Steps first."
          M99
        set var.y[var.i] = 0.01

      ; if the error is larger than 10% or more than twice as the previous value - stop 
      if var.y[var.i] > 0.1 || ( var.i > 0 && var.y[var.i-1] > 0.025 && var.y[var.i] > (var.y[var.i-1] * 2))
        if var.first == true && var.i < 1
          echo "Calibrate E-Steps first."
          M99
        set var.N = var.i
        echo "New N: " ^ var.N
        break

    set var.i = var.i + 1
  
  set var.first = false

  var k = 0
  while {var.k < var.N}
    set var.mean_error = var.mean_error + var.errors[var.k]
    set var.k = var.k + 1

  set var.mean_error = var.mean_error / var.N
  echo "mean error:" ^ var.mean_error

  set var.k = 0
  set var.s = 0.0

  while {var.k < var.N}
    set var.s = pow(var.errors[var.k] - var.mean_error, 2.0)
    set var.k = var.k + 1

  set var.s = sqrt(var.s / var.N)
  echo "standard deviation: " ^ var.s

  if var.check
    set var.check = false
    if var.s <= 0.005
      set var.success = true
      break
    elif var.s > 0.005 && var.s < 0.25
      M592 D0 A0 B0
      continue
    else
      set var.success = false
      break

  ; echo "y: " ^ var.y
  
  ; an array of size 2*n+1 for storing N, Sig xi, Sig xi^2, ...
  var X = vector(2*var.n+1, 0.0)
  ; echo "X: " ^ var.X
  
  set var.i = 0
  while {var.i <= (2*var.n)}
    var j = 0
    while {var.j < var.N}
      set var.X[var.i] = var.X[var.i] + pow(var.x[var.j], var.i)
      set var.j = var.j + 1
    set var.i = var.i + 1
  ; echo "X: " ^ var.X
  
  ; the normal argumented matrix
  
  var B = vector(var.n+1, vector(var.n+2, 0.0))
  var Y = vector(var.n+1, 0.0)
  ; echo "B: " ^ var.B
  ; echo "Y: " ^ var.Y
  
  set var.i = 0
  while {var.i <= var.n}
    var j = 0
    while {var.j < var.N}
      set var.Y[var.i] = var.Y[var.i] + pow(var.x[var.j], var.i) * var.y[var.j]
      set var.j = var.j + 1
    set var.i = var.i + 1
  ; echo "Y: " ^ var.Y
  
  set var.i = 0
  while {var.i <= var.n}
    var j = 0
    while {var.j <= var.n}
      set var.B[var.i][var.j] = var.X[var.i+var.j]
      set var.j = var.j + 1
    set var.i = var.i + 1
  ; echo "B: " ^ var.B
  
  set var.i = 0
  while {var.i <= var.n}
    set var.B[var.i][var.n+1] = var.Y[var.i]
    set var.i = var.i + 1
  ; echo "B: " ^ var.B
  
  var A = vector(var.n+1, 0.0)
  ; echo "A: " ^ var.A
  
  ; gaussEliminationLS
  
  var m = var.n + 1
  set var.n = var.n + 2
  
  set var.i = 0
  while {var.i < (var.m-1)}
    ;Partial Pivoting
    set var.k = var.i + 1
    while {var.k < var.m}
      ;If diagonal element(absolute vallue) is smaller than any of the terms below it
      if abs(var.B[var.i][var.i]) < abs(var.B[var.k][var.i])
        ;Swap the rows
        var j = 0
        while {var.j < var.n}
          var temp = var.B[var.i][var.j]
          set var.B[var.i][var.j] = var.B[var.k][var.j]
          set var.B[var.k][var.j] = var.temp
          set var.j = var.j + 1
      set var.k = var.k + 1
  
    ;Begin Gauss Elimination
    set var.k = var.i + 1
    while {var.k < var.m}
      var term = var.B[var.k][var.i] / var.B[var.i][var.i]
      var j = 0
      while {var.j < var.n}
        set var.B[var.k][var.j] = var.B[var.k][var.j] - var.term * var.B[var.i][var.j]
        set var.j = var.j + 1
      set var.k = var.k + 1
    set var.i = var.i + 1
  
  ;Begin Back-substitution
  set var.i = var.m - 1
  while {var.i >= 0}
    set var.A[var.i] = var.B[var.i][var.n-1]
    var j = var.i + 1
    while {var.j < (var.n - 1)}
      set var.A[var.i] = var.A[var.i] - var.B[var.i][var.j] * var.A[var.j]
      set var.j = var.j + 1
  
    set var.A[var.i] = var.A[var.i] / var.B[var.i][var.i]
    set var.i = var.i - 1
  
  set var.nle_a = var.A[1]
  set var.nle_b = var.A[2]

  M592 D0 A{var.A[1]} B{var.A[2]} L0.2
  echo "Test: M592 D0 A" ^ var.nle_a ^ " B" ^ var.nle_b ^ " L0.2"
  set var.check = true

if var.success
  echo "NLE calibration finished!"
  echo "M592 D0 A" ^ var.nle_a ^ " B" ^ var.nle_b ^ " L0.2"
  echo >{"0:/filaments/" ^ {move.extruders[0].filament} ^ "/config-auto-nle.g"} "; max F" ^ var.x[var.N-1] * 60 ^ " mm/min or " ^ var.x[var.N-1] * 6.38 ^ "mm³/s"
  echo >>{"0:/filaments/" ^ {move.extruders[0].filament} ^ "/config-auto-nle.g"} "; temp: " ^ var.currentTemp ^ " °C"
  echo >>{"0:/filaments/" ^ {move.extruders[0].filament} ^ "/config-auto-nle.g"} "; mean error: " ^ var.mean_error
  echo >>{"0:/filaments/" ^ {move.extruders[0].filament} ^ "/config-auto-nle.g"} "; min error: " ^ var.min_error
  echo >>{"0:/filaments/" ^ {move.extruders[0].filament} ^ "/config-auto-nle.g"} "; max error: " ^ var.max_error
  echo >>{"0:/filaments/" ^ {move.extruders[0].filament} ^ "/config-auto-nle.g"} "; standard deviation: " ^ var.s
  echo >>{"0:/filaments/" ^ {move.extruders[0].filament} ^ "/config-auto-nle.g"} "M592 D0 A" ^ var.nle_a ^ " B" ^ var.nle_b ^ " L0.2"
else
  echo "NLE calibration falied!"

; end calibration

G10                                          ; retract
G10 P0 R0 S0                                 ; disable hotend
M140 S0 R0                                   ; set bed heater to 0°
M144 P0                                      ; disable bed heater
T-1                                          ; unselect tool

M591 D0 P0                                   ; reset filament sensor
;M98 P"0:/sys/meltingplot/machine-override"              ; Load Machine specific overrides

set global.ignoreMFMevents = false