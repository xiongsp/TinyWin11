# Tiny11 自动构建工具

这是一个基于 GitHub Actions 的自动化工具，用于构建 Tiny11 和 Tiny11 Core 精简版 Windows 11 镜像。

## 功能特性

- 🤖 全自动化构建流程
- 🔄 从 Microsoft 官方下载 Windows 11 ISO
- 🛠️ 使用 [ntdevlabs/tiny11builder](https://github.com/ntdevlabs/tiny11builder) 的官方脚本
- 📦 自动生成 Release 并上传 ISO 文件
- 🔐 提供 SHA256 校验和文件
- 🎯 支持构建 Tiny11 和 Tiny11 Core 两种版本

## 使用方法

### 1. Fork 本仓库

点击页面右上角的 "Fork" 按钮，将本仓库 fork 到你的账号下。

### 2. 启用 GitHub Actions

1. 进入你 fork 的仓库
2. 点击 "Actions" 标签页
3. 如果看到提示，点击 "I understand my workflows, go ahead and enable them"

### 3. 配置 ISO 下载链接

**重要步骤**：编辑 `iso-links.txt` 文件，添加 Windows 11 ISO 的下载链接

1. 打开仓库中的 `iso-links.txt` 文件
2. 取消注释或添加有效的 Windows 11 ISO 下载链接
3. 可以添加多个链接作为备份（工作流会依次尝试）
4. 提交更改

获取 ISO 下载链接的方法：
- 使用 [UUP dump](https://uupdump.net/) 生成 ISO 下载链接
- 使用 Rufus 工具获取 Microsoft 官方直接下载链接
- 从 Microsoft 下载页面获取（可能需要修改浏览器 User-Agent）

### 4. 运行构建工作流

1. 在 "Actions" 页面，选择左侧的 "Build Tiny11 ISO" 工作流
2. 点击右侧的 "Run workflow" 按钮
3. 选择构建选项：
   - **Windows version**: 选择要构建的 Windows 11 版本（默认：latest）
   - **Build type**: 选择构建类型
     - `both`: 同时构建 Tiny11 和 Tiny11 Core
     - `tiny11`: 仅构建 Tiny11
     - `tiny11core`: 仅构建 Tiny11 Core
4. 点击绿色的 "Run workflow" 按钮开始构建

### 5. 下载构建结果

1. 构建完成后，进入 "Releases" 页面
2. 找到最新的 Release
3. 下载生成的 ISO 文件和对应的 SHA256 校验文件
4. 验证下载的文件完整性（使用 SHA256 校验）

## 项目架构

### 目录结构
```
Tiny11/
├── .github/
│   └── workflows/
│       └── build-tiny11.yml    # GitHub Actions 工作流
├── scripts/                     # PowerShell 脚本（解耦后）
│   ├── Download-WindowsISO.ps1  # ISO 下载脚本
│   ├── Build-Tiny11.ps1         # 构建脚本
│   ├── Prepare-Release.ps1      # Release 准备脚本
│   ├── Generate-ReleaseNotes.ps1 # Release 说明生成
│   └── README.md                # 脚本文档
├── iso-links.txt                # ISO 下载链接配置
├── README.md                    # 主文档
├── CONFIGURATION.md             # 配置说明
└── CONTRIBUTING.md              # 贡献指南
```

### 设计原则
- **关注点分离**: 脚本逻辑与 YAML 工作流分离
- **可测试性**: 脚本可以在本地独立测试
- **可维护性**: 脚本使用参数化，易于修改和扩展
- **可重用性**: 脚本可在其他项目中重用

## 构建流程说明

工作流程包括以下步骤：

1. **检出仓库代码**
2. **下载 Windows 11 ISO** - 使用 `Download-WindowsISO.ps1` 从配置文件读取链接并下载
3. **下载 Tiny11 构建脚本** - 从官方仓库获取最新的制作脚本
4. **挂载 ISO 镜像** - 将下载的 ISO 挂载到虚拟驱动器
5. **构建 Tiny11** - 使用 `Build-Tiny11.ps1` 自动化执行 tiny11maker.ps1
6. **构建 Tiny11 Core** - 使用 `Build-Tiny11.ps1` 自动化执行 tiny11Coremaker.ps1（如果选择）
7. **卸载 ISO 镜像**
8. **准备 Release 资源** - 使用 `Prepare-Release.ps1` 生成 SHA256 校验和
9. **生成 Release 说明** - 使用 `Generate-ReleaseNotes.ps1` 创建发布文档
10. **创建 Release** - 自动创建 GitHub Release 并上传文件
11. **清理临时文件**

## 系统要求

### GitHub Actions Runner
- 操作系统：Windows (latest)
- 磁盘空间：至少 20GB 可用空间
- 运行时间：构建可能需要 30-60 分钟

### 使用生成的 ISO
- 至少 8GB USB 驱动器（用于创建启动盘）
- 支持 UEFI 的计算机
- 至少 16GB RAM（推荐）
- 至少 20GB 可用磁盘空间

## 注意事项

### ⚠️ 重要提示

1. **配置 ISO 下载链接**：首次使用前必须在 `iso-links.txt` 中配置有效的下载链接：
   - 使用 [UUP dump](https://uupdump.net/) 获取最新的 Windows 11 ISO 下载链接
   - 从 Microsoft 官方网站获取下载链接
   - 可以添加多个链接作为备份，工作流会自动尝试

2. **自动化构建**：工作流已配置为非交互式运行：
   - 自动从 `iso-links.txt` 读取下载链接
   - 自动尝试多个链接直到成功
   - 自动提供脚本所需的输入参数
   - 无需人工干预

3. **构建时间**：完整的构建过程可能需要 30-60 分钟，请耐心等待。

4. **存储配额**：GitHub 免费账户有存储限制，请注意 Release 的大小和数量。

5. **许可证合规**：确保你的使用符合 Microsoft Windows 的许可条款。

## 本地测试

所有脚本都可以在本地测试，无需 GitHub Actions：

```powershell
# 测试下载脚本
.\scripts\Download-WindowsISO.ps1 `
    -LinksFile "iso-links.txt" `
    -OutputPath "test\Windows11.iso"

# 测试构建脚本（需要先挂载 ISO）
$mount = Mount-DiskImage -ImagePath "Windows11.iso" -PassThru
$drive = ($mount | Get-Volume).DriveLetter
.\scripts\Build-Tiny11.ps1 `
    -BuildType "tiny11" `
    -DriveLetter $drive `
    -ScriptPath ".\tiny11maker.ps1"

# 测试 Release 准备
.\scripts\Prepare-Release.ps1 -ReleaseDir "release"

# 测试 Release Notes 生成
.\scripts\Generate-ReleaseNotes.ps1 -ReleaseDir "release"
```

详细的脚本使用说明请查看 [`scripts/README.md`](scripts/README.md)。

## 自定义配置

### 修改 ISO 下载源

编辑 `iso-links.txt` 文件，添加或修改下载链接：

```text
# 主链接
https://your-windows-11-iso-download-url

# 备用链接
https://backup-url
```

### 自定义构建输入

修改 `scripts/Build-Tiny11.ps1` 中的 `$answers` 数组以适应不同的脚本提示。

### 添加自定义步骤

在 `.github/workflows/build-tiny11.yml` 中添加新步骤，或创建新的 PowerShell 脚本：

```yaml
- name: Custom Step
  run: |
    .\scripts\Your-Custom-Script.ps1 -Param "value"
  shell: powershell
```

## 故障排除

### 构建失败

1. **磁盘空间不足**：GitHub Actions 的 runner 可能空间不足
   - 解决方案：在工作流中添加更多的清理步骤

2. **ISO 下载失败**：下载链接可能已过期
   - 解决方案：更新工作流中的 ISO 下载链接

3. **脚本执行失败**：脚本可能需要管理员权限或特定环境
   - 解决方案：检查脚本日志，调整执行策略

### 查看日志

1. 进入 "Actions" 页面
2. 点击失败的工作流运行
3. 展开各个步骤查看详细日志

## 贡献

欢迎提交 Issue 和 Pull Request！

## 致谢

- [ntdevlabs/tiny11builder](https://github.com/ntdevlabs/tiny11builder) - 提供核心构建脚本
- Microsoft - Windows 11 操作系统

## 免责声明

本项目仅供学习和研究使用。生成的 Tiny11 镜像是修改版的 Windows 11，使用时请遵守 Microsoft 的许可协议。作者不对使用本工具造成的任何问题负责。

## 许可证

本项目采用 MIT 许可证。但请注意，Windows 11 本身受 Microsoft 的许可条款约束。

---

**注意**：首次运行时可能需要一些调试和配置。如果遇到问题，请查看 Actions 日志或提交 Issue。
