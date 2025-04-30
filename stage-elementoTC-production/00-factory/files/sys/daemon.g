if state.status = "idle"
	M141 S{heat.heaters[3].current + 1}
if ((heat.heaters[0].active > 20 || heat.heaters[1].active > 20 || heat.heaters[2].active > 20 ) && state.status = "processing" && job.file.filament[0] = 0)
	var violet = 0;
	var pixel = 0
	set var.violet = ceil(heat.heaters[0].current * 255 / heat.heaters[0].active);
	set var.pixel = ceil(heat.heaters[0].current * 78 / heat.heaters[0].active);
	M150 E0 R255 U0 B{var.violet} P255 S{var.pixel - 1 } F1
	M150 E0 R255 U255 B255 P255 S1 F1
	M150 E0 R255 U0 B{var.violet} P20 S{78-var.pixel} F0
if ((heat.heaters[0].active =0 || heat.heaters[1].active =0 || heat.heaters[2].active =0 )&& state.status = "idle")
	M150 E0 R255 U85 B0 S78 P255


if state.status = "processing"
	var totalLEDs = 78;
	var greenLEDs = 0
	var orangeLEDs = 0
	var printProgress = 0 
	set var.printProgress = (job.rawExtrusion * 100) / job.file.filament[0];
	set var.greenLEDs = ceil(var.totalLEDs * var.printProgress / 100);
	set var.orangeLEDs = var.totalLEDs - var.greenLEDs;
	if (var.greenLEDs > 0) 
    	M150 E0 R0 U255 B0 P255 S{var.greenLEDs} F1  ; Sets LEDs to green based on print progress
	if (var.orangeLEDs > 0) 
    	M150 E0 R0 U255 B0 P20 S{var.orangeLEDs} F0  ; Sets remaining LEDs to orange