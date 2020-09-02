@echo off
mkdir bin
mkdir include
mkdir lib
copy src\lib\pump.h include
cd src
copy pump.c.dos pump.c
copy makefile.dos makefile
nmake
cd lib
copy makefile.dos makefile
nmake
cd ..\..
echo please read demo\autoexec.bat to setup the running enviroment
