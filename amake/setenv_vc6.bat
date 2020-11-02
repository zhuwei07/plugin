@echo off

set INCLUDE=%~dp0\pump\include;F:\Program Files\Microsoft Platform SDK\Include;D:\Microsoft Visual Studio\VC98\Include;%INCLUDE%
set LIB=%~dp0\pump\lib;F:\Program Files\Microsoft Platform SDK\Lib;D:\Microsoft Visual Studio\VC98\Lib;%LIB%
set PATH=%~dp0\amake;%~dp0\pump\bin;D:\Microsoft Visual Studio\VC98\Bin;D:\Microsoft Visual Studio\Common\MSDev98\Bin;%PATH%