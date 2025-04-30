;Medium setting 
M566 X1500 Y1500 Z300 C10000                        ; set maximum instantaneous speed changes (mm/min)
M203 X16000 Y16000 Z3000 C2000                        ; set maximum speeds (mm/min)
M201 X2000 Y2000 Z600 C400                         ; set accelerations (mm/s^2)

; Extruders
M566 E1000:1000                            ; set maximum instantaneous speed changes (mm/min)
M203 E15000:15000                          ; set maximum speeds (mm/min)
M201 E500:500                            ; set accelerations (mm/s^2)

M117 "Medium Settings"
M118 P0 S"Medium Settings"