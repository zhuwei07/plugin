@echo off
set "amakeroot=%~dp0"
nmake /NOLOGO -f "%amakeroot%windows\makefile.win" prjfile=%1 amakeroot="%amakeroot%"