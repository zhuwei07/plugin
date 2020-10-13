@echo off

set INCLUDE=%~dp0\pump\include;D:\Microsoft Visual Studio\VC98\Include;%INCLUDE%
set LIB=%~dp0\pump\lib;D:\Microsoft Visual Studio\VC98\Lib;%LIB%
set PATH=%~dp0\amake;%~dp0\pump\bin;D:\Microsoft Visual Studio\VC98\Bin;D:\Microsoft Visual Studio\Common\MSDev98\Bin;%PATH%