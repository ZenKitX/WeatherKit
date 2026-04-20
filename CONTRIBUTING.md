# WeatherKit 贡献指南

感谢您对 WeatherKit 的关注！本文档将指导您如何为项目做出贡献。

## 目录

1. [行为准则](#行为准则)
2. [如何贡献](#如何贡献)
3. [开发环境设置](#开发环境设置)
4. [提交规范](#提交规范)
5. [代码审查](#代码审查)
6. [发布流程](#发布流程)

## 行为准则

### 我们的承诺

为了营造一个开放和友好的环境，我们承诺：

- 使用友好和包容的语言
- 尊重不同的观点和经验
- 优雅地接受建设性批评
- 关注对社区最有利的事情
- 对其他社区成员表示同理心

### 我们的标准

**积极行为示例:**
- 使用友好和包容的语言
- 尊重不同的观点和经验
- 优雅地接受建设性批评
- 关注对社区最有利的事情

**不可接受的行为示例:**
- 使用性化的语言或图像
- 侮辱性/贬损性评论和人身攻击
- 公开或私下骚扰
- 未经许可发布他人的私人信息

## 如何贡献

### 报告 Bug

在提交 Bug 报告之前：

1. 检查[现有 Issues](https://github.com/ZenKitX/WeatherKit/issues) 确保问题未被报告
2. 确保您使用的是最新版本
3. 收集相关信息（版本号、错误信息、复现步骤）

**Bug 报告应包含:**

- 清晰的标题和描述
- 复现步骤
- 预期行为
- 实际行为
- 环境信息（Dart/Flutter 版本、操作系统）
- 相关代码示例或截图

## 开发环境设置

### 克隆仓库

```bash
git clone https://github.com/ZenKitX/WeatherKit.git
cd WeatherKit
```

### 安装依赖

```bash
flutter pub get
```

### 运行测试

```bash
flutter test
```

### 运行代码分析

```bash
flutter analyze
```

## 提交规范

### 提交信息格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型:**
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例:**

```
feat(service): add support for 7-day forecast

Implement the dailyForecast parameter in getWeatherByCity
method to return 7-day weather forecast data.

Closes #123
```

## 发布流程

### 版本号遵循语义化版本

- MAJOR.MINOR.PATCH
- 不兼容的 API 修改 → MAJOR
- 向后兼容的功能性新增 → MINOR
- 向后兼容的问题修复 → PATCH

### 发布步骤

1. 更新 `pubspec.yaml` 中的版本号
2. 更新 `CHANGELOG.md`
3. 创建 git tag
4. 推送到 GitHub
5. （可选）发布到 pub.dev

```bash
# 更新版本号
# 编辑 pubspec.yaml

# 提交变更
git add .
git commit -m "chore: bump version to 0.2.0"

# 创建 tag
git tag v0.2.0
git push origin main --tags
```
