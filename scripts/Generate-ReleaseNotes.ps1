# Generate-ReleaseNotes.ps1
# 生成 Release 说明文档

param(
    [Parameter(Mandatory=$true)]
    [string]$ReleaseDir,
    
    [Parameter(Mandatory=$false)]
    [string]$WindowsVersion = "latest",
    
    [Parameter(Mandatory=$false)]
    [string]$BuildType = "both",
    
    [Parameter(Mandatory=$false)]
    [string]$SourceUrl = "",
    
    [Parameter(Mandatory=$false)]
    [string]$RunNumber = "0",
    
    [Parameter(Mandatory=$false)]
    [string]$RunId = "0",
    
    [Parameter(Mandatory=$false)]
    [string]$ServerUrl = "https://github.com",
    
    [Parameter(Mandatory=$false)]
    [string]$Repository = "unknown/unknown"
)

Write-Host "Generating release notes..."

$buildDate = Get-Date -Format "yyyy-MM-dd"
$buildDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"

# 创建 Release Notes
$releaseNotes = "# Tiny11 Build - $buildDate`n`n"
$releaseNotes += "## Build Information`n"
$releaseNotes += "- **Windows Version**: $WindowsVersion`n"
$releaseNotes += "- **Build Type**: $BuildType`n"
$releaseNotes += "- **Build Date**: $buildDateTime`n"
$releaseNotes += "- **Workflow Run**: [$RunNumber]($ServerUrl/$Repository/actions/runs/$RunId)`n`n"
$releaseNotes += "## Generated ISOs`n"

# 添加生成的 ISO 信息
$isoFiles = Get-ChildItem -Path "$ReleaseDir\*.iso" -ErrorAction SilentlyContinue

if ($isoFiles) {
    foreach ($isoFile in $isoFiles) {
        $fileSize = [math]::Round($isoFile.Length / 1GB, 2)
        $hashFile = "$($isoFile.FullName).sha256"
        
        if (Test-Path $hashFile) {
            $hashContent = Get-Content $hashFile
            $hash = $hashContent.Split()[0]
        } else {
            $hash = "Not available"
        }
        
        $releaseNotes += "`n### $($isoFile.Name)"
        $releaseNotes += "`n- **Size**: $fileSize GB"
        $releaseNotes += "`n- **SHA256**: ``$hash``"
        $releaseNotes += "`n"
    }
} else {
    $releaseNotes += "`n*No ISO files found*`n"
}

# 添加源 ISO 信息
if ($SourceUrl) {
    $releaseNotes += "`n## Source ISO`n"
    $releaseNotes += "- Downloaded from: $SourceUrl`n"
}

# 添加安装说明和免责声明
$releaseNotes += "`n## Installation Notes`n"
$releaseNotes += "1. Download the ISO file`n"
$releaseNotes += "2. Verify the SHA256 checksum`n"
$releaseNotes += "3. Create a bootable USB drive using Rufus or similar tool`n"
$releaseNotes += "4. Boot from the USB drive and follow the installation process`n`n"
$releaseNotes += "## Credits`n"
$releaseNotes += "- Built using [tiny11builder](https://github.com/ntdevlabs/tiny11builder)`n"
$releaseNotes += "- Based on Windows 11 from Microsoft`n`n"
$releaseNotes += "## Disclaimer`n"
$releaseNotes += "This is a modified version of Windows 11. Use at your own risk.`n"

# 保存到文件
$outputFile = Join-Path $ReleaseDir "RELEASE_NOTES.md"
$releaseNotes | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "Release notes saved to: $outputFile"

# 输出标题到 GitHub Actions
if ($env:GITHUB_OUTPUT) {
    $releaseTitle = "Tiny11 Build - $buildDate"
    "release_title=$releaseTitle" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}

Write-Host "✓ Release notes generated successfully!"
exit 0
