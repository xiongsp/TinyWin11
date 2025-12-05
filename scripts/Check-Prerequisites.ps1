# Check-Prerequisites.ps1
# Check if all prerequisites are met for building Tiny11

Write-Host ""
Write-Host "=========================================="
Write-Host "Tiny11 Builder - Prerequisites Check"
Write-Host "=========================================="
Write-Host ""

$allChecksPassed = $true

# Check 1: Administrator Privileges
Write-Host "[1/4] Checking Administrator privileges..."
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "  ✓ Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "  ✗ NOT running as Administrator" -ForegroundColor Red
    Write-Host "    Please run PowerShell as Administrator:" -ForegroundColor Yellow
    Write-Host "    1. Right-click PowerShell icon" -ForegroundColor Yellow
    Write-Host "    2. Select 'Run as Administrator'" -ForegroundColor Yellow
    $allChecksPassed = $false
}
Write-Host ""

# Check 2: PowerShell Version
Write-Host "[2/4] Checking PowerShell version..."
$psVersion = $PSVersionTable.PSVersion

if ($psVersion.Major -ge 7) {
    Write-Host "  ✓ PowerShell $($psVersion.Major).$($psVersion.Minor) (Recommended)" -ForegroundColor Green
} elseif ($psVersion.Major -eq 5) {
    Write-Host "  ⚠ PowerShell $($psVersion.Major).$($psVersion.Minor) (Minimum - PS7 recommended for tiny11maker.ps1)" -ForegroundColor Yellow
    Write-Host "    Consider installing PowerShell 7:" -ForegroundColor Yellow
    Write-Host "    winget install --id Microsoft.PowerShell" -ForegroundColor Yellow
} else {
    Write-Host "  ✗ PowerShell $($psVersion.Major).$($psVersion.Minor) (Too old)" -ForegroundColor Red
    $allChecksPassed = $false
}
Write-Host ""

# Check 3: PowerShell 7 Availability
Write-Host "[3/4] Checking PowerShell 7 (pwsh) availability..."
$pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Source

if ($pwshPath) {
    Write-Host "  ✓ PowerShell 7 found at: $pwshPath" -ForegroundColor Green
    
    # Get pwsh version
    try {
        $pwshVersionOutput = & pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
        Write-Host "    Version: $pwshVersionOutput" -ForegroundColor Gray
    } catch {
        Write-Host "    Could not get version" -ForegroundColor Gray
    }
} else {
    Write-Host "  ✗ PowerShell 7 (pwsh) not found" -ForegroundColor Red
    Write-Host "    tiny11maker.ps1 requires PowerShell 7" -ForegroundColor Yellow
    Write-Host "    Install with: winget install --id Microsoft.PowerShell" -ForegroundColor Yellow
    $allChecksPassed = $false
}
Write-Host ""

# Check 4: Disk Space
Write-Host "[4/4] Checking available disk space..."
try {
    $drive = Get-PSDrive -Name C -ErrorAction Stop
    $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
    
    if ($freeSpaceGB -gt 20) {
        Write-Host "  ✓ Available space on C:\ : $freeSpaceGB GB" -ForegroundColor Green
    } elseif ($freeSpaceGB -gt 10) {
        Write-Host "  ⚠ Available space on C:\ : $freeSpaceGB GB (Low - 20GB+ recommended)" -ForegroundColor Yellow
    } else {
        Write-Host "  ✗ Available space on C:\ : $freeSpaceGB GB (Insufficient - need 20GB+)" -ForegroundColor Red
        $allChecksPassed = $false
    }
} catch {
    Write-Host "  ⚠ Could not check disk space" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "=========================================="
if ($allChecksPassed) {
    Write-Host "✓ All prerequisites met!" -ForegroundColor Green
    Write-Host "You can proceed with building Tiny11." -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ Some prerequisites are not met." -ForegroundColor Red
    Write-Host "Please resolve the issues above before building." -ForegroundColor Red
    exit 1
}
