# Build-Tiny11.ps1
# 自动化构建 Tiny11 或 Tiny11 Core

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("tiny11", "tiny11core", "both")]
    [string]$BuildType,
    
    [Parameter(Mandatory=$true)]
    [string]$DriveLetter,
    
    [Parameter(Mandatory=$true)]
    [string]$ScriptPath
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
# Note: These answers need to be adjusted based on actual script prompts
$answers = @()
$answers += $DriveLetter  # Drive letter
$answers += "y"           # Confirmation
$answers += ""            # Extra empty line

Write-Host ""
Write-Host "================================================"
Write-Host "Starting automated build process..."
Write-Host "Using mounted drive: ${DriveLetter}:"
Write-Host "================================================"
Write-Host ""

try {
    # 使用管道自动输入答案
    $result = $answers | & $ScriptPath
    
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
