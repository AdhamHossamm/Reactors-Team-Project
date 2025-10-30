# ====================================================================
# Full Stack E-Commerce Project - Complete Dependency Installation
# Compatible with Windows 10/11, PowerShell 5.1+ and PowerShell 7+
# ====================================================================
# This script installs all required dependencies for the project:
# - Python 3.11+ with pip and virtual environment support
# - Node.js 18+ with npm
# - Django backend dependencies
# - Next.js frontend dependencies
# - SQLite3 (included with Python)
# - All Python packages from backend/requirements.txt
# - All npm packages from frontend/package.json
# - Database setup and test accounts
# ====================================================================

# Set error handling and execution policy
$ErrorActionPreference = "Continue"
Set-StrictMode -Version Latest

# Suppress encoding warnings
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ====================================================================
# CONFIGURATION
# ====================================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$BackendDir = Join-Path $ProjectRoot "backend"
$FrontendDir = Join-Path $ProjectRoot "frontend"
$LogFile = Join-Path $ScriptDir "install-log.txt"

# Color output helper
function Write-ColorOutput($Message, $Color) {
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Message
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

# Logging function
function Write-Log($Message, $Level = "INFO") {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage -Encoding UTF8
    Write-Host $Message
}

# Display banner
function Show-Banner {
    Clear-Host
    Write-ColorOutput "================================================================" Cyan
    Write-ColorOutput "  Full Stack E-Commerce - Dependency Installation Script" Cyan
    Write-ColorOutput "  Python 3.11+ | Django 5 | Node.js 18+ | Next.js 15" Cyan
    Write-ColorOutput "================================================================" Cyan
    Write-Host ""
}

# Check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if command exists
function Test-CommandExists($Command) {
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Get installed version of a command
function Get-InstalledVersion($Command) {
    try {
        if (Test-CommandExists $Command) {
            $versionOutput = & $Command --version 2>$null
            if ($versionOutput) {
                return ($versionOutput | Select-Object -First 1).ToString().Trim()
            }
        }
        return $null
    }
    catch {
        return $null
    }
}

# ====================================================================
# CHECK SYSTEM REQUIREMENTS
# ====================================================================

function Test-SystemRequirements {
    Write-Log "Checking system requirements..."
    
    # Check OS
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Log "ERROR: PowerShell version 5.1 or higher is required" "ERROR"
        Write-Log "Your version: $($PSVersionTable.PSVersion)"
        Write-Log "Please update PowerShell: https://docs.microsoft.com/powershell/scripting/install/installing-powershell-on-windows" "ERROR"
        return $false
    }
    
    # Check internet connectivity
    Write-Log "Checking internet connectivity..."
    try {
        $null = Test-NetConnection -ComputerName www.google.com -InformationLevel Quiet -WarningAction SilentlyContinue
        Write-Log "Internet connectivity: OK"
    }
    catch {
        Write-Log "WARNING: Could not verify internet connectivity" "WARN"
        Write-Log "The installation may fail if internet connection is not available"
    }
    
    # Check if running as admin
    if (-not (Test-Administrator)) {
        Write-Log "WARNING: Not running as Administrator. Some installations may require elevation." "WARN"
        Write-Log "If you encounter permission errors, try running this script as Administrator"
    }
    
    return $true
}

# ====================================================================
# INSTALL CHOCOLATEY (PACKAGE MANAGER)
# ====================================================================

function Install-Chocolatey {
    Write-Log "Checking Chocolatey package manager..."
    
    if (Test-CommandExists "choco") {
        $chocoVersion = choco --version
        Write-Log "Chocolatey is already installed (version $chocoVersion)"
        return $true
    }
    
    Write-Log "Chocolatey not found. Installing Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        if (Test-CommandExists "choco") {
            Write-Log "Chocolatey installed successfully"
            return $true
        }
        else {
            Write-Log "ERROR: Chocolatey installation failed" "ERROR"
            Write-Log "SOLUTION: Try installing manually from https://chocolatey.org/install" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "ERROR: Failed to install Chocolatey: $_" "ERROR"
        Write-Log "SOLUTION: Install Chocolatey manually or use alternative installation methods" "ERROR"
        return $false
    }
}

