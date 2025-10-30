@echo off
echo ============================================
echo Starting E-Commerce Platform Servers
echo ============================================
echo.

REM Check if we're in the right directory
if not exist "backend" (
    echo ERROR: backend directory not found!
    echo Please run this script from the project root directory.
    pause
    exit /b 1
)

if not exist "frontend" (
    echo ERROR: frontend directory not found!
    echo Please run this script from the project root directory.
    pause
    exit /b 1
)

echo [1/2] Starting Django Backend Server...
echo ----------------------------------------
start "Django Backend" cmd /k "cd /d "%~dp0backend" && python manage.py runserver"

timeout /t 3 /nobreak >nul

echo.
echo [2/2] Starting Next.js Frontend Server...
echo ----------------------------------------
start "Next.js Frontend" cmd /k "cd /d "%~dp0frontend" && npm run dev"

echo.
echo ============================================
echo Both servers are starting in separate windows!
echo ============================================
echo.
echo Backend:  http://localhost:8000
echo Frontend: http://localhost:3000
echo.
echo Press any key to exit this window...
pause >nul

