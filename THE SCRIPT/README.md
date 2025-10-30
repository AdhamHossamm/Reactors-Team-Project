# Full Stack E-Commerce Project - Installation Script

Complete PowerShell script for installing all dependencies required for the E-Commerce Full Stack project.

## Quick Start

### Option 1: Simple Double-Click
```
Double-click on: RUN-INSTALLER.bat
```

### Option 2: Run from PowerShell
```powershell
cd "THE SCRIPT"
.\install-project-dependencies.ps1
```

### Option 3: Run from Command Prompt
```cmd
cd "THE SCRIPT"
powershell.exe -ExecutionPolicy Bypass -File install-project-dependencies.ps1
```

## What This Script Installs

### Backend Requirements
- Python 3.11+ (if not installed)
- pip (Python package manager)
- Django 5.0.13
- Django REST Framework 3.15.2
- JWT Authentication (djangorestframework-simplejwt)
- CORS Headers
- SQLite3 (included with Python)
- All packages from backend/requirements.txt

### Frontend Requirements
- Node.js 18+ LTS (if not installed)
- npm (Node package manager)
- Next.js 15.1.3
- React 19.0.0
- Tailwind CSS
- All packages from frontend/package.json

### Additional Setup
- Creates Python virtual environment
- Installs all Python dependencies
- Installs all Node.js dependencies
- Runs database migrations
- Creates test accounts (admin, buyer, seller)

## Prerequisites

### Required
- Windows 10 or Windows 11
- Internet connection
- Administrator access (recommended)

### Optional
- PowerShell 5.1+ (comes with Windows)
- Chocolatey package manager (installed automatically if needed)
- winget (installed automatically if needed)

## Installation Process

The script performs the following steps:

1. **System Requirements Check**
   - Verifies PowerShell version
   - Checks internet connectivity
   - Verifies administrator privileges

2. **Package Manager Setup**
   - Attempts to install Chocolatey if needed
   - Uses winget for installations

3. **Python Installation**
   - Checks for existing Python 3.11+
   - Installs Python 3.11 if not found
   - Installs and upgrades pip
   - Verifies venv module

4. **Node.js Installation**
   - Checks for existing Node.js 18+
   - Installs Node.js LTS if not found
   - Verifies npm installation

5. **Backend Setup**
   - Creates Python virtual environment
   - Installs all packages from requirements.txt
   - Runs database migrations
   - Creates test accounts

6. **Frontend Setup**
   - Installs all packages from package.json
   - Configures environment

7. **Verification**
   - Tests Python installation
   - Tests Node.js installation
   - Tests Django installation
   - Tests npm packages
   - Confirms database setup

## Test Accounts

After installation, the following test accounts are created:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@example.com | admin |
| Buyer | buyer@example.com | buyer123 |
| Seller | seller@example.com | seller123 |

## Running the Project

### Start Backend Server
```powershell
cd backend
python manage.py runserver
```
Backend runs on: http://localhost:8000
Admin panel: http://localhost:8000/admin/

### Start Frontend Server
```powershell
cd frontend
npm run dev
```
Frontend runs on: http://localhost:3000

## Logs

The installation creates a log file with detailed information:

```
THE SCRIPT/install-log.txt
```

Check this file if you encounter any issues.

## Troubleshooting

### Issue: "Execution Policy" Error

**Error**: Script cannot be executed due to execution policy.

**Solution 1**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Solution 2**: Use the provided batch file instead:
```
Double-click: RUN-INSTALLER.bat
```

### Issue: Python Installation Fails

**Error**: Cannot install Python automatically.

**Solution**:
1. Download Python 3.11+ from https://www.python.org/downloads/
2. Run the installer
3. **Important**: Check "Add Python to PATH" during installation
4. Run the script again

### Issue: Node.js Installation Fails

**Error**: Cannot install Node.js automatically.