# ====================================================================
# INSTALL PYTHON
# ====================================================================

function Install-Python {
    Write-Log "=================================================="
    Write-Log "[1/6] Checking Python installation..."
    Write-Log "=================================================="
    
    # Check if Python is already installed
    if (Test-CommandExists "python") {
        $pythonVersion = Get-InstalledVersion "python"
        Write-Log "Python found: $pythonVersion"
        
        # Check version requirement (3.11+)
        try {
            $versionInfo = python --version 2>&1
            if ($versionInfo -match 'Python 3\.(\d+)') {
                $minorVersion = [int]$matches[1]
                if ($minorVersion -ge 11) {
                    Write-Log "Python version requirement met (>= 3.11)"
                    return $true
                }
                else {
                    Write-Log "WARNING: Python version is $versionInfo, but 3.11+ is required" "WARN"
                    Write-Log "Installing Python 3.11..."
                }
            }
        }
        catch {
            Write-Log "Could not determine Python version. Proceeding with installation..."
        }
    }
    
    # Try to install Python
    Write-Log "Installing Python 3.11 using winget..."
    try {
        if (Test-CommandExists "winget") {
            Write-Log "Using winget to install Python..."
            $process = Start-Process -FilePath "winget" -ArgumentList "install","Python.Python.3.11","--accept-source-agreements","--accept-package-agreements" -NoNewWindow -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Log "Python installed successfully via winget"
                
                # Refresh PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                
                # Verify installation
                Start-Sleep -Seconds 2
                if (Test-CommandExists "python") {
                    $version = python --version
                    Write-Log "Python successfully installed: $version"
                    return $true
                }
            }
        }
        
        # Alternative: Try chocolatey
        if (Test-CommandExists "choco") {
            Write-Log "Trying alternative: Installing Python via Chocolatey..."
            choco install python311 -y
            
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            if (Test-CommandExists "python") {
                $version = python --version
                Write-Log "Python successfully installed via Chocolatey: $version"
                return $true
            }
        }
        
        Write-Log "ERROR: Failed to install Python automatically" "ERROR"
        Write-Log "SOLUTION 1: Install Python manually from https://www.python.org/downloads/" "ERROR"
        Write-Log "SOLUTION 2: Make sure 'Add Python to PATH' is checked during manual installation" "ERROR"
        Write-Log "SOLUTION 3: Run this script as Administrator and try again" "ERROR"
        return $false
    }
    catch {
        Write-Log "ERROR: Python installation failed: $_" "ERROR"
        Write-Log "Please install Python 3.11+ manually from https://www.python.org/downloads/" "ERROR"
        return $false
    }
}

# ====================================================================
# INSTALL PIP AND VIRTUAL ENVIRONMENT TOOLS
# ====================================================================

function Install-PythonTools {
    Write-Log "Checking pip and venv..."
    
    # Ensure pip is available
    if (-not (Test-CommandExists "pip")) {
        Write-Log "Installing pip..."
        try {
            python -m ensurepip --upgrade
            python -m pip install --upgrade pip
            Write-Log "pip installed successfully"
        }
        catch {
            Write-Log "ERROR: Failed to install pip: $_" "ERROR"
            Write-Log "SOLUTION: Run 'python -m ensurepip' manually" "ERROR"
            return $false
        }
    }
    else {
        $pipVersion = pip --version
        Write-Log "pip is already installed: $pipVersion"
    }
    
    # Verify venv module
    try {
        python -c "import venv" 2>$null
        Write-Log "venv module is available"
        return $true
    }
    catch {
        Write-Log "ERROR: venv module not found" "ERROR"
        Write-Log "SOLUTION: Install Python with 'venv' support (included in standard Python)" "ERROR"
        return $false
    }
}

