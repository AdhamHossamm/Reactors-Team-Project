@echo off
setlocal EnableDelayedExpansion
TITLE Full Stack Environment Setup (Next.js + Django + Supabase)
color 0A

echo =============================================================
echo         FULL STACK ENVIRONMENT INSTALLER (Windows 11)
echo =============================================================
echo.

:: -------------- SETUP --------------
set LOGFILE=%~dp0install_log.txt
echo Starting installation... > "%LOGFILE%"

:: Keep script open even on failure
set CONTINUE_ON_ERROR=true

:: Function to pause if error occurs
:pause_if_error
if %errorlevel% neq 0 (
    echo [!] Something went wrong, see log file: %LOGFILE%
    echo Continuing anyway...
)
goto :eof

:: ========== STEP 1: CHECK ADMIN RIGHTS ==========
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Please run this file as Administrator!
    echo Right-click and select "Run as Administrator".
    pause
    exit /b
)

:: ========== STEP 2: CHECK NODE & NPM ==========
echo [1/7] Checking Node.js...
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Node.js 20.x LTS ...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-BitsTransfer -Source 'https://nodejs.org/dist/v20.17.0/node-v20.17.0-x64.msi' -Destination $env:TEMP\node.msi; Start-Process msiexec.exe -ArgumentList '/i', \"$env:TEMP\node.msi\", '/quiet', '/norestart' -Wait"
    echo Node.js installed. >> "%LOGFILE%"
) else (
    echo Node.js is already installed. >> "%LOGFILE%"
)
call :pause_if_error

echo Checking npm...
npm -v >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing npm@10.8.2 ...
    npm install -g npm@10.8.2
) else (
    echo npm is already installed. >> "%LOGFILE%"
)
call :pause_if_error

:: ========== STEP 3: CHECK PYTHON & PIP ==========
echo.
echo [2/7] Checking Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Python 3.11.x ...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-BitsTransfer -Source 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe' -Destination $env:TEMP\python.exe; Start-Process $env:TEMP\python.exe -ArgumentList '/quiet', 'InstallAllUsers=1', 'PrependPath=1' -Wait"
    echo Python installed. >> "%LOGFILE%"
) else (
    echo Python is already installed. >> "%LOGFILE%"
)
call :pause_if_error

echo Checking pip...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Pip not found. Installing...
    python -m ensurepip
)
call :pause_if_error

:: ========== STEP 4: CHECK GIT ==========
echo.
echo [3/7] Checking Git...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Git 2.45.2 ...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-BitsTransfer -Source 'https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe' -Destination $env:TEMP\git.exe; Start-Process $env:TEMP\git.exe -ArgumentList '/VERYSILENT', '/NORESTART' -Wait"
    echo Git installed. >> "%LOGFILE%"
) else (
    echo Git is already installed. >> "%LOGFILE%"
)
call :pause_if_error

:: ========== STEP 5: CHECK NEXT.JS + REACT ==========
echo.
echo [4/7] Checking Next.js...
npm list -g next >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Next.js 14.2.4 + React 19.1.1 ...
    npm install -g next@14.2.4 react@19.1.1 react-dom@19.1.1
    echo Next.js stack installed. >> "%LOGFILE%"
) else (
    echo Next.js already installed. >> "%LOGFILE%"
)
call :pause_if_error

:: ========== STEP 6: CHECK SUPABASE CLI ==========
echo.
echo [5/7] Checking Supabase CLI...
supabase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Supabase CLI 1.x ...
    npm install -g supabase@1.177.5
    echo Supabase CLI installed. >> "%LOGFILE%"
) else (
    echo Supabase CLI already installed. >> "%LOGFILE%"
)
call :pause_if_error

:: ========== STEP 7: CHECK DJANGO + DEPENDENCIES ==========
echo.
echo [6/7] Checking Django...
pip show django >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Django 5 + DRF 3.15 ...
    pip install "Django>=5.0,<6.0" "djangorestframework>=3.15,<4.0" ^
        djangorestframework-simplejwt django-cors-headers psycopg2-binary ^
        python-dotenv gunicorn
    echo Django + DRF installed. >> "%LOGFILE%"
) else (
    echo Django already installed. >> "%LOGFILE%"
)
call :pause_if_error

:: ========== STEP 8: SUMMARY ==========
echo.
echo =============================================================
echo ✅ INSTALLATION COMPLETE!
echo =============================================================
echo Installed components:
echo - Node.js 20.x + npm 10.x
echo - Next.js 14 + React 19.1.1
echo - Python 3.11 + Django 5 + DRF 3.15
echo - Supabase CLI 1.x
echo - Git 2.45.2
echo -------------------------------------------------------------
echo Logs saved to: %LOGFILE%
echo =============================================================
pause
exit /b
