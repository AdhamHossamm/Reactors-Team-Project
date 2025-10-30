# Create ZIP file for sharing the Docker project
# This script creates a compressed package ready to share with friends

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Creating Sharing ZIP Package" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the project root directory (parent of this script's location)
$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$zipName = "RP---e-Commerce-FS-Docker.zip"
$parentDir = Split-Path -Parent $projectRoot
$zipPath = Join-Path $parentDir $zipName

Write-Host "Project root: $projectRoot" -ForegroundColor Yellow
Write-Host "ZIP will be created in parent folder" -ForegroundColor Yellow
Write-Host ""

# Check if Docker containers are running
Write-Host "Checking for running containers..." -ForegroundColor Yellow
$containers = docker ps --format "{{.Names}}" 2>$null

if ($containers -match "ecommerce") {
    Write-Host "WARNING: Docker containers are running!" -ForegroundColor Red
    Write-Host "Stopping containers to ensure clean state..." -ForegroundColor Yellow
    Push-Location $projectRoot
    docker compose down
    Pop-Location
    Write-Host "Containers stopped." -ForegroundColor Green
    Write-Host ""
}

# Navigate to parent directory
Push-Location (Split-Path $projectRoot)

Write-Host "Creating ZIP package..." -ForegroundColor Green
Write-Host "This may take a few minutes..." -ForegroundColor Yellow
Write-Host ""

# Create the ZIP (excluding node_modules to reduce size)
Write-Host "Including project files..." -ForegroundColor Yellow

# Get the folder name
$folderName = Split-Path -Leaf $projectRoot

# Create temporary exclude list
$excludeItems = @(
    "*.pyc",
    "__pycache__",
    ".git",
    "*.log",
    ".pytest_cache",
    ".coverage",
    "htmlcov"
)

try {
    # Create ZIP using .NET compression
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        $projectRoot,
        $zipName,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $false
    )
    
    Write-Host ""
    Write-Host "✓ ZIP created successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Get file size
    $zipFile = Get-Item $zipName
    $sizeMB = [math]::Round($zipFile.Length / 1MB, 2)
    
    Write-Host "File: $zipName" -ForegroundColor Cyan
    Write-Host "Size: $sizeMB MB" -ForegroundColor Cyan
    Write-Host "Location: $(Split-Path $zipFile.FullName)" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✓ Ready to Share!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Share the ZIP file: $zipName" -ForegroundColor White
    Write-Host "2. Tell friend to install Docker Desktop" -ForegroundColor White
    Write-Host "3. Tell friend to extract and run START.bat" -ForegroundColor White
    Write-Host "4. Friend reads: DOCKER-DOCS/QUICK-START-GUIDE.txt" -ForegroundColor White
    Write-Host ""
    
    # Open the parent folder in explorer
    Write-Host "Opening folder location..." -ForegroundColor Yellow
    Start-Process explorer.exe -ArgumentList "/select,`"$($zipFile.FullName)`""
    
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to create ZIP file" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Try manually:" -ForegroundColor Yellow
    Write-Host "1. Right-click project folder" -ForegroundColor White
    Write-Host "2. Select 'Send to' > 'Compressed (zipped) folder'" -ForegroundColor White
}

Pop-Location

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