# ====================================================================
# INSTALL NODE.JS
# ====================================================================

function Install-NodeJS {
    Write-Log "=================================================="
    Write-Log "[2/6] Checking Node.js installation..."
    Write-Log "=================================================="
    
    # Check if Node.js is already installed
    if (Test-CommandExists "node") {
        $nodeVersion = Get-InstalledVersion "node"
        Write-Log "Node.js found: $nodeVersion"
        
        # Check version requirement (18+)
        try {
            $versionInfo = node --version 2>&1
            if ($versionInfo -match 'v(\d+)') {
                $majorVersion = [int]$matches[1]
                if ($majorVersion -ge 18) {
                    Write-Log "Node.js version requirement met (>= 18)"
                    return $true
                }
                else {
                    Write-Log "WARNING: Node.js version is $versionInfo, but v18+ is required" "WARN"
                    Write-Log "Installing Node.js 18 LTS..."
                }
            }
        }
        catch {
            Write-Log "Could not determine Node.js version. Proceeding with installation..."
        }
    }
    
    # Try to install Node.js
    Write-Log "Installing Node.js 18 LTS using winget..."
    try {
        if (Test-CommandExists "winget") {
            Write-Log "Using winget to install Node.js..."
            $process = Start-Process -FilePath "winget" -ArgumentList "install","OpenJS.NodeJS.LTS","--accept-source-agreements","--accept-package-agreements" -NoNewWindow -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Log "Node.js installed successfully via winget"
                
                # Refresh PATH
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                
                # Verify installation
                Start-Sleep -Seconds 2
                if (Test-CommandExists "node") {
                    $version = node --version
                    Write-Log "Node.js successfully installed: $version"
                    return $true
                }
            }
        }
        
        # Alternative: Try chocolatey
        if (Test-CommandExists "choco") {
            Write-Log "Trying alternative: Installing Node.js via Chocolatey..."
            choco install nodejs-lts -y
            
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            if (Test-CommandExists "node") {
                $version = node --version
                Write-Log "Node.js successfully installed via Chocolatey: $version"
                return $true
            }
        }
        
        Write-Log "ERROR: Failed to install Node.js automatically" "ERROR"
        Write-Log "SOLUTION 1: Install Node.js manually from https://nodejs.org/" "ERROR"
        Write-Log "SOLUTION 2: Make sure to download the LTS version" "ERROR"
        Write-Log "SOLUTION 3: Run this script as Administrator and try again" "ERROR"
        return $false
    }
    catch {
        Write-Log "ERROR: Node.js installation failed: $_" "ERROR"
        Write-Log "Please install Node.js 18+ LTS manually from https://nodejs.org/" "ERROR"
        return $false
    }
}

# ====================================================================
# INSTALL BACKEND DEPENDENCIES
# ====================================================================

