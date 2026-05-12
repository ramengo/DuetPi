if state.status = "idle"
	M141 S{heat.heaters[6].current + 0.7}
	M106 P5 S0
elif state.status = "processing"
	M106 P5 S255
	var totalLEDs = 78;
	var greenLEDs = 0
	var orangeLEDs = 0
	var printProgress = 0 
	if exists(job.file.filament[1])
		set var.printProgress = (job.rawExtrusion * 100) / (job.file.filament[0] + job.file.filament[1]);
	else
		set var.printProgress = (job.rawExtrusion * 100) / (job.file.filament[0]);
	set var.greenLEDs = ceil(var.totalLEDs * var.printProgress / 100);
	set var.orangeLEDs = var.totalLEDs - var.greenLEDs;
		if (var.greenLEDs > 0)
    		M150 E0 R0 U255 B0 P255 S{var.greenLEDs} F1  ; Sets LEDs to green based on print progress
		if (var.orangeLEDs > 0)
    		M150 E0 R0 U255 B0 P20 S{var.orangeLEDs} F0  ; Sets remaining LEDs to orange

; ── Tool Usage Counters (aggiornamento ogni 3 min) ────────────────────────
; Heaters: H0=bed  H1=T0  H2=T1  H3=T2  H4=T3  H5=T4  H6=camera
; Condizioni: bed>25°C, Tn>50°C, CH>25°C — indipendenti dallo stato stampa
if exists(global.tcReady)
	var tcNow = state.upTime
	var tcDelta = var.tcNow - global.tcLastUpdateS
	if var.tcDelta >= 180
		set global.tcLastUpdateS = var.tcNow
		if !global.tcReady
			set global.tcReady = true
		else
			if global.tool0Present && heat.heaters[1].current > 50
				set global.tcT0TimeS = global.tcT0TimeS + var.tcDelta
			if global.tool1Present && heat.heaters[2].current > 50
				set global.tcT1TimeS = global.tcT1TimeS + var.tcDelta
			if global.tool2Present && heat.heaters[3].current > 50
				set global.tcT2TimeS = global.tcT2TimeS + var.tcDelta
			if global.tool3Present && heat.heaters[4].current > 50
				set global.tcT3TimeS = global.tcT3TimeS + var.tcDelta
			if global.tool4Present && heat.heaters[5].current > 50
				set global.tcT4TimeS = global.tcT4TimeS + var.tcDelta
			if heat.heaters[0].current > 25
				set global.tcBedTimeS = global.tcBedTimeS + var.tcDelta
			if heat.heaters[6].current > 25
				set global.tcChamberTimeS = global.tcChamberTimeS + var.tcDelta
			; ── Scrivi file dati (ricaricabile come macro) ──────────────────
			echo >"0:/sys/toolstats_data.g" {"; toolstats_data.g — auto-generated uptime=" ^ state.upTime ^ "s"}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT0TimeS = " ^ global.tcT0TimeS}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT1TimeS = " ^ global.tcT1TimeS}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT2TimeS = " ^ global.tcT2TimeS}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT3TimeS = " ^ global.tcT3TimeS}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT4TimeS = " ^ global.tcT4TimeS}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcBedTimeS = " ^ global.tcBedTimeS}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcChamberTimeS = " ^ global.tcChamberTimeS}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT0Jobs = " ^ global.tcT0Jobs}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT1Jobs = " ^ global.tcT1Jobs}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT2Jobs = " ^ global.tcT2Jobs}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT3Jobs = " ^ global.tcT3Jobs}
			echo >>"0:/sys/toolstats_data.g" {"set global.tcT4Jobs = " ^ global.tcT4Jobs}
			; ── Scrivi riepilogo leggibile ──────────────────────────────────
			echo >"0:/sys/toolstats.txt" {"=== Elemento 5TC — Tool Stats | uptime " ^ state.upTime ^ "s ==="}
			echo >>"0:/sys/toolstats.txt" {"Status : " ^ state.status ^ "  |  tool: T" ^ state.currentTool ^ "  |  tools present: " ^ global.toolCount}
			echo >>"0:/sys/toolstats.txt" {"Temps  : Bed=" ^ heat.heaters[0].current ^ "C  CH=" ^ heat.heaters[6].current ^ "C"}
			if global.tool0Present
				echo >>"0:/sys/toolstats.txt" {"T0     : " ^ global.tcT0TimeS ^ "s  (" ^ (global.tcT0TimeS / 3600.0) ^ "h)  jobs=" ^ global.tcT0Jobs ^ "  H=" ^ heat.heaters[1].current ^ "C"}
			if global.tool1Present
				echo >>"0:/sys/toolstats.txt" {"T1     : " ^ global.tcT1TimeS ^ "s  (" ^ (global.tcT1TimeS / 3600.0) ^ "h)  jobs=" ^ global.tcT1Jobs ^ "  H=" ^ heat.heaters[2].current ^ "C"}
			if global.tool2Present
				echo >>"0:/sys/toolstats.txt" {"T2     : " ^ global.tcT2TimeS ^ "s  (" ^ (global.tcT2TimeS / 3600.0) ^ "h)  jobs=" ^ global.tcT2Jobs ^ "  H=" ^ heat.heaters[3].current ^ "C"}
			if global.tool3Present
				echo >>"0:/sys/toolstats.txt" {"T3     : " ^ global.tcT3TimeS ^ "s  (" ^ (global.tcT3TimeS / 3600.0) ^ "h)  jobs=" ^ global.tcT3Jobs ^ "  H=" ^ heat.heaters[4].current ^ "C"}
			if global.tool4Present
				echo >>"0:/sys/toolstats.txt" {"T4     : " ^ global.tcT4TimeS ^ "s  (" ^ (global.tcT4TimeS / 3600.0) ^ "h)  jobs=" ^ global.tcT4Jobs ^ "  H=" ^ heat.heaters[5].current ^ "C"}
			echo >>"0:/sys/toolstats.txt" {"Bed    : " ^ global.tcBedTimeS ^ "s  (" ^ (global.tcBedTimeS / 3600.0) ^ "h)"}
			echo >>"0:/sys/toolstats.txt" {"CH     : " ^ global.tcChamberTimeS ^ "s  (" ^ (global.tcChamberTimeS / 3600.0) ^ "h)"}
			if state.status = "processing"
				echo >>"0:/sys/toolstats.txt" {"Job    : " ^ job.file.fileName ^ "  progress=" ^ job.rawExtrusion ^ "mm"}
				echo >>"0:/sys/toolstats.txt" {"Extrud : E0=" ^ move.extruders[0].rawPosition ^ "mm  E1=" ^ move.extruders[1].rawPosition ^ "mm  E2=" ^ move.extruders[2].rawPosition ^ "mm  (sessione)"}