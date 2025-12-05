# PowerShell Version Requirements

## Summary

This project uses different PowerShell versions for different tasks:

- **Helper Scripts**: Windows PowerShell 5.1 ✅
  - Download-WindowsISO.ps1
  - Prepare-Release.ps1
  - Generate-ReleaseNotes.ps1

- **Build Scripts**: PowerShell 7+ ✅ (Required)
  - tiny11maker.ps1 (from ntdevlabs/tiny11builder)
  - tiny11Coremaker.ps1 (from ntdevlabs/tiny11builder)

## Why PowerShell 7?

The official tiny11builder scripts (tiny11maker.ps1 and tiny11Coremaker.ps1) require PowerShell 7+ to function correctly. They use modern PowerShell features that are not available in Windows PowerShell 5.1.

## GitHub Actions Configuration

The workflow automatically uses the correct PowerShell version:

```yaml
# For helper scripts - Windows PowerShell 5.1
- name: Download Windows 11 ISO
  run: |
    .\scripts\Download-WindowsISO.ps1 -LinksFile "iso-links.txt"
  shell: powershell

# For build scripts - PowerShell 7
- name: Build Tiny11
  run: |
    .\scripts\Build-Tiny11.ps1 -BuildType "tiny11"
  shell: pwsh
```

## Local Development

### Install PowerShell 7

**Windows:**
```powershell
# Using winget
winget install --id Microsoft.PowerShell

# Or download from
# https://github.com/PowerShell/PowerShell/releases
```

**Verify Installation:**
```powershell
pwsh --version
# Should show: PowerShell 7.x.x
```

### Running Scripts Locally

**⚠️ IMPORTANT: Must run PowerShell as Administrator!**

```powershell
# 1. Right-click PowerShell icon
# 2. Select "Run as Administrator"
# 3. Then run the commands:

# Download ISO (can use either PowerShell version)
.\scripts\Download-WindowsISO.ps1 -LinksFile "iso-links.txt" -OutputPath "Windows11.iso"

# Build Tiny11 (automatically uses PowerShell 7 if available)
# This will check for Administrator privileges automatically
.\scripts\Build-Tiny11.ps1 -BuildType "tiny11" -DriveLetter "E" -ScriptPath ".\tiny11maker.ps1"
```

## Automatic Detection

The `Build-Tiny11.ps1` script automatically:
1. Checks if PowerShell 7 (pwsh) is available
2. Uses PowerShell 7 to execute tiny11maker.ps1 if available
3. Falls back to current PowerShell version if PowerShell 7 is not found

```powershell
# Build-Tiny11.ps1 automatically handles this:
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    # Use PowerShell 7
    pwsh -NoProfile -Command "& 'tiny11maker.ps1'"
} else {
    # Fallback (may fail if script requires PS7)
    & 'tiny11maker.ps1'
}
```

## Troubleshooting

### Error: "This script requires Administrator privileges!"

**Solution:** Run PowerShell as Administrator
1. Right-click PowerShell icon
2. Select "Run as Administrator"
3. Navigate to project directory
4. Run the script again

**Check if running as Administrator:**
```powershell
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "Running as Administrator: $isAdmin"
```

### Error: "This script requires PowerShell 7 or later"

**Solution:** Install PowerShell 7
```powershell
winget install --id Microsoft.PowerShell
```

### Error: "pwsh: command not found"

**Solution:** Add PowerShell 7 to PATH or use full path
```powershell
# Windows default installation path
& "C:\Program Files\PowerShell\7\pwsh.exe" -Version
```

### Local Testing

Test if your scripts work with both versions:

```powershell
# Test with Windows PowerShell 5.1
powershell.exe -File .\scripts\Download-WindowsISO.ps1 -LinksFile "iso-links.txt" -OutputPath "test.iso"

# Test with PowerShell 7
pwsh -File .\scripts\Build-Tiny11.ps1 -BuildType "tiny11" -DriveLetter "E" -ScriptPath ".\tiny11maker.ps1"
```

## References

- [PowerShell 7 Installation Guide](https://docs.microsoft.com/powershell/scripting/install/installing-powershell-on-windows)
- [PowerShell 7 GitHub Releases](https://github.com/PowerShell/PowerShell/releases)
- [Tiny11 Builder Repository](https://github.com/ntdevlabs/tiny11builder)

---

**Last Updated:** 2025-12-05
