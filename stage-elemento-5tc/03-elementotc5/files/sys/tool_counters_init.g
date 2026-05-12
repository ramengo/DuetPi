; Tool Usage Counters — init globali (Elemento 5TC)
; Valori 0 di default; sovrascrittti da toolstats_data.g se il file esiste (persistenza cross-reboot).
; Heater map: H0=bed  H1=T0  H2=T1  H3=T2  H4=T3  H5=T4  H6=camera

global tcT0TimeS      = 0       ; secondi con T0 > 50°C
global tcT1TimeS      = 0       ; secondi con T1 > 50°C
global tcT2TimeS      = 0       ; secondi con T2 > 50°C
global tcT3TimeS      = 0       ; secondi con T3 > 50°C
global tcT4TimeS      = 0       ; secondi con T4 > 50°C
global tcBedTimeS     = 0       ; secondi con bed > 25°C
global tcChamberTimeS = 0       ; secondi con camera > 25°C
global tcT0Jobs       = 0       ; stampe avviate con filamento su E0
global tcT1Jobs       = 0       ; stampe avviate con filamento su E1
global tcT2Jobs       = 0       ; stampe avviate con filamento su E2
global tcT3Jobs       = 0       ; stampe avviate con filamento su E3
global tcT4Jobs       = 0       ; stampe avviate con filamento su E4
global tcLastUpdateS  = 0       ; uptime all'ultimo aggiornamento (non persistito)
global tcReady        = false   ; salta prima iterazione daemon (intervallo non valido)
