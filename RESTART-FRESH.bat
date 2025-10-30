@echo off
title Fresh Start - Warning
color 0E

echo ========================================
echo   FRESH START - WILL DELETE ALL DATA
echo ========================================
echo.
echo This will:
echo - Stop all containers
echo - Delete all data (database, uploads)
echo - Rebuild from scratch
echo.
echo Are you sure? (Press any key to continue or Ctrl+C to cancel)
pause >nul

echo.
echo Stopping containers...
docker compose down -v

echo.
echo Rebuilding and starting...
docker compose up --build -d

if %errorlevel% equ 0 (
    echo.
    echo [✓] Fresh start complete!
    echo Opening application...
    timeout /t 2 /nobreak >nul
    start http://localhost:3000
    echo.
    echo View logs: docker compose logs -f
)

pause



