# 自动化构建功能说明

## 概述

Tiny11 Builder CI/CD 现已支持完全自动化构建,无需任何手动交互。系统会自动处理所有构建过程中的选择和确认。

## 新增功能

### 1. 镜像索引自动选择

不再需要手动选择 Windows 版本,通过参数指定即可:

**GitHub Actions 工作流:**
- 在触发工作流时选择 `image_index` (1-6)
- 默认值: `4` (Windows 11 专业版)

**本地构建:**
```powershell
.\scripts\Build-Tiny11.ps1 `
    -BuildType "tiny11" `
    -DriveLetter "E" `
    -ScriptPath ".\tiny11maker.ps1" `
    -ImageIndex 4
```

### 2. 镜像版本对照表

| 索引 | 版本名称 | 说明 |
|------|---------|------|
| 1 | 家庭版 | 基础版本 |
| 2 | 家庭单语言版 | OEM 预装版 |
| 3 | 教育版 | 教育机构版 |
| **4** | **专业版** | **推荐** |
| 5 | 专业教育版 | 教育专业版 |
| 6 | 专业工作站版 | 高性能版 |

详细说明: [image-index.md](image-index.md)

## 自动化输入流程

构建脚本会自动提供以下输入:

```
1. 执行策略确认 → "yes"
2. 驱动器字母 → 自动检测 (如 "E")
3. 镜像索引 → 用户指定 (默认 4)
4. 最终确认 → 自动回车
```

## 使用示例

### GitHub Actions

1. 进入 Actions 页面
2. 选择 "Build Tiny11 ISO" 工作流
3. 点击 "Run workflow"
4. 配置参数:
   - Windows version: `25H2`
   - Build type: `both` / `tiny11` / `tiny11core`
   - **Image index: `4`** (新增)
5. 点击 "Run workflow" 开始构建

### 本地构建示例

**构建专业版 (推荐):**
```powershell
# 1. 挂载 ISO
$mount = Mount-DiskImage -ImagePath ".\Windows11.iso" -PassThru
$drive = ($mount | Get-Volume).DriveLetter

# 2. 运行构建
.\scripts\Build-Tiny11.ps1 `
    -BuildType "tiny11" `
    -DriveLetter $drive `
    -ScriptPath ".\tiny11maker.ps1" `
    -ImageIndex 4

# 3. 卸载 ISO
Dismount-DiskImage -ImagePath ".\Windows11.iso"
```

**构建家庭版 (轻量):**
```powershell
.\scripts\Build-Tiny11.ps1 `
    -BuildType "tiny11" `
    -DriveLetter $drive `
    -ScriptPath ".\tiny11maker.ps1" `
    -ImageIndex 1
```

**同时构建两个版本:**
```powershell
.\scripts\Build-Tiny11.ps1 `
    -BuildType "both" `
    -DriveLetter $drive `
    -ScriptPath ".\tiny11maker.ps1" `
    -ImageIndex 4
```

## 技术实现

### 自动化输入机制

```powershell
# Build-Tiny11.ps1 中的实现
$answers = @(
    "yes",              # 执行策略确认
    $DriveLetter,       # 驱动器字母
    $ImageIndex,        # 镜像索引
    ""                  # 最终确认
)

# 通过管道传递给 PowerShell 7
$answers | & pwsh -NoProfile -Command "& '$ScriptPath'"
```

### PowerShell 版本管理

- **Helper Scripts**: PowerShell 5.1 (Windows PowerShell)
  - Download-WindowsISO.ps1
  - Prepare-Release.ps1
  - Generate-ReleaseNotes.ps1

- **Build Scripts**: PowerShell 7+ (pwsh)
  - tiny11maker.ps1
  - tiny11Coremaker.ps1

Build-Tiny11.ps1 会自动检测并使用正确的 PowerShell 版本。

## 常见问题

### Q1: 如何知道我的 ISO 包含哪些版本?

```powershell
# 挂载 ISO
$mount = Mount-DiskImage -ImagePath ".\Windows11.iso" -PassThru
$drive = ($mount | Get-Volume).DriveLetter

# 查看所有版本
Get-WindowsImage -ImagePath "${drive}:\sources\install.wim"

# 卸载 ISO
Dismount-DiskImage -ImagePath ".\Windows11.iso"
```

### Q2: 不同版本有什么区别?

- **家庭版 (1)**: 功能最少,体积最小
- **专业版 (4)**: 功能完整,推荐使用
- **工作站版 (6)**: 高性能硬件支持

### Q3: 可以同时构建多个版本吗?

目前一次只能构建一个版本。如需多个版本:

```powershell
# 方法1: 多次运行工作流,每次选择不同的 image_index

# 方法2: 本地脚本循环构建
foreach ($index in @(1, 4)) {
    .\scripts\Build-Tiny11.ps1 `
        -BuildType "tiny11" `
        -DriveLetter $drive `
        -ScriptPath ".\tiny11maker.ps1" `
        -ImageIndex $index
}
```

### Q4: 构建失败如何调试?

1. **检查权限**: 必须以管理员身份运行
   ```powershell
   .\scripts\Check-Prerequisites.ps1
   ```

2. **验证 ISO**: 确保 ISO 包含所选索引
   ```powershell
   Get-WindowsImage -ImagePath "path\to\install.wim"
   ```

3. **检查 PowerShell 版本**:
   ```powershell
   $PSVersionTable.PSVersion  # 应该是 7.0+
   ```

4. **查看详细日志**: GitHub Actions 中查看完整构建日志

## 文件更新清单

### 核心文件
- ✅ `.github/workflows/build-tiny11.yml` - 添加 image_index 输入参数
- ✅ `scripts/Build-Tiny11.ps1` - 添加 ImageIndex 参数和自动化输入

### 文档文件
- ✅ `image-index.md` - 新增镜像索引说明文档
- ✅ `README.md` - 更新使用说明
- ✅ `CONFIGURATION.md` - 更新配置说明
- ✅ `scripts/README.md` - 更新脚本参数说明
- ✅ `automation-guide.md` - 本文档

## 升级注意事项

### 从旧版本升级

如果你之前 fork 了这个项目:

1. **同步最新代码**:
   ```bash
   git fetch upstream
   git merge upstream/master
   ```

2. **测试新参数**:
   - 工作流会自动使用默认值 (ImageIndex=4)
   - 可以在 workflow_dispatch 中选择其他版本

3. **更新文档**: 建议同步所有文档更新

### 兼容性

- ✅ 向后兼容: 旧的工作流会使用默认值
- ✅ 默认行为不变: 仍然构建专业版 (索引4)
- ✅ 可选功能: ImageIndex 是可选参数

## 下一步计划

可能的未来改进:

- [ ] 支持批量构建多个版本
- [ ] 自动检测 ISO 中可用的版本
- [ ] 版本特定的优化选项
- [ ] 构建配置预设 (Gaming, Office, Developer, etc.)

## 相关资源

- [ntdevlabs/tiny11builder](https://github.com/ntdevlabs/tiny11builder) - 上游项目
- [image-index.md](image-index.md) - 镜像索引详细说明
- [CONFIGURATION.md](CONFIGURATION.md) - 完整配置指南
- [scripts/README.md](scripts/README.md) - 脚本使用说明
