# Build-Tiny11.ps1
# 自动化构建 Tiny11 或 Tiny11 Core

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("tiny11", "tiny11core", "both")]
    [string]$BuildType,
    
    [Parameter(Mandatory=$true)]
    [string]$DriveLetter,
    
    [Parameter(Mandatory=$true)]
    [string]$ScriptPath,
    
    [Parameter(Mandatory=$false)]
    [int]$ImageIndex = 4
)

Write-Host "Building Tiny11..."
Write-Host "Build Type: $BuildType"
Write-Host "Drive Letter: $DriveLetter"
Write-Host "Script Path: $ScriptPath"

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Check if script exists
if (-not (Test-Path $ScriptPath)) {
    Write-Error "Script not found: $ScriptPath"
    exit 1
}

# Prepare automated input answers
# The script expects:
# 1. Execution policy response (yes/no)
# 2. Drive letter (e.g., E)
# 3. Image index (1-6, typically 4 for Pro)
# 4. Final Enter to continue
$answers = @(
    "yes"              # Execution policy confirmation
    $DriveLetter       # Drive letter without colon
    $ImageIndex        # Image index to build
    ""                 # Final confirmation
)

Write-Host ""
Write-Host "================================================"
Write-Host "Starting automated build process..."
Write-Host "Using mounted drive: ${DriveLetter}:"
Write-Host "Building image index: $ImageIndex"
Write-Host "================================================"
Write-Host ""

try {
    # Check if running as Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Error "This script requires Administrator privileges!"
        Write-Error "Please run PowerShell as Administrator and try again."
        exit 1
    }
    
    Write-Host "Running with Administrator privileges: OK"
    
    # Check if PowerShell 7 is available
    $pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
    
    if ($pwshPath) {
        Write-Host "Using PowerShell 7 to execute build script..."
        # Use PowerShell 7 to execute the script with automated input
        $answers | & $pwshPath -NoProfile -Command "& '$ScriptPath'"
    } else {
        Write-Host "PowerShell 7 not found, using current PowerShell version..."
        # Fallback to current PowerShell
        $result = $answers | & $ScriptPath
    }
    
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host ""
        Write-Host "================================================"
        Write-Host "Build completed successfully!"
        Write-Host "================================================"
        Write-Host ""
        exit 0
    } else {
        Write-Error "Build failed with exit code: $LASTEXITCODE"
        exit 1
    }
} catch {
    Write-Error "Build failed with error: $_"
    exit 1
}
