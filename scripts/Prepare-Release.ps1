# Prepare-Release.ps1
# 准备 Release 资源，包括移动文件和生成哈希

param(
    [Parameter(Mandatory=$true)]
    [string]$ReleaseDir,
    
    [Parameter(Mandatory=$false)]
    [string[]]$IsoNames
)

if ($null -eq $IsoNames -or $IsoNames.Count -eq 0) {
    $IsoNames = @("tiny11.iso", "tiny11core.iso")
}

Write-Host "Preparing release assets..."

# Create release directory
if (-not (Test-Path $ReleaseDir)) {
    New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null
}

# Find generated ISO files
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

# Move files and calculate hashes
foreach ($iso in $outputIsos) {
    Write-Host ""
    Write-Host "Processing: $iso"
    
    $destPath = Join-Path $ReleaseDir $iso
    Move-Item -Path $iso -Destination $destPath -Force
    
    # Calculate SHA256 hash
    Write-Host "  Calculating SHA256 hash..."
    $hash = Get-FileHash -Path $destPath -Algorithm SHA256
    $hashFile = "$destPath.sha256"
    "$($hash.Hash)  $(Split-Path $destPath -Leaf)" | Out-File -FilePath $hashFile -Encoding ASCII
    
    # Display file information
    $fileSize = (Get-Item $destPath).Length / 1GB
    $fileSizeRounded = [math]::Round($fileSize, 2)
    Write-Host "  Size: $fileSizeRounded GB"
    Write-Host "  SHA256: $($hash.Hash)"
    Write-Host "  Hash file: $hashFile"
}

# Output to GitHub Actions environment variables
if ($env:GITHUB_OUTPUT) {
    "iso_count=$($outputIsos.Count)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}

Write-Host ""
Write-Host "================================================"
Write-Host "Release assets prepared successfully!"
Write-Host "  Location: $ReleaseDir"
Write-Host "  Files: $($outputIsos.Count) ISO(s) + checksums"
Write-Host "================================================"
Write-Host ""

exit 0
