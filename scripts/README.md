# PowerShell Scripts

这个目录包含用于构建 Tiny11 的所有 PowerShell 脚本。这些脚本从 GitHub Actions 工作流中分离出来，便于维护、测试和调试。

## 脚本列表

### 1. Download-WindowsISO.ps1
从配置文件读取下载链接并下载 Windows 11 ISO。

**参数：**
- `LinksFile` (必需): ISO 下载链接配置文件路径
- `OutputPath` (必需): ISO 保存路径
- `MinSizeGB` (可选，默认: 3): 最小文件大小（GB），用于验证下载

**用法：**
```powershell
.\Download-WindowsISO.ps1 `
    -LinksFile "iso-links.txt" `
    -OutputPath "D:\downloads\Windows11.iso" `
    -MinSizeGB 3
```

**输出：**
- 下载的 ISO 文件
- GitHub Actions 环境变量: `iso_path`, `iso_url`

---

### 2. Build-Tiny11.ps1
自动化构建 Tiny11 或 Tiny11 Core。

**参数：**
- `BuildType` (必需): 构建类型 - `tiny11`, `tiny11core`, 或 `both`
- `DriveLetter` (必需): 挂载的 ISO 驱动器号
- `ScriptPath` (必需): tiny11maker.ps1 或 tiny11Coremaker.ps1 的路径

**用法：**
```powershell
.\Build-Tiny11.ps1 `
    -BuildType "tiny11" `
    -DriveLetter "E" `
    -ScriptPath ".\tiny11maker.ps1"
```

**功能：**
- 自动检测并使用 PowerShell 7（如果可用）
- tiny11maker.ps1 需要 PowerShell 7 才能正常运行
- 自动设置执行策略
- 通过管道提供自动化输入
- 错误处理和日志记录

**要求：**
- **管理员权限**（必需）
- PowerShell 7+ 推荐（GitHub Actions Windows runner 已预装）
- 如果本地测试，请先安装 [PowerShell 7](https://github.com/PowerShell/PowerShell/releases)

**本地运行：**
```powershell
# 必须以管理员身份运行 PowerShell
# 1. 右键点击 PowerShell 图标
# 2. 选择 "以管理员身份运行"
# 3. 然后执行脚本
```

---

### 3. Prepare-Release.ps1
准备 Release 资源，包括移动 ISO 文件和生成校验和。

**参数：**
- `ReleaseDir` (必需): Release 输出目录
- `IsoNames` (可选): 要查找的 ISO 文件名数组

**用法：**
```powershell
.\Prepare-Release.ps1 `
    -ReleaseDir "release" `
    -IsoNames @("tiny11.iso", "tiny11core.iso")
```

**输出：**
- 移动的 ISO 文件到 release 目录
- SHA256 校验和文件 (.sha256)
- GitHub Actions 环境变量: `iso_count`

---

### 4. Generate-ReleaseNotes.ps1
生成 GitHub Release 的说明文档。

**参数：**
- `ReleaseDir` (必需): Release 目录
- `WindowsVersion` (可选): Windows 版本
- `BuildType` (可选): 构建类型
- `SourceUrl` (可选): 源 ISO 下载 URL
- `RunNumber` (可选): GitHub Actions 运行编号
- `RunId` (可选): GitHub Actions 运行 ID
- `ServerUrl` (可选): GitHub 服务器 URL
- `Repository` (可选): 仓库名称

**用法：**
```powershell
.\Generate-ReleaseNotes.ps1 `
    -ReleaseDir "release" `
    -WindowsVersion "23H2" `
    -BuildType "both" `
    -SourceUrl "https://example.com/Win11.iso"
```

**输出：**
- release/RELEASE_NOTES.md
- GitHub Actions 环境变量: `release_title`

---

## 本地测试

### 测试下载脚本
```powershell
# 在项目根目录
.\scripts\Download-WindowsISO.ps1 `
    -LinksFile "iso-links.txt" `
    -OutputPath "test\Windows11.iso" `
    -MinSizeGB 0.1  # 测试时使用较小的阈值
```

### 测试构建脚本
```powershell
# ⚠️ 必须以管理员身份运行 PowerShell！

# 先手动挂载 ISO
$mount = Mount-DiskImage -ImagePath "path\to\Windows11.iso" -PassThru
$drive = ($mount | Get-Volume).DriveLetter

# 运行构建脚本（会自动检查管理员权限）
.\scripts\Build-Tiny11.ps1 `
    -BuildType "tiny11" `
    -DriveLetter $drive `
    -ScriptPath ".\tiny11maker.ps1"

# 清理
Dismount-DiskImage -ImagePath "path\to\Windows11.iso"
```

### 测试 Release 准备
```powershell
# 创建测试 ISO 文件
New-Item -ItemType File -Path "tiny11.iso" -Force
"Test content" | Out-File "tiny11.iso"

# 运行准备脚本
.\scripts\Prepare-Release.ps1 -ReleaseDir "test-release"
```

### 测试 Release Notes 生成
```powershell
.\scripts\Generate-ReleaseNotes.ps1 `
    -ReleaseDir "release" `
    -WindowsVersion "23H2" `
    -BuildType "both"
```

---

## 脚本修改指南

### 调整自动输入答案

如果 tiny11maker.ps1 或 tiny11Coremaker.ps1 需要不同的输入，修改 `Build-Tiny11.ps1` 中的 `$answers` 数组：

```powershell
$answers = @(
    $DriveLetter,           # 第一个问题：驱动器号
    "y",                    # 第二个问题：确认
    "1",                    # 第三个问题：选项
    "Pro",                  # 第四个问题：版本
    ""                      # 最后的空行
)
```

### 添加新功能

1. 创建新的 .ps1 文件
2. 添加参数验证和帮助信息
3. 实现错误处理
4. 在 YAML 工作流中调用

**示例：**
```powershell
# New-Script.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$RequiredParam,
    
    [Parameter(Mandatory=$false)]
    [string]$OptionalParam = "default"
)

# 实现功能
Write-Host "Processing..."

# 错误处理
try {
    # 你的代码
} catch {
    Write-Error "Failed: $_"
    exit 1
}

# 输出到 GitHub Actions
if ($env:GITHUB_OUTPUT) {
    "output_var=value" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
}

exit 0
```

---

## 故障排除

### 脚本执行策略错误
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

### 查看详细输出
```powershell
$VerbosePreference = "Continue"
.\scripts\YourScript.ps1 -Verbose
```

### 调试模式
在脚本开头添加：
```powershell
$DebugPreference = "Continue"
Set-PSDebug -Trace 1
```

---

## 最佳实践

1. **参数验证**: 使用 `[Parameter]` 和 `[ValidateSet]` 属性
2. **错误处理**: 使用 `try-catch` 块
3. **日志记录**: 使用 `Write-Host`, `Write-Warning`, `Write-Error`
4. **退出码**: 成功时 `exit 0`，失败时 `exit 1`
5. **环境变量**: 检查 `$env:GITHUB_OUTPUT` 是否存在
6. **编码**: 使用 UTF-8 编码保存文件

---

## 贡献

如果你改进了脚本或添加了新功能，请：
1. 更新此 README
2. 添加注释说明
3. 测试所有场景
4. 提交 Pull Request