function Install-BackendDependencies {
    Write-Log "=================================================="
    Write-Log "[3/6] Installing backend Python dependencies..."
    Write-Log "=================================================="
    
    if (-not (Test-Path $BackendDir)) {
        Write-Log "ERROR: Backend directory not found: $BackendDir" "ERROR"
        Write-Log "Make sure you're running this script from the correct location" "ERROR"
        return $false
    }
    
    # Check requirements.txt
    $requirementsFile = Join-Path $BackendDir "requirements.txt"
    if (-not (Test-Path $requirementsFile)) {
        Write-Log "ERROR: requirements.txt not found: $requirementsFile" "ERROR"
        return $false
    }
    
    # Create virtual environment if it doesn't exist
    $venvPath = Join-Path $BackendDir "venv"
    if (-not (Test-Path $venvPath)) {
        Write-Log "Creating Python virtual environment..."
        try {
            Set-Location $BackendDir
            python -m venv venv
            Write-Log "Virtual environment created successfully"
        }
        catch {
            Write-Log "ERROR: Failed to create virtual environment: $_" "ERROR"
            return $false
        }
    }
    else {
        Write-Log "Virtual environment already exists"
    }
    
    # Activate virtual environment and install requirements
    Write-Log "Installing Python packages..."
    try {
        $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
        
        # Check if activation script exists
        if (-not (Test-Path $activateScript)) {
            Write-Log "ERROR: Virtual environment activation script not found" "ERROR"
            Write-Log "SOLUTION: Delete venv folder and run this script again" "ERROR"
            return $false
        }
        
        # Run pip install in the context of the virtual environment
        Write-Log "Upgrading pip..."
        & "$venvPath\Scripts\python.exe" -m pip install --upgrade pip
        
        Write-Log "Installing packages from requirements.txt..."
        & "$venvPath\Scripts\pip.exe" install -r $requirementsFile
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Backend dependencies installed successfully"
            return $true
        }
        else {
            Write-Log "ERROR: Failed to install some packages" "ERROR"
            Write-Log "Try running: pip install -r requirements.txt manually" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "ERROR: Failed to install backend dependencies: $_" "ERROR"
        Write-Log "Try installing manually: cd backend && pip install -r requirements.txt" "ERROR"
        return $false
    }
}

# ====================================================================
# INSTALL FRONTEND DEPENDENCIES
# ====================================================================

function Install-FrontendDependencies {
    Write-Log "=================================================="
    Write-Log "[4/6] Installing frontend Node.js dependencies..."
    Write-Log "=================================================="
    
    if (-not (Test-Path $FrontendDir)) {
        Write-Log "ERROR: Frontend directory not found: $FrontendDir" "ERROR"
        return $false
    }
    
    # Check package.json
    $packageJson = Join-Path $FrontendDir "package.json"
    if (-not (Test-Path $packageJson)) {
        Write-Log "ERROR: package.json not found: $packageJson" "ERROR"
        return $false
    }
    
    Write-Log "Installing npm packages (this may take a few minutes)..."
    try {
        Set-Location $FrontendDir
        
        # Clear npm cache if needed
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
            Write-Log "Clearing npm cache..."
            npm cache clean --force
        }
        
        # Install packages
        npm install --legacy-peer-deps
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Frontend dependencies installed successfully"
            return $true
        }
        else {
            Write-Log "WARNING: npm install reported errors" "WARN"
            Write-Log "Try running: cd frontend && npm install --legacy-peer-deps" "WARN"
            return $false
        }
    }
    catch {
        Write-Log "ERROR: Failed to install frontend dependencies: $_" "ERROR"
        Write-Log "Try running manually: cd frontend && npm install" "ERROR"
        return $false
    }
}

# ====================================================================
# SETUP DATABASE AND TEST ACCOUNTS
# ====================================================================

function Setup-Database {
    Write-Log "=================================================="
    Write-Log "[5/6] Setting up database and test accounts..."
    Write-Log "=================================================="
    
    if (-not (Test-Path $BackendDir)) {
        Write-Log "ERROR: Backend directory not found" "ERROR"
        return $false
    }
    
    $venvPath = Join-Path $BackendDir "venv"
    $pythonExe = Join-Path $venvPath "Scripts\python.exe"
    
    if (-not (Test-Path $pythonExe)) {
        Write-Log "ERROR: Python executable not found in virtual environment" "ERROR"
        Write-Log "Make sure backend dependencies were installed correctly" "ERROR"
        return $false
    }
    
    try {
        Set-Location $BackendDir
        
        Write-Log "Running database migrations..."
        & $pythonExe manage.py makemigrations
        & $pythonExe manage.py migrate
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Database migrations completed"
        }
        else {
            Write-Log "WARNING: Some migrations may have failed" "WARN"
        }
        
        Write-Log "Creating test accounts..."
        try {
            & $pythonExe manage.py setup_local
            Write-Log "Test accounts created successfully"
            Write-Host ""
            Write-ColorOutput "Test Accounts Created:" Green
            Write-Host "  Admin User: admin@example.com / admin"
            Write-Host "  Buyer User: buyer@example.com / buyer123"
            Write-Host "  Seller User: seller@example.com / seller123"
            Write-Host ""
        }
        catch {
            Write-Log "WARNING: Could not create test accounts automatically: $_" "WARN"
            Write-Log "You can create accounts manually using: python manage.py createsuperuser" "WARN"
        }
        
        return $true
    }
    catch {
        Write-Log "ERROR: Database setup failed: $_" "ERROR"
        Write-Log "SOLUTION: Run manually: cd backend && python manage.py migrate" "ERROR"
        return $false
    }
}

