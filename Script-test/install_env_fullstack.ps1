<#
    Full Stack Environment Setup Script
    Compatible with Windows 11 / PowerShell 7+
    Stack: Node.js + Next.js + React + Python + Django + Supabase
#>

# ---------------------- INITIAL SETUP ----------------------
$ErrorActionPreference = "Continue"
$LogPath = Join-Path $PSScriptRoot "install_log.txt"
New-Item -Path $LogPath -ItemType File -Force | Out-Null
function Log($msg) {
    $time = Get-Date -Format "HH:mm:ss"
    "$time | $msg" | Tee-Object -FilePath $LogPath -Append
}

Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host " FULL STACK ENVIRONMENT INSTALLER (Next.js + Django + Supabase)"
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

# Require admin rights
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Run this script as Administrator!"
    Pause
    Exit
}

# Helper: check if command exists
function CmdExists($cmd) { return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null }

# ---------------------- NODE & NPM ----------------------
Log "[1/7] Checking Node.js"
if (!(CmdExists "node")) {
    Log "Node.js not found. Installing Node.js LTS 20.x..."
    winget install -e --id OpenJS.NodeJS.LTS -h
    Log "Node.js installed."
} else {
    Log "Node.js is already installed ($(node -v))"
}

if (!(CmdExists "npm")) {
    Log "npm not found. Installing npm..."
    npm install -g npm@10.8.2
    Log "npm installed."
} else {
    Log "npm is already installed ($(npm -v))"
}

# ---------------------- PYTHON & PIP ----------------------
Log "[2/7] Checking Python"
if (!(CmdExists "python")) {
    Log "Python not found. Installing Python 3.11..."
    winget install -e --id Python.Python.3.11 -h
    Log "Python installed."
} else {
    Log "Python is already installed ($(python --version))"
}

if (!(CmdExists "pip")) {
    Log "pip not found. Installing pip..."
    python -m ensurepip
    Log "pip installed."
} else {
    Log "pip is already installed ($(pip --version))"
}

# ---------------------- GIT ----------------------
Log "[3/7] Checking Git"
if (!(CmdExists "git")) {
    Log "Git not found. Installing Git..."
    winget install -e --id Git.Git -h
    Log "Git installed."
} else {
    Log "Git is already installed ($(git --version))"
}

# ---------------------- NEXT.JS + REACT ----------------------
Log "[4/7] Checking Next.js"
$next = npm list -g next --depth=0 2>$null
if ($LASTEXITCODE -ne 0) {
    Log "Installing Next.js 14.2.4 + React 19.1.1 ..."
    npm install -g next@14.2.4 react@19.1.1 react-dom@19.1.1
    Log "Next.js installed."
} else {
    Log "Next.js already installed."
}

# ---------------------- SUPABASE CLI ----------------------
Log "[5/7] Checking Supabase CLI"
if (!(CmdExists "supabase")) {
    Log "Installing Supabase CLI stable..."
    npm install -g supabase@1.177.5
    Log "Supabase CLI installed."
} else {
    Log "Supabase CLI already installed ($(supabase --version))"
}

# ---------------------- DJANGO & DRF ----------------------
Log "[6/7] Checking Django + Dependencies"
$pipList = pip list | Out-String
if ($pipList -notmatch "Django") {
    Log "Installing Django 5 + DRF 3.15 ..."
    pip install "Django>=5.0,<6.0" "djangorestframework>=3.15,<4.0" `
        djangorestframework-simplejwt django-cors-headers psycopg2-binary `
        python-dotenv gunicorn
    Log "Django stack installed."
} else {
    Log "Django already installed ($(django-admin --version))"
}

# ---------------------- SUMMARY ----------------------
Write-Host ""
Write-Host "=============================================================" -ForegroundColor Green
Write-Host " ✅ INSTALLATION COMPLETE!"
Write-Host "=============================================================" -ForegroundColor Green
Write-Host "- Node.js 20.x + npm 10.x"
Write-Host "- Next.js 14 + React 19.1.1"
Write-Host "- Python 3.11 + Django 5 + DRF 3.15"
Write-Host "- Supabase CLI 1.x"
Write-Host "- Git latest stable"
Write-Host "-------------------------------------------------------------"
Write-Host "Logs saved to: $LogPath"
Write-Host "============================================================="
Pause
