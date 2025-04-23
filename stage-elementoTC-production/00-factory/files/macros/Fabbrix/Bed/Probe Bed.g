M190 S55
T-1 
G29 S2
M561
G32        ; set Z probe type to bltouch and the dive height + speeds
T0 P0
G1 X500 Y300 F2000
G30 S-2
G29 K0 S0
T-1 P0
G1 Z100 F1000
