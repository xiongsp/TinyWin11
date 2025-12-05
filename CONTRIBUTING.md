# 贡献指南

感谢你考虑为 Tiny11 自动构建工具做出贡献！

## 如何贡献

### 报告问题

如果你发现了 bug 或有功能建议：

1. 检查 [Issues](../../issues) 页面，确保问题尚未报告
2. 创建新的 Issue，提供详细信息：
   - 问题描述
   - 重现步骤
   - 预期行为
   - 实际行为
   - 工作流日志（如果适用）
   - 屏幕截图（如果有帮助）

### 提交代码

1. **Fork 仓库**
   ```bash
   # 克隆你的 fork
   git clone https://github.com/你的用户名/Tiny11.git
   cd Tiny11
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/你的功能名称
   # 或
   git checkout -b fix/你的修复名称
   ```

3. **进行更改**
   - 编写清晰、简洁的代码
   - 遵循现有的代码风格
   - 添加或更新文档（如果需要）

4. **测试更改**
   - 在本地测试工作流（如果可能）
   - 确保所有步骤正常工作

5. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加某某功能"
   # 或
   git commit -m "fix: 修复某某问题"
   ```

6. **推送到 GitHub**
   ```bash
   git push origin feature/你的功能名称
   ```

7. **创建 Pull Request**
   - 访问原仓库
   - 点击 "New Pull Request"
   - 选择你的分支
   - 填写 PR 描述，说明你的更改

## 提交信息规范

使用语义化的提交信息：

- `feat:` 新功能
- `fix:` 错误修复
- `docs:` 文档更新
- `style:` 代码格式调整（不影响功能）
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建过程或辅助工具的变动

示例：
```
feat: 添加对 Windows 11 24H2 的支持
fix: 修复磁盘空间不足的问题
docs: 更新 README 中的使用说明
```

## 代码风格

### PowerShell 脚本
- 使用 4 个空格缩进
- 变量使用 PascalCase：`$MyVariable`
- 函数使用 Verb-Noun 命名：`Get-IsoPath`
- 添加注释说明复杂逻辑

### YAML 文件
- 使用 2 个空格缩进
- 保持一致的键顺序
- 为复杂步骤添加注释

## 测试指南

### 本地测试

1. **测试 PowerShell 脚本**
   ```powershell
   # 在 Windows PowerShell 中运行
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   .\your-script.ps1
   ```

2. **验证 YAML 语法**
   - 使用 [YAML Lint](http://www.yamllint.com/) 验证语法
   - 使用 VS Code 的 YAML 扩展检查格式

3. **测试工作流**
   - 在你的 fork 中运行工作流
   - 检查所有步骤是否正常执行

## 文档更新

如果你的更改影响了使用方式，请更新相应文档：

- `README.md` - 主要使用文档
- `CONFIGURATION.md` - 配置说明
- `CONTRIBUTING.md` - 本文件

## Pull Request 检查清单

在提交 PR 之前，请确保：

- [ ] 代码通过了所有测试
- [ ] 添加或更新了相关文档
- [ ] 提交信息清晰明确
- [ ] 没有引入不必要的依赖
- [ ] 工作流在 GitHub Actions 中测试通过
- [ ] 代码遵循项目的风格规范

## 需要帮助？

如果你在贡献过程中遇到问题：

1. 查看 [README.md](README.md) 和 [CONFIGURATION.md](CONFIGURATION.md)
2. 搜索现有的 [Issues](../../issues)
3. 创建新的 Issue 询问问题
4. 在 Pull Request 中提问

## 行为准则

- 尊重所有贡献者
- 接受建设性的批评
- 专注于对项目最有利的事情
- 表现出对社区其他成员的同理心

## 许可证

通过贡献代码，你同意你的贡献将在 MIT 许可证下发布。

---

再次感谢你的贡献！🎉
