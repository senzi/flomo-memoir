# Flomo Memoir

Flomo Memoir 是一个优雅的日记写作工具，专注于帮助用户记录每一天的想法和感悟。它与 Flomo 完美集成，让你的思考更有条理，记录更加便捷。现在提供跨平台的桌面应用，让写作体验更加流畅！

## ✨ 特点

- 🎯 **专注写作**：简洁的界面设计，让你专注于写作本身
- 🏷️ **智能标签**：支持标签管理，轻松整理和分类你的想法
- 🔄 **Flomo 集成**：无缝同步到你的 Flomo 账户
- 🎨 **优雅体验**：精心设计的动画和交互，带来流畅的使用体验
- 💻 **跨平台支持**：提供 macOS 和 Windows 桌面应用
- 🤖 **AI 审阅**：集成 AI 写作助手，为日记内容提供改进建议，帮助提升写作水平

## 🚀 快速开始

### 桌面应用

1. 访问 [Releases](https://github.com/yourusername/flomo-memoir/releases) 页面
2. 下载适合你操作系统的安装包：
   - macOS: `.dmg` 文件
   - Windows: `.msi` 文件
3. 安装并运行应用

### 开发者指南

1. **安装依赖**
   ```bash
   pnpm install
   ```

2. **启动开发服务器**
   ```bash
   # 网页开发模式
   pnpm dev

   # 桌面应用开发模式
   pnpm tauri dev
   ```

3. **构建**
   ```bash
   # 构建网页版本
   pnpm build

   # 构建桌面应用
   pnpm tauri build
   ```

## 📝 使用说明

1. **设置 API**
   - 点击右上角的 ⚙️ 图标
   - 访问 [Flomo API 设置页面](https://v.flomoapp.com/mine?source=incoming_webhook) 获取你的 API URL
   - 将 API URL 填入设置面板

2. **写日记**
   - 在主文本框中写下你的想法
   - 使用标签功能对内容进行分类（在标签输入框中输入并按回车添加）
   - 点击发布按钮保存内容
   - 使用 AI 审阅功能获取写作建议和改进意见

3. **管理标签**
   - 点击标签可以删除（需要二次确认）
   - 标签会自动与内容一起保存到 Flomo

## 🎯 开发计划

- [ ] **标签分析**：添加标签使用统计和分析功能
- [ ] **主题定制**：支持自定义主题和深色模式
- [ ] **快捷键支持**：添加常用操作的快捷键

## 🛠️ 技术栈

- Vue 3 + TypeScript
- Vite
- Tauri
- GitHub Actions（自动化发布）

## 📄 许可证

[MIT License](LICENSE)

## 🤝 贡献

欢迎提出建议和改进意见！请随时提交 Issue 或 Pull Request。
