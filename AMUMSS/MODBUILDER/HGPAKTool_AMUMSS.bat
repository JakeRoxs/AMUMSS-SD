@echo off
SETLOCAL EnableDelayedExpansion ENABLEEXTENSIONS
cd /d "%~dp0"



if not [%*]==[] (
	hgpaktool.exe -U -N -O "C:\UNPACKED_NMS" %*
)

pause