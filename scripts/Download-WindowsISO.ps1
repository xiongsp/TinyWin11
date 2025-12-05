# Download-WindowsISO.ps1
# 从配置文件读取链接并下载 Windows 11 ISO

param(
    [Parameter(Mandatory=$true)]
    [string]$LinksFile,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$false)]
    [double]$MinSizeGB = 3
)

Write-Host "Downloading Windows 11 ISO..."

# 创建下载目录
$downloadDir = Split-Path -Parent $OutputPath
if ([string]::IsNullOrEmpty($downloadDir)) {
    $downloadDir = "."
}

if (-not (Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
}

# Check configuration file exists
if (-not (Test-Path $LinksFile)) {
    Write-Error "ISO links file not found: $LinksFile"
    Write-Error "Please create iso-links.txt with download URLs"
    exit 1
}

# Read all non-comment, non-empty lines
$allLines = Get-Content $LinksFile
$isoUrls = @()
foreach ($line in $allLines) {
    $trimmedLine = $line.Trim()
    if ($trimmedLine -match '\S' -and $trimmedLine -notmatch '^\s*#') {
        $isoUrls += $trimmedLine
    }
}

if ($isoUrls.Count -eq 0) {
    Write-Error "No valid ISO URLs found in $LinksFile"
    Write-Error "Please add at least one download URL"
    exit 1
}

Write-Host "Found $($isoUrls.Count) ISO URL(s) in configuration file"

$downloadSuccess = $false
$successUrl = ""

# 依次尝试每个下载链接
foreach ($isoUrl in $isoUrls) {
    Write-Host ""
    Write-Host "================================================"
    Write-Host "Attempting to download from: $isoUrl"
    Write-Host "Saving to: $OutputPath"
    Write-Host "================================================"
    Write-Host ""
    
    try {
        # 使用 curl 下载，显示进度
        $startTime = Get-Date
        curl.exe -L --progress-bar -o $OutputPath $isoUrl
        $downloadTime = (Get-Date) - $startTime
        
        if (Test-Path $OutputPath) {
            $fileSize = (Get-Item $OutputPath).Length / 1GB
            
            # 验证文件大小是否合理
            if ($fileSize -gt $MinSizeGB) {
                $fileSizeRounded = [math]::Round($fileSize, 2)
                $downloadTimeStr = "{0:hh\:mm\:ss}" -f $downloadTime
                Write-Host ""
                Write-Host "================================================"
                Write-Host "Download completed successfully!"
                Write-Host "  File size: $fileSizeRounded GB"
                Write-Host "  Download time: $downloadTimeStr"
                Write-Host "  Source: $isoUrl"
                Write-Host "================================================"
                Write-Host ""
                
                $downloadSuccess = $true
                $successUrl = $isoUrl
                break
            } else {
                $fileSizeRounded = [math]::Round($fileSize, 2)
                Write-Warning "Downloaded file is too small ($fileSizeRounded GB). Trying next URL..."
                Remove-Item -Path $OutputPath -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {
        Write-Warning "Download failed: $_"
        Write-Warning "Trying next URL if available..."
        Remove-Item -Path $OutputPath -Force -ErrorAction SilentlyContinue
    }
}

if (-not $downloadSuccess) {
    Write-Host ""
    Write-Error "================================================"
    Write-Error "Failed to download ISO from all configured URLs"
    Write-Error "  Please check iso-links.txt and ensure URLs are valid"
    Write-Error "================================================"
    exit 1
}

# 输出结果到 GitHub Actions 环境变量（如果在 Actions 中运行）
if ($env:GITHUB_OUTPUT) {
    "iso_path=$OutputPath" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
    "iso_url=$successUrl" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}

Write-Host "Download completed successfully!"
exit 0
