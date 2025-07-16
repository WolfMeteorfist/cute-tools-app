# 可爱工具集 🎨

一个使用 Flutter 开发的可爱主题工具应用，包含番茄计时器和 AI 聊天助手功能。

## ✨ 功能特色

- 🍅 **番茄计时器**: 25分钟专注计时，支持任务输入和可爱动画
- 🤖 **AI 聊天助手**: 集成 DeepSeek AI，支持智能对话
- 🎨 **可爱界面**: 粉色渐变主题，圆角设计，动画效果
- 📱 **跨平台**: 支持 Android、iOS、Windows、Web

## 🚀 快速开始

### 环境要求
- Flutter 3.8.1+
- Dart 3.8.1+
- Android Studio / VS Code

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/YOUR_USERNAME/wan_android.git
   cd wan_android
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **配置 API Key** (可选)
   - 复制 `lib/core/config.example.dart` 为 `lib/core/config.dart`
   - 在 `config.dart` 中填入你的 DeepSeek API Key

4. **运行应用**
   ```bash
   flutter run
   ```

## 📱 打包发布

### Android APK
```bash
flutter build apk --release
```

### Windows 应用
```bash
flutter build windows
```

### Web 版本
```bash
flutter build web
```

## 🛠️ 技术栈

- **框架**: Flutter 3.8.1
- **路由**: go_router
- **音频**: just_audio
- **网络**: http
- **AI 服务**: DeepSeek API

## 📁 项目结构

```
lib/
├── app/                    # 应用配置
│   └── router_config.dart  # 路由配置
├── core/                   # 核心功能
│   ├── config.dart         # 配置文件
│   └── app_routes.dart     # 路由常量
├── features/               # 功能模块
│   ├── auth/              # 认证模块
│   ├── tools/             # 工具模块
│   │   └── presentation/
│   │       └── page/
│   │           ├── tools_page.dart
│   │           ├── pomodoro_timer.dart
│   │           └── ai_talk_page.dart
│   └── ...
└── common_widgets/         # 公共组件
```

## 🎯 主要功能

### 番茄计时器
- 25分钟专注计时
- 任务输入和显示
- 可爱番茄图标动画
- 倒计时结束提醒
- 圆形进度条显示

### AI 聊天助手
- 集成 DeepSeek AI
- 智能对话功能
- 离线模式支持
- 可爱聊天界面
- 实时消息显示

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 🙏 致谢

- Flutter 团队
- DeepSeek AI 服务
- 所有开源贡献者
