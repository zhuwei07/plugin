all:tplmake.exe pump.exe pump_cut.exe clearemptylines.exe

tplmake.exe: tplmake.c
	$(CC) -DWINDOWS -o tplmake.exe tplmake.c
	copy tplmake.exe ..\bin /y

pump.exe: pump.c
	$(CC) -o pump.exe pump.c
	copy pump.exe ..\bin /y

pump_cut.exe: pump_cut.c
	$(CC) -o pump_cut.exe pump_cut.c
	copy pump_cut.exe ..\bin /y

clearemptylines.exe: clearemptylines.c
	$(CC) -o clearemptylines.exe clearemptylines.c
	copy clearemptylines.exe ..\bin /y

