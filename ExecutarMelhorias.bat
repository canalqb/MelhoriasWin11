@echo off
title Melhorias Automaticas Windows 11
setlocal

::  Request admin privileges (UAC) silently
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

::  Run the automation script fully automatic
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0MelhoriasWin11.ps1"
pause