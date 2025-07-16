/// 应用配置文件
/// 在这里配置各种 API 密钥和设置
class AppConfig {
  /// DeepSeek API 配置
  static const String deepSeekApiKey = 'sk-5c64584639804d1ca39485684a3518e0';
  
  /// 其他配置项可以在这里添加
  static const String appName = '可爱工具集';
  static const String appVersion = '1.0.0';
  
  /// 检查是否已配置 API Key
  static bool get isDeepSeekConfigured => 
      deepSeekApiKey != 'YOUR_DEEPSEEK_API_KEY' && 
      deepSeekApiKey.isNotEmpty;
} 