**Solution**:
1. Download Node.js LTS from https://nodejs.org/
2. Install using the default settings
3. Run the script again

### Issue: "Permission Denied" Error

**Error**: Access denied when installing packages.

**Solution 1**: Run PowerShell as Administrator:
1. Right-click on PowerShell
2. Select "Run as Administrator"
3. Run the script again

**Solution 2**: Use the provided batch file:
```
Double-click: RUN-INSTALLER.bat
```
(This runs with administrator privileges)

### Issue: Backend Dependencies Fail to Install

**Error**: pip install fails for some packages.

**Solution 1**: Upgrade pip:
```powershell
cd backend
python -m pip install --upgrade pip
pip install -r requirements.txt
```

**Solution 2**: Install packages individually:
```powershell
cd backend
pip install Django==5.0.13
pip install djangorestframework==3.15.2
# ... etc
```

### Issue: Frontend Dependencies Fail to Install

**Error**: npm install fails.

**Solution 1**: Clear npm cache:
```powershell
cd frontend
npm cache clean --force
npm install --legacy-peer-deps
```

**Solution 2**: Try with different Node.js version:
```powershell
# Uninstall current Node.js
# Install Node.js 20.x LTS from nodejs.org
npm install
```

### Issue: Database Migration Errors

**Error**: Migrations fail to run.

**Solution**:
```powershell
cd backend
python manage.py makemigrations
python manage.py migrate
```

### Issue: Test Accounts Not Created

**Error**: setup_local command fails.

**Solution**: Create accounts manually:
```powershell
cd backend
python manage.py createsuperuser
```

Then create additional test accounts through Django admin.

## Manual Installation Alternative

If the automatic script fails, you can install everything manually:

### 1. Install Python
- Download from https://www.python.org/downloads/
- Run installer
- Check "Add Python to PATH"

### 2. Install Node.js
- Download LTS from https://nodejs.org/
- Run installer

### 3. Setup Backend
```powershell
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py setup_local
```

### 4. Setup Frontend
```powershell
cd frontend
npm install
```

## Verification

Run the Python test script to verify the installer:

```powershell
cd "THE SCRIPT"
python test_install_script.py
```

Expected output:
```
PASS: All tests passed!
The PowerShell script is ready for use.
```

## Features

- **Comprehensive Error Handling**: Catches and handles all common errors
- **Detailed Logging**: Logs all operations to install-log.txt
- **Progress Indicators**: Shows progress through 6 main steps
- **Automatic Recovery**: Attempts multiple installation methods
- **Clear Error Messages**: Provides specific solutions for each error
- **Compatibility Testing**: Tests all installations before completion
- **No Emojis**: ASCII-only output for maximum compatibility
- **UTF-8 Safe**: Proper encoding for Windows compatibility

## System Requirements

### Minimum
- Windows 10
- 4 GB RAM
- 2 GB free disk space
- Internet connection

### Recommended
- Windows 11
- 8 GB RAM
- 5 GB free disk space
- High-speed internet connection
- Administrator privileges

## File Locations

### Project Structure
```
RP---e-Commerce-FS/
├── THE SCRIPT/
│   ├── install-project-dependencies.ps1  (Main installer)
│   ├── RUN-INSTALLER.bat                  (Easy launcher)
│   ├── test_install_script.py             (Validator)
│   ├── install-log.txt                     (Log file)
│   └── README.md                           (This file)
├── backend/
│   ├── venv/                               (Python virtual environment)
│   ├── db.sqlite3                          (Database)
│   └── requirements.txt                    (Python packages)
└── frontend/
    ├── node_modules/                       (Node.js packages)
    └── package.json                        (Node.js dependencies)
```

## Support

For issues or questions:
1. Check the log file: `THE SCRIPT/install-log.txt`
2. Review the troubleshooting section above
3. Verify manual installation steps work
4. Check system requirements

## License

This script is part of the Full Stack E-Commerce project.

