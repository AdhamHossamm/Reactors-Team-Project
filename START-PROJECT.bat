@echo off
echo ============================================
echo Starting E-Commerce Full Stack Project
echo ============================================
echo.

REM Start Backend Server
echo [1/2] Starting Django Backend Server...
start "Django Backend" cmd /k "cd /d %~dp0backend && python manage.py runserver"

timeout /t 3 /nobreak >nul

REM Start Frontend Server  
echo [2/2] Starting Next.js Frontend Server...
start "Next.js Frontend" cmd /k "cd /d %~dp0frontend && npm run dev"

echo.
echo ============================================
echo Both servers are starting in separate windows!
echo ============================================
echo.
echo Backend:  http://localhost:8000
echo Admin:    http://localhost:8000/admin/
echo Frontend: http://localhost:3000
echo.
echo Press any key to exit this window...
pause >nul

