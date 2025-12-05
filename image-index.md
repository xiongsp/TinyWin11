# Windows 11 镜像索引说明

构建 Tiny11 时需要选择 Windows 11 ISO 中的镜像版本。不同版本对应不同的索引编号。

## 镜像索引对应表

| 索引 | 版本名称 | 英文名称 | 说明 |
|------|---------|----------|------|
| 1 | 家庭版 | Home | 适合家庭用户的基础版本 |
| 2 | 家庭单语言版 | Home Single Language | 单语言版本,通常预装在OEM设备 |
| 3 | 教育版 | Education | 教育机构使用的版本 |
| 4 | 专业版 | Professional | **推荐** - 适合专业用户和小型企业 |
| 5 | 专业教育版 | Professional Education | 专业版的教育版本 |
| 6 | 专业工作站版 | Professional for Workstations | 高性能工作站版本 |

## 推荐选择

- **默认推荐**: 索引 4 (专业版) - 功能完整,兼容性最好
- **轻量需求**: 索引 1 (家庭版) - 功能较少,体积更小
- **企业/教育**: 索引 3 或 5 - 根据实际授权选择

## GitHub Actions 中使用

在触发工作流时,可以通过 `image_index` 参数选择要构建的版本:

```yaml
image_index: '4'  # 构建专业版
```

## 本地构建使用

本地运行构建脚本时,可以指定 `-ImageIndex` 参数:

```powershell
.\scripts\Build-Tiny11.ps1 `
    -BuildType "tiny11" `
    -DriveLetter "E" `
    -ScriptPath ".\tiny11maker.ps1" `
    -ImageIndex 4
```

如果不指定,默认值为 4 (专业版)。

## 查看 ISO 中可用的镜像

如果需要查看 ISO 文件中包含哪些版本,可以使用以下命令:

```powershell
# 挂载 ISO
$mount = Mount-DiskImage -ImagePath "path\to\Windows11.iso" -PassThru
$driveLetter = ($mount | Get-Volume).DriveLetter

# 查看 install.wim 中的镜像
Get-WindowsImage -ImagePath "${driveLetter}:\sources\install.wim"

# 或者查看 install.esd
Get-WindowsImage -ImagePath "${driveLetter}:\sources\install.esd"

# 卸载 ISO
Dismount-DiskImage -ImagePath "path\to\Windows11.iso"
```

## 注意事项

1. 不同的 Windows 11 ISO 可能包含不同数量的镜像
2. OEM 版本的 ISO 可能只包含特定版本
3. 批量授权版本可能包含企业版等额外版本
4. 确保选择的索引在您的 ISO 中存在
