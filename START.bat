@echo off
title E-Commerce Platform - Docker Setup
color 0A

echo ========================================
echo   E-Commerce Platform - Docker Setup
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed!
    echo.
    echo Please install Docker Desktop from:
    echo https://www.docker.com/products/docker-desktop/
    echo.
    pause
    exit /b 1
)

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running!
    echo.
    echo Please start Docker Desktop first.
    echo Wait for the Docker icon in the system tray.
    echo.
    pause
    exit /b 1
)

echo [✓] Docker is installed and running
echo [✓] Docker version:
docker --version
echo.

echo ========================================
echo   Building and Starting Services
echo ========================================
echo.
echo This will take a few minutes the first time...
echo - Downloading base images (Python, Node.js)
echo - Installing dependencies
echo - Setting up database
echo - Creating test accounts (admin, seller, buyer)
echo - Creating seller profiles
echo - Creating categories
echo - Creating products
echo - Creating orders
echo.

REM Navigate to script directory
cd /d "%~dp0"

echo Starting containers in detached mode...
echo.
docker compose up --build -d

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to start containers!
    echo.
    echo Try running with logs to see the error:
    echo   docker compose up --build
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   ✓ SUCCESS! Containers are running
echo ========================================
echo.
timeout /t 3 /nobreak >nul

echo Opening the application...
start http://localhost:3000

echo.
echo ========================================
echo   ACCESS YOUR APPLICATION
echo ========================================
echo.
echo   Frontend:    http://localhost:3000
echo   Backend API: http://localhost:8000
echo   Admin Panel: http://localhost:8000/admin/
echo.
echo ========================================
echo   TEST ACCOUNTS
echo ========================================
echo.
echo   Admin:  admin@example.com  /  admin
echo   Seller: seller@example.com / seller123
echo   Buyer:  buyer@example.com  / buyer123
echo.
echo ========================================
echo   VIEW LOGS (in another terminal)
echo ========================================
echo   docker compose logs -f
echo.
echo ========================================
echo   STOP CONTAINERS
echo ========================================
echo   Press Ctrl+C or run: docker compose down
echo.

docker compose logs -f


