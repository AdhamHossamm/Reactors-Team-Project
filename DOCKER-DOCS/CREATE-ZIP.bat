@echo off
REM Quick launcher for creating the sharing ZIP file

cd /d "%~dp0\.."

echo Creating sharing ZIP package...
echo.

powershell -ExecutionPolicy Bypass -File "DOCKER-DOCS\CREATE-SHARING-ZIP.ps1"



