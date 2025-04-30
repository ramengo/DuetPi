;Medium setting 
M566 X1500 Y1500                          ; set maximum instantaneous speed changes (mm/min)
M203 X32000 Y32000                          ; set maximum speeds (mm/min)
M201 X2000 Y2000                          ; set accelerations (mm/s^2)

M906 E1000:1000

; Extruders
M566 E1000:1000                            ; set maximum instantaneous speed changes (mm/min)
M203 E25000:25000                          ; set maximum speeds (mm/min)
M201 E20500:20500                            ; set accelerations (mm/s^2)

M117 "Medium Settings"
M118 P0 S"Medium Settings"

m591 d0 s0