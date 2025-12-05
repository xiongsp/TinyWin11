# Changelog

## [v2.0.0] - 2025-12-05

### 🎉 新增功能

#### 自动化镜像索引选择
- **GitHub Actions 工作流**: 新增 `image_index` 输入参数,支持选择 6 种 Windows 11 版本
- **Build-Tiny11.ps1**: 新增 `-ImageIndex` 参数,默认值为 4 (专业版)
- **完全自动化**: 无需手动交互,自动处理所有构建提示

#### 镜像版本支持
- 1: Windows 11 家庭版
- 2: Windows 11 家庭单语言版
- 3: Windows 11 教育版
- **4: Windows 11 专业版 (推荐,默认)**
- 5: Windows 11 专业教育版
- 6: Windows 11 专业工作站版

### 📝 文档更新

#### 新增文档
- **image-index.md**: Windows 11 镜像索引详细说明
  - 完整的版本对照表
  - 使用建议和场景说明
  - 查看 ISO 镜像信息的方法

- **automation-guide.md**: 自动化构建完整指南
  - 自动化输入流程说明
  - GitHub Actions 和本地构建示例
  - 常见问题解答
  - 技术实现细节

#### 更新文档
- **README.md**: 
  - 更新工作流运行说明,添加 image_index 参数说明
  - 添加镜像索引快速参考
  
- **CONFIGURATION.md**:
  - 更新自动化脚本配置章节
  - 添加镜像索引配置对照表
  - 更新自动化输入流程说明

- **scripts/README.md**:
  - 更新 Build-Tiny11.ps1 参数说明
  - 添加 ImageIndex 参数文档
  - 更新功能列表

- **CHANGELOG.md**: 本文档

### 🔧 技术改进

#### Build-Tiny11.ps1 脚本增强
```powershell
# 新增参数
[Parameter(Mandatory=$false)]
[int]$ImageIndex = 4

# 自动化输入更新
$answers = @(
    "yes",              # 执行策略确认
    $DriveLetter,       # 驱动器字母
    $ImageIndex,        # 镜像索引 (新增)
    ""                  # 最终确认
)
```

#### GitHub Actions 工作流增强
```yaml
# 新增输入参数
image_index:
  description: 'Windows image index (1-6)'
  required: true
  default: '4'
  type: choice
  options: ['1', '2', '3', '4', '5', '6']

# 构建步骤更新
-ImageIndex ${{ github.event.inputs.image_index }}
```

### 🎯 使用改进

#### Before (v1.x)
```powershell
# 手动输入驱动器字母
# 手动选择镜像索引
# 手动确认所有提示
```

#### After (v2.0)
```powershell
# GitHub Actions: 在 UI 中选择 image_index
# 本地构建:
.\scripts\Build-Tiny11.ps1 `
    -BuildType "tiny11" `
    -DriveLetter "E" `
    -ScriptPath ".\tiny11maker.ps1" `
    -ImageIndex 4
```

### 📊 统计信息

- 新增文件: 2 (image-index.md, automation-guide.md)
- 更新文件: 4 (README.md, CONFIGURATION.md, scripts/README.md, build-tiny11.yml)
- 代码变更: Build-Tiny11.ps1 (+9 行)
- 文档新增: ~1000 行

### 🔄 向后兼容性

- ✅ **完全兼容**: 所有现有功能保持不变
- ✅ **默认行为**: 不指定 ImageIndex 时默认使用 4 (专业版)
- ✅ **可选升级**: 用户可以选择是否使用新参数

### 🐛 问题修复

- 解决了 tiny11maker.ps1 交互式提示导致 CI/CD 阻塞的问题
- 自动处理镜像索引选择,消除手动输入需求
- 改进错误处理和日志输出

---

## [v1.0.0] - 2025-12-04

### 🎉 初始发布

#### 核心功能
- GitHub Actions CI/CD 工作流
- 自动下载 Windows 11 ISO
- 自动构建 Tiny11 和 Tiny11 Core
- 自动发布到 GitHub Releases

#### 脚本模块
- **Download-WindowsISO.ps1**: ISO 下载和验证
- **Build-Tiny11.ps1**: 自动化构建包装器
- **Prepare-Release.ps1**: Release 资源准备
- **Generate-ReleaseNotes.ps1**: Release 说明生成
- **Check-Prerequisites.ps1**: 环境前置检查
- **Test-Scripts.ps1**: 脚本语法验证

#### PowerShell 版本支持
- PowerShell 5.1 (Windows PowerShell) 用于辅助脚本
- PowerShell 7+ (pwsh) 用于构建脚本
- 自动检测和切换

#### 文档系统
- README.md - 主文档
- CONFIGURATION.md - 配置指南
- CONTRIBUTING.md - 贡献指南
- POWERSHELL-VERSION.md - PowerShell 版本说明
- scripts/README.md - 脚本文档
- scripts/COMPATIBILITY.md - 兼容性说明
- LICENSE - MIT 许可证

#### 自动化特性
- 非交互式 ISO 下载 (iso-links.txt)
- 多 URL 重试机制
- 自动 ISO 挂载和卸载
- SHA256 校验和生成
- 自动化 Release 创建

### 🔧 技术实现
- 脚本与 YAML 解耦设计
- 错误处理和日志记录
- 管理员权限检查
- 磁盘空间验证 (20GB+)
- 文件大小验证 (3GB+)

---

## 版本说明

### 语义化版本控制
- **Major (X.0.0)**: 重大功能变更,可能不兼容
- **Minor (x.Y.0)**: 新功能添加,向后兼容
- **Patch (x.y.Z)**: Bug 修复,向后兼容

### 发布周期
- 定期跟进 ntdevlabs/tiny11builder 上游更新
- 根据用户反馈添加新功能
- 持续改进文档和自动化

### 贡献
欢迎提交 Issue 和 Pull Request!
详见 [CONTRIBUTING.md](CONTRIBUTING.md)
