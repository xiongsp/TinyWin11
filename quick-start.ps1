# Quick Start Example
# 快速开始示例 - 本地构建 Tiny11

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Tiny11 Builder - Quick Start Example" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Right-click PowerShell" -ForegroundColor Yellow
    Write-Host "2. Select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "3. Run this script again" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Running with Administrator privileges: OK" -ForegroundColor Green
Write-Host ""

# Check if PowerShell 7 is available
$pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
if ($pwshPath) {
    Write-Host "PowerShell 7 detected: OK" -ForegroundColor Green
    Write-Host "Location: $pwshPath" -ForegroundColor Gray
} else {
    Write-Host "WARNING: PowerShell 7 not found!" -ForegroundColor Yellow
    Write-Host "Please install from: https://github.com/PowerShell/PowerShell/releases" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne 'y') {
        exit 1
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Step 1: Locate Windows 11 ISO" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Ask for ISO path
$isoPath = Read-Host "Enter the full path to your Windows 11 ISO file"

if (-not (Test-Path $isoPath)) {
    Write-Host "ERROR: ISO file not found: $isoPath" -ForegroundColor Red
    exit 1
}

Write-Host "ISO file found: OK" -ForegroundColor Green
Write-Host ""

# Mount ISO
Write-Host "Mounting ISO..." -ForegroundColor Yellow
try {
    $mount = Mount-DiskImage -ImagePath $isoPath -PassThru
    $drive = ($mount | Get-Volume).DriveLetter
    Write-Host "ISO mounted to drive: ${drive}:" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Failed to mount ISO: $_" -ForegroundColor Red
    exit 1
}

# Check for install.wim or install.esd
$installWim = "${drive}:\sources\install.wim"
$installEsd = "${drive}:\sources\install.esd"

if (Test-Path $installWim) {
    $imagePath = $installWim
} elseif (Test-Path $installEsd) {
    $imagePath = $installEsd
} else {
    Write-Host "ERROR: No install.wim or install.esd found in ISO" -ForegroundColor Red
    Dismount-DiskImage -ImagePath $isoPath
    exit 1
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Step 2: Select Windows Version" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available Windows versions in this ISO:" -ForegroundColor Yellow
Write-Host ""

# Get available images
$images = Get-WindowsImage -ImagePath $imagePath

foreach ($img in $images) {
    $sizeGB = [math]::Round($img.ImageSize / 1GB, 2)
    Write-Host "  [$($img.ImageIndex)] $($img.ImageName) - ${sizeGB} GB" -ForegroundColor White
}

Write-Host ""
Write-Host "Common choices:" -ForegroundColor Cyan
Write-Host "  - 1: Home Edition (smaller size)" -ForegroundColor Gray
Write-Host "  - 4: Professional Edition (recommended)" -ForegroundColor Gray
Write-Host ""

$imageIndex = Read-Host "Enter the image index number (press Enter for 4 - Professional)"
if ([string]::IsNullOrWhiteSpace($imageIndex)) {
    $imageIndex = 4
}

$selectedImage = $images | Where-Object { $_.ImageIndex -eq $imageIndex }
if (-not $selectedImage) {
    Write-Host "ERROR: Invalid image index: $imageIndex" -ForegroundColor Red
    Dismount-DiskImage -ImagePath $isoPath
    exit 1
}

Write-Host "Selected: $($selectedImage.ImageName)" -ForegroundColor Green
Write-Host ""

# Ask for build type
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Step 3: Select Build Type" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Build types:" -ForegroundColor Yellow
Write-Host "  1. Tiny11 (standard version)" -ForegroundColor White
Write-Host "  2. Tiny11 Core (minimal version)" -ForegroundColor White
Write-Host "  3. Both" -ForegroundColor White
Write-Host ""

$buildChoice = Read-Host "Enter your choice (1-3, press Enter for 1)"
if ([string]::IsNullOrWhiteSpace($buildChoice)) {
    $buildChoice = "1"
}

switch ($buildChoice) {
    "1" { $buildType = "tiny11"; $scriptName = "tiny11maker.ps1" }
    "2" { $buildType = "tiny11core"; $scriptName = "tiny11Coremaker.ps1" }
    "3" { $buildType = "both"; $scriptName = "tiny11maker.ps1" }
    default {
        Write-Host "ERROR: Invalid choice: $buildChoice" -ForegroundColor Red
        Dismount-DiskImage -ImagePath $isoPath
        exit 1
    }
}

Write-Host "Build type: $buildType" -ForegroundColor Green
Write-Host ""

# Check if script exists
if (-not (Test-Path ".\$scriptName")) {
    Write-Host "ERROR: Build script not found: $scriptName" -ForegroundColor Red
    Write-Host "Please download from: https://github.com/ntdevlabs/tiny11builder" -ForegroundColor Yellow
    Dismount-DiskImage -ImagePath $isoPath
    exit 1
}

# Confirm
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Ready to Build" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  ISO: $isoPath" -ForegroundColor White
Write-Host "  Drive: ${drive}:" -ForegroundColor White
Write-Host "  Version: $($selectedImage.ImageName)" -ForegroundColor White
Write-Host "  Index: $imageIndex" -ForegroundColor White
Write-Host "  Build Type: $buildType" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Start build? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Build cancelled" -ForegroundColor Yellow
    Dismount-DiskImage -ImagePath $isoPath
    exit 0
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Building Tiny11..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Run build
try {
    .\scripts\Build-Tiny11.ps1 `
        -BuildType $buildType `
        -DriveLetter $drive `
        -ScriptPath ".\$scriptName" `
        -ImageIndex $imageIndex
    
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host ""
        Write-Host "======================================" -ForegroundColor Green
        Write-Host "Build completed successfully!" -ForegroundColor Green
        Write-Host "======================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Output files should be in the current directory:" -ForegroundColor Yellow
        Get-ChildItem -Path . -Filter "tiny*.iso" | ForEach-Object {
            $sizeGB = [math]::Round($_.Length / 1GB, 2)
            Write-Host "  - $($_.Name) (${sizeGB} GB)" -ForegroundColor White
        }
    } else {
        Write-Host ""
        Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "Build failed with error: $_" -ForegroundColor Red
} finally {
    # Cleanup: Unmount ISO
    Write-Host ""
    Write-Host "Unmounting ISO..." -ForegroundColor Yellow
    Dismount-DiskImage -ImagePath $isoPath -ErrorAction SilentlyContinue
    Write-Host "Done!" -ForegroundColor Green
}

Write-Host ""
Read-Host "Press Enter to exit"