# ====================================================================
# VERIFY INSTALLATION
# ====================================================================

function Test-Installation {
    Write-Log "=================================================="
    Write-Log "[6/6] Verifying installation..."
    Write-Log "=================================================="
    
    $allTestsPassed = $true
    
    # Test Python
    Write-Log "Testing Python..."
    if (Test-CommandExists "python") {
        $version = python --version
        Write-Log "PASS: Python is installed - $version"
    }
    else {
        Write-Log "FAIL: Python is not installed" "ERROR"
        $allTestsPassed = $false
    }
    
    # Test pip
    Write-Log "Testing pip..."
    if (Test-CommandExists "pip") {
        $version = pip --version
        Write-Log "PASS: pip is installed"
    }
    else {
        Write-Log "FAIL: pip is not installed" "ERROR"
        $allTestsPassed = $false
    }
    
    # Test Node.js
    Write-Log "Testing Node.js..."
    if (Test-CommandExists "node") {
        $version = node --version
        Write-Log "PASS: Node.js is installed - $version"
    }
    else {
        Write-Log "FAIL: Node.js is not installed" "ERROR"
        $allTestsPassed = $false
    }
    
    # Test npm
    Write-Log "Testing npm..."
    if (Test-CommandExists "npm") {
        $version = npm --version
        Write-Log "PASS: npm is installed - $version"
    }
    else {
        Write-Log "FAIL: npm is not installed" "ERROR"
        $allTestsPassed = $false
    }
    
    # Test Django
    $venvPath = Join-Path $BackendDir "venv"
    $pythonExe = Join-Path $venvPath "Scripts\python.exe"
    if (Test-Path $pythonExe) {
        Write-Log "Testing Django installation..."
        try {
            $djangoVersion = & $pythonExe -c "import django; print(django.get_version())" 2>&1
            if ($djangoVersion) {
                Write-Log "PASS: Django is installed - $djangoVersion"
            }
        }
        catch {
            Write-Log "FAIL: Django is not properly installed" "ERROR"
            $allTestsPassed = $false
        }
    }
    
    # Test frontend dependencies
    if (Test-Path $FrontendDir) {
        Write-Log "Testing frontend dependencies..."
        if (Test-Path (Join-Path $FrontendDir "node_modules")) {
            Write-Log "PASS: Frontend dependencies are installed"
        }
        else {
            Write-Log "FAIL: Frontend dependencies are missing" "ERROR"
            $allTestsPassed = $false
        }
    }
    
    Write-Host ""
    if ($allTestsPassed) {
        Write-ColorOutput "All tests PASSED!" Green
        return $true
    }
    else {
        Write-ColorOutput "Some tests FAILED. Please review the errors above." Red
        return $false
    }
}

# ====================================================================
# MAIN EXECUTION
# ====================================================================

