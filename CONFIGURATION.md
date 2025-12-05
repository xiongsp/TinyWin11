# Tiny11 Builder Configuration

## ISO 下载配置

### 配置文件：`iso-links.txt`

工作流从 `iso-links.txt` 文件读取 ISO 下载链接。这是一个简单的文本文件，每行一个链接。

**文件格式：**
```text
# 这是注释行
https://example.com/Win11_23H2_x64.iso
https://backup.example.com/Win11_23H2_x64.iso

# 可以添加多个链接作为备份
```

**特性：**
- ✅ 支持多个下载链接（按顺序尝试）
- ✅ 支持注释行（以 `#` 开头）
- ✅ 自动跳过空行
- ✅ 自动重试机制
- ✅ 文件大小验证（至少 3GB）

### 获取 ISO 下载链接

#### 方法 1: 使用 UUP Dump（推荐）

1. 访问 [UUP dump](https://uupdump.net/)
2. 搜索 "Windows 11" 并选择你想要的版本
3. 选择语言（如 Chinese (Simplified) 或 English）
4. 点击 "Create download package"
5. 在生成的页面中，可以找到直接下载链接
6. 将链接复制到 `iso-links.txt`

#### 方法 2: Microsoft 官方下载

1. 访问 [Microsoft Windows 11 下载页面](https://www.microsoft.com/software-download/windows11)
2. 使用浏览器开发者工具：
   - 按 F12 打开开发者工具
   - 切换到 Network 标签
   - 修改 User-Agent 为非 Windows 系统（如 Mac）
   - 刷新页面获取直接下载链接
3. 或使用 Rufus 工具：
   - 下载并运行 [Rufus](https://rufus.ie/)
   - 点击 "选择" 按钮旁的下拉箭头
   - 选择 "下载"，Rufus 会提供官方下载链接

#### 方法 3: 使用 GitHub Release 托管

如果你已经有 Windows 11 ISO：

1. 创建一个私有/公有仓库的 Release
2. 上传 ISO 文件到 Release
3. 获取 Release 中 ISO 的直接下载链接
4. 将链接添加到 `iso-links.txt`

**注意**：GitHub 单个文件大小限制为 2GB，如果 ISO 超过此大小，需要使用其他托管方式。

## iso-links.txt 配置示例

### 基本配置
```text
# 主下载链接
https://software-static.download.prss.microsoft.com/Windows11_23H2_x64.iso
```

### 多链接备份配置
```text
# 主链接 - UUP Dump
https://uupdump.example.com/Win11_23H2_x64.iso

# 备用链接 1 - Microsoft 官方
https://software-static.download.prss.microsoft.com/Windows11.iso

# 备用链接 2 - 镜像站
https://mirror.example.com/windows11.iso
```

### 带注释的完整配置
```text
# ===========================================
# Windows 11 ISO 下载链接配置
# ===========================================
# 更新日期: 2025-12-05
# 版本: Windows 11 23H2

# 主下载源 - UUP Dump 生成
https://uupdump.example.com/Win11_23H2_Chinese_x64.iso

# 备用下载源 - Microsoft 官方
# https://software-static.download.prss.microsoft.com/Win11_23H2_x64.iso

# 说明：
# - 工作流会按顺序尝试每个链接
# - 取消注释（删除 #）来启用备用链接
# - 建议定期更新链接以获取最新版本
```

## 工作流变量配置

在 `.github/workflows/build-tiny11.yml` 中可配置的变量：

### 下载目录
```powershell
$downloadDir = "D:\downloads"  # GitHub Actions runner 的临时目录
```

### Tiny11 脚本链接
```powershell
$tiny11MakerUrl = "https://raw.githubusercontent.com/ntdevlabs/tiny11builder/main/tiny11maker.ps1"
$tiny11CoreMakerUrl = "https://raw.githubusercontent.com/ntdevlabs/tiny11builder/main/tiny11Coremaker.ps1"
```

### 文件大小验证阈值
```powershell
if ($fileSize -gt 3) {  # 至少 3GB
    # ISO 有效
}
```

## 自动化脚本配置

工作流已配置为自动化运行，无需交互式输入。

### 当前实现方式

工作流使用管道自动提供输入：

```powershell
# 准备自动输入的答案
$answers = @(
    $driveLetter,  # ISO 挂载的驱动器号
    "y",           # 确认继续
    ""             # 其他可能的输入
)

# 通过管道传递给脚本
$answers | .\tiny11maker.ps1
```

### 工作原理

1. **自动挂载 ISO**：工作流自动挂载下载的 ISO 并获取驱动器号
2. **传递参数**：将驱动器号作为第一个输入传递给脚本
3. **自动确认**：自动回答 "y" 确认所有提示
4. **非交互式运行**：整个过程无需人工干预

### 自定义脚本输入

如果原始脚本需要不同的输入，修改 `$answers` 数组：

```powershell
$answers = @(
    $driveLetter,           # 第一个输入：驱动器号
    "y",                    # 第二个输入：确认
    "1",                    # 第三个输入：选项 1
    "Pro",                  # 第四个输入：版本选择
    ""                      # 最后的空行
)
```

### 高级选项：修改脚本

如果需要更精细的控制，可以 fork tiny11builder 仓库：

1. Fork https://github.com/ntdevlabs/tiny11builder
2. 修改脚本添加命令行参数支持
3. 更新工作流中的脚本下载链接：

```yaml
- name: Download Tiny11 Builder Scripts
  run: |
    $tiny11MakerUrl = "https://raw.githubusercontent.com/你的用户名/tiny11builder/main/tiny11maker.ps1"
    Invoke-WebRequest -Uri $tiny11MakerUrl -OutFile "tiny11maker.ps1"
```

## GitHub Secrets 配置（可选）

如果需要访问私有资源，可以在仓库设置中添加 Secrets：

### 添加 Secret

1. 进入仓库的 Settings > Secrets and variables > Actions
2. 点击 "New repository secret"
3. 添加以下可能需要的 secrets：

- `WINDOWS_ISO_URL`: Windows 11 ISO 的私有下载链接
- `CUSTOM_TOKEN`: 如果需要访问私有资源的令牌

### 在工作流中使用

```yaml
- name: Download Windows 11 ISO
  env:
    ISO_URL: ${{ secrets.WINDOWS_ISO_URL }}
  run: |
    $isoUrl = $env:ISO_URL
    # ... 其余下载代码
```

## 磁盘空间优化

GitHub Actions 的 Windows runner 可能空间有限，可以添加额外的清理步骤：

```powershell
# 删除不需要的 Windows 功能
Disable-WindowsOptionalFeature -Online -FeatureName "Feature-Name" -NoRestart

# 清理 Windows Update 缓存
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force

# 清理 .NET 临时文件
Remove-Item -Path "C:\Windows\Microsoft.NET\Framework*\v*\Temporary ASP.NET Files\*" -Recurse -Force
```

## 构建超时配置

默认的 GitHub Actions 超时时间是 6 小时，如果需要调整：

```yaml
jobs:
  build-tiny11:
    runs-on: windows-latest
    timeout-minutes: 360  # 6 小时
```

## 并行构建

如果要同时构建多个版本，可以使用矩阵策略：

```yaml
jobs:
  build-tiny11:
    runs-on: windows-latest
    strategy:
      matrix:
        build_type: [tiny11, tiny11core]
    steps:
      # ... 构建步骤
```

## Release 配置

### 自动标签命名

当前使用 `build-${{ github.run_number }}` 作为标签，你可以自定义：

```yaml
tag_name: v1.0.${{ github.run_number }}
# 或
tag_name: tiny11-$(date +%Y%m%d)
```

### Draft Release

如果想先创建草稿版本再手动发布：

```yaml
- name: Create Release
  uses: softprops/action-gh-release@v1
  with:
    draft: true  # 设置为 true
    prerelease: false
```

### 测试建议

首次运行时建议：

1. **测试 ISO 下载**：先单独测试 ISO 下载步骤
2. **测试脚本执行**：在本地 Windows 环境测试脚本
   - ⚠️ **必须以管理员身份运行 PowerShell**
   - 右键点击 PowerShell → "以管理员身份运行"
3. **分步运行**：注释掉部分步骤，逐步测试
4. **使用小型测试 ISO**：先用较小的 ISO 测试流程

## 性能优化建议

1. **使用缓存**：缓存下载的 ISO（如果多次构建）
2. **并行步骤**：将独立的步骤并行执行
3. **使用更快的下载源**：选择地理位置近的镜像源
4. **压缩输出**：在上传前压缩 ISO 文件（如果需要）

---

如有问题，请参考 [GitHub Actions 文档](https://docs.github.com/actions) 或提交 Issue。
