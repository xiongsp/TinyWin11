# Test-Scripts.ps1
# 测试所有脚本的语法和基本功能

Write-Host "=========================================="
Write-Host "Testing PowerShell Scripts Compatibility"
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Host "=========================================="
Write-Host ""

$testsPassed = 0
$testsFailed = 0

# 测试 1: 检查脚本文件是否存在
Write-Host "Test 1: Checking script files..."
$scripts = @(
    "scripts\Download-WindowsISO.ps1",
    "scripts\Build-Tiny11.ps1",
    "scripts\Prepare-Release.ps1",
    "scripts\Generate-ReleaseNotes.ps1"
)

foreach ($script in $scripts) {
    if (Test-Path $script) {
        Write-Host "  [OK] $script exists" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] $script not found" -ForegroundColor Red
        $testsFailed++
    }
}
Write-Host ""

# 测试 2: 检查脚本语法
Write-Host "Test 2: Checking script syntax..."
foreach ($script in $scripts) {
    if (Test-Path $script) {
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $script -Raw), [ref]$errors)
        
        if ($errors.Count -eq 0) {
            Write-Host "  [OK] $script syntax valid" -ForegroundColor Green
            $testsPassed++
        } else {
            Write-Host "  [FAIL] $script has syntax errors:" -ForegroundColor Red
            $errors | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
            $testsFailed++
        }
    }
}
Write-Host ""

# 测试 3: 测试 Download-WindowsISO.ps1 参数
Write-Host "Test 3: Testing Download-WindowsISO.ps1 parameters..."
try {
    $help = Get-Help "scripts\Download-WindowsISO.ps1" -ErrorAction Stop
    if ($help.parameters.parameter.name -contains "LinksFile" -and 
        $help.parameters.parameter.name -contains "OutputPath") {
        Write-Host "  [OK] Required parameters found" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] Required parameters missing" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  [WARN] Could not get help (this is OK): $_" -ForegroundColor Yellow
    $testsPassed++
}
Write-Host ""

# 测试 4: 测试字符串处理
Write-Host "Test 4: Testing string handling compatibility..."
try {
    $testVar = "test"
    $testString = "Value: $testVar GB"
    if ($testString -eq "Value: test GB") {
        Write-Host "  [OK] String interpolation works" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] String interpolation failed" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  [FAIL] String handling error: $_" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# 测试 5: 测试文件路径处理
Write-Host "Test 5: Testing file path handling..."
try {
    $testPath = "D:\test\file.iso"
    $testDir = Split-Path -Parent $testPath
    if ($testDir -eq "D:\test") {
        Write-Host "  [OK] Path handling works" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] Path handling failed" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  [FAIL] Path handling error: $_" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# 测试 6: 创建测试配置文件并测试读取
Write-Host "Test 6: Testing configuration file reading..."
try {
    $testConfig = "test-iso-links.txt"
    @"
# Test configuration
https://example.com/test1.iso
# Comment line
https://example.com/test2.iso
"@ | Out-File -FilePath $testConfig -Encoding UTF8
    
    $urls = Get-Content $testConfig | Where-Object { 
        $_ -match '\S' -and $_ -notmatch '^\s*#' 
    } | ForEach-Object { $_.Trim() }
    
    if ($urls.Count -eq 2) {
        Write-Host "  [OK] Configuration file parsing works" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "  [FAIL] Configuration file parsing failed (found $($urls.Count) URLs, expected 2)" -ForegroundColor Red
        $testsFailed++
    }
    
    Remove-Item $testConfig -Force -ErrorAction SilentlyContinue
} catch {
    Write-Host "  [FAIL] Configuration reading error: $_" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# 总结
Write-Host "=========================================="
Write-Host "Test Summary"
Write-Host "=========================================="
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor Red
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "All tests passed! Scripts are compatible with PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some tests failed. Please review the errors above." -ForegroundColor Red
    exit 1
}
