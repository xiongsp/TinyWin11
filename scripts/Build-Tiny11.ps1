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

# 设置执行策略
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# 检查脚本是否存在
if (-not (Test-Path $ScriptPath)) {
    Write-Error "Script not found: $ScriptPath"
    exit 1
}

# 准备自动输入的答案
# 注意：这些答案需要根据实际脚本的提示来调整
$answers = @(
    $DriveLetter,  # 驱动器号
    "y",           # 确认
    ""             # 额外的空行
)

Write-Host "`n================================================"
Write-Host "Starting automated build process..."
Write-Host "Using mounted drive: ${DriveLetter}:"
Write-Host "================================================`n"

try {
    # 使用管道自动输入答案
    $answers | & $ScriptPath
    
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host "`n================================================"
        Write-Host "✓ Build completed successfully!"
        Write-Host "================================================`n"
        exit 0
    } else {
        Write-Error "Build failed with exit code: $LASTEXITCODE"
        exit 1
    }
} catch {
    Write-Error "Build failed with error: $_"
    exit 1
}
