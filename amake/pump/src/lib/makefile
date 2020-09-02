all: pump.lib

pump.lib: vector.obj stack.obj sgml.obj pumpsys.obj pump.obj env.obj
	lib /out:pump.lib vector.obj stack.obj sgml.obj pumpsys.obj pump.obj env.obj
	copy pump.lib ..\..\lib /y

vector.obj: vector.cpp vector.h
	$(CC) -c vector.cpp

stack.obj: stack.cpp stack.h vector.h
	$(CC) -c stack.cpp

sgml.obj: sgml.cpp sgml.h vector.h pumpsys.h
	$(CC) -c sgml.cpp

pumpsys.obj: pumpsys.cpp pumpsys.h
	$(CC) -c pumpsys.cpp

pump.obj: pump.cpp pump.h env.h
	$(CC) -c pump.cpp

env.obj: env.cpp env.h sgml.h stack.h
	$(CC) -c env.cpp