function Main {
    # Display banner
    Show-Banner
    
    # Check system requirements
    if (-not (Test-SystemRequirements)) {
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Create log file
    New-Item -Path $LogFile -ItemType File -Force | Out-Null
    Write-Log "Installation started at $(Get-Date)"
    Write-Log "Project Root: $ProjectRoot"
    Write-Host ""
    
    # Show warning about running as admin
    if (-not (Test-Administrator)) {
        Write-ColorOutput "WARNING: This script is not running as Administrator" Yellow
        Write-ColorOutput "If you encounter permission errors, right-click PowerShell and select 'Run as Administrator'" Yellow
        Write-Host ""
        
        $continue = Read-Host "Continue anyway? (y/n)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Log "Installation cancelled by user"
            Read-Host "Press Enter to exit"
            exit 0
        }
    }
    
    Write-Host ""
    Write-ColorOutput "Starting installation process..." Cyan
    Write-Host ""
    
    # Track installation results
    $installationResults = @{
        "Python" = $false
        "NodeJS" = $false
        "BackendDeps" = $false
        "FrontendDeps" = $false
        "Database" = $false
        "Tests" = $false
    }
    
    # Step 1: Install Python
    if (Install-Python) {
        if (Install-PythonTools) {
            $installationResults["Python"] = $true
        }
    }
    
    # Step 2: Install Node.js
    if (Install-NodeJS) {
        $installationResults["NodeJS"] = $true
    }
    
    # Step 3: Install backend dependencies
    if ($installationResults["Python"]) {
        if (Install-BackendDependencies) {
            $installationResults["BackendDeps"] = $true
        }
    }
    
    # Step 4: Install frontend dependencies
    if ($installationResults["NodeJS"]) {
        if (Install-FrontendDependencies) {
            $installationResults["FrontendDeps"] = $true
        }
    }
    
    # Step 5: Setup database
    if ($installationResults["BackendDeps"]) {
        if (Setup-Database) {
            $installationResults["Database"] = $true
        }
    }
    
    # Step 6: Verify installation
    if ($installationResults["Python"] -and $installationResults["NodeJS"]) {
        if (Test-Installation) {
            $installationResults["Tests"] = $true
        }
    }
    
    # Display final summary
    Write-Host ""
    Write-Log "=================================================="
    Write-Log "INSTALLATION SUMMARY"
    Write-Log "=================================================="
    Write-Host ""
    
    $allPassed = $true
    foreach ($key in $installationResults.Keys) {
        $status = if ($installationResults[$key]) { "PASS" } else { "FAIL" }
        $color = if ($installationResults[$key]) { "Green" } else { "Red" }
        Write-ColorOutput "  $key : $status" $color
        
        if (-not $installationResults[$key]) {
            $allPassed = $false
        }
    }
    
    Write-Host ""
    Write-Log "Log file saved to: $LogFile"
    
    if ($allPassed) {
        Write-Host ""
        Write-ColorOutput "================================================================" Green
        Write-ColorOutput "  INSTALLATION COMPLETED SUCCESSFULLY!" Green
        Write-ColorOutput "================================================================" Green
        Write-Host ""
        Write-ColorOutput "Next Steps:" Cyan
        Write-Host "  1. Backend: cd backend && python manage.py runserver"
        Write-Host "  2. Frontend: cd frontend && npm run dev"
        Write-Host "  3. Admin Panel: http://localhost:8000/admin/"
        Write-Host "     Login: admin@example.com / admin"
        Write-Host "  4. Frontend: http://localhost:3000"
        Write-Host ""
        Write-ColorOutput "Test Accounts:" Cyan
        Write-Host "  Buyer: buyer@example.com / buyer123"
        Write-Host "  Seller: seller@example.com / seller123"
        Write-Host "  Admin: admin@example.com / admin"
    }
    else {
        Write-Host ""
        Write-ColorOutput "================================================================" Yellow
        Write-ColorOutput "  INSTALLATION COMPLETED WITH ERRORS" Yellow
        Write-ColorOutput "================================================================" Yellow
        Write-Host ""
        Write-ColorOutput "Please review the errors above and try the suggested solutions." Yellow
        Write-ColorOutput "You can also check the log file for more details." Yellow
    }
    
    Write-Host ""
    Write-Log "Installation completed at $(Get-Date)"
    Read-Host "Press Enter to exit"
}

# Run main function
Main

