# Prepare-Release.ps1
# 准备 Release 资源，包括移动文件和生成哈希

param(
    [Parameter(Mandatory=$true)]
    [string]$ReleaseDir,
    
    [Parameter(Mandatory=$false)]
    [string[]]$IsoNames = @("tiny11.iso", "tiny11core.iso")
)

Write-Host "Preparing release assets..."

# 创建发布目录
if (-not (Test-Path $ReleaseDir)) {
    New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null
}

# 查找生成的 ISO 文件
$outputIsos = @()
foreach ($isoName in $IsoNames) {
    if (Test-Path $isoName) {
        $outputIsos += $isoName
    }
}

if ($outputIsos.Count -eq 0) {
    Write-Error "No ISO files were generated!"
    Write-Error "Expected files: $($IsoNames -join ', ')"
    exit 1
}

Write-Host "Found $($outputIsos.Count) ISO file(s)"

# 移动文件并计算哈希
foreach ($iso in $outputIsos) {
    Write-Host "`nProcessing: $iso"
    
    $destPath = Join-Path $ReleaseDir $iso
    Move-Item -Path $iso -Destination $destPath -Force
    
    # 计算 SHA256 哈希
    Write-Host "  Calculating SHA256 hash..."
    $hash = Get-FileHash -Path $destPath -Algorithm SHA256
    $hashFile = "$destPath.sha256"
    "$($hash.Hash)  $(Split-Path $destPath -Leaf)" | Out-File -FilePath $hashFile -Encoding ASCII
    
    # 显示文件信息
    $fileSize = (Get-Item $destPath).Length / 1GB
    $fileSizeRounded = [math]::Round($fileSize, 2)
    Write-Host "  Size: $fileSizeRounded GB"
    Write-Host "  SHA256: $($hash.Hash)"
    Write-Host "  Hash file: $hashFile"
}

# 输出到 GitHub Actions 环境变量
if ($env:GITHUB_OUTPUT) {
    "iso_count=$($outputIsos.Count)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}

Write-Host "`n================================================"
Write-Host "✓ Release assets prepared successfully!"
Write-Host "  Location: $ReleaseDir"
Write-Host "  Files: $($outputIsos.Count) ISO(s) + checksums"
Write-Host "================================================`n"

exit 0
