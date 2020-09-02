CC=g++

all:tplmake pump pump_cut clearemptylines

tplmake: tplmake.c
	$(CC) -DUNIX -o tplmake tplmake.c
	cp tplmake ../bin

pump: pump.c
	$(CC) -o pump pump.c
	cp pump ../bin

pump_cut: pump_cut.c
	$(CC) -o pump_cut pump_cut.c
	cp pump_cut ../bin

clearemptylines: clearemptylines.c
	$(CC) -o clearemptylines clearemptylines.c
	cp clearemptylines ../bin

