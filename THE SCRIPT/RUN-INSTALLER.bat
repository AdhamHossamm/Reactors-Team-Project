@echo off
REM ========================================================================
REM Full Stack E-Commerce Project - Easy Installation Launcher
REM ========================================================================
REM This batch file provides an easy way to run the PowerShell installer
REM without dealing with execution policies or command-line parameters.
REM ========================================================================

setlocal

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
set "INSTALLER=%~dp0install-project-dependencies.ps1"

REM Display banner
cls
echo.
echo ========================================================================
echo   Full Stack E-Commerce - Dependency Installation
echo ========================================================================
echo.
echo   This will install all required dependencies for the project:
echo   - Python 3.11+ with pip
echo   - Node.js 18+ with npm
echo   - Django backend dependencies
echo   - Next.js frontend dependencies
echo.
echo ========================================================================
echo.

REM Check if the PowerShell script exists
if not exist "%INSTALLER%" (
    echo ERROR: Installation script not found!
    echo Expected location: %INSTALLER%
    echo.
    pause
    exit /b 1
)

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with Administrator privileges
    echo.
) else (
    echo WARNING: Not running as Administrator
    echo Some installations may require elevation
    echo.
)

REM Run the PowerShell script with bypass execution policy
echo Starting installation...
echo.
echo To close this window during installation, press Ctrl+C
echo.
echo ========================================================================
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%INSTALLER%"

REM Check exit code
if %errorLevel% == 0 (
    echo.
    echo ========================================================================
    echo   Installation completed successfully!
    echo ========================================================================
    echo.
) else (
    echo.
    echo ========================================================================
    echo   Installation completed with errors
    echo ========================================================================
    echo.
    echo Please check the log file for details:
    echo %SCRIPT_DIR%install-log.txt
    echo.
)

REM Pause before closing
echo.
pause

