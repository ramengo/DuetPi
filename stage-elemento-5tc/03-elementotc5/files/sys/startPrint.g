M118 S"Print Start"
M591 D0 S1
M591 D1 S1
M150 R255 U40 B0 P20

; Incrementa job counter per ogni tool usato in questo lavoro
if exists(global.tcT0Jobs)
	if exists(job.file.filament[0]) && job.file.filament[0] > 0
		set global.tcT0Jobs = global.tcT0Jobs + 1
	if exists(job.file.filament[1]) && job.file.filament[1] > 0
		set global.tcT1Jobs = global.tcT1Jobs + 1
	if exists(job.file.filament[2]) && job.file.filament[2] > 0
		set global.tcT2Jobs = global.tcT2Jobs + 1
	if exists(job.file.filament[3]) && job.file.filament[3] > 0
		set global.tcT3Jobs = global.tcT3Jobs + 1
	if exists(job.file.filament[4]) && job.file.filament[4] > 0
		set global.tcT4Jobs = global.tcT4Jobs + 1