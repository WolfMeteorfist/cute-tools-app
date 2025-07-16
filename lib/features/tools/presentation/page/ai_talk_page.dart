import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wan_android/core/config.dart';

class AITalkPage extends StatefulWidget {
  const AITalkPage({super.key});

  @override
  State<AITalkPage> createState() => _AITalkPageState();
}

class _AITalkPageState extends State<AITalkPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 添加欢迎消息
    _messages.add(ChatMessage(
      text: "你好！我是你的AI助手 🧠\n我可以帮你回答问题、写代码、聊天等等～\n有什么想和我聊的吗？",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // 添加用户消息
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // 调用 DeepSeek API
      final response = await _callDeepSeekAPI(userMessage);
      
      // 检查是否是余额不足错误
      if (response.contains('账户余额不足')) {
        // 切换到离线模式
        final offlineResponse = _getOfflineResponse(userMessage);
        setState(() {
          _messages.add(ChatMessage(
            text: response + '\n\n' + offlineResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "抱歉，我遇到了一些问题 😅\n请稍后再试，或者检查网络连接。",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<String> _callDeepSeekAPI(String message) async {
    // 使用配置文件中的 API Key
    final apiKey = AppConfig.deepSeekApiKey;
    
    // 如果还没有配置 API Key，显示配置提示
    if (!AppConfig.isDeepSeekConfigured) {
      return '''🔧 需要配置 API Key

请按以下步骤配置：

1. 访问 https://platform.deepseek.com/
2. 注册账号并登录
3. 在控制台获取 API Key
4. 打开 lib/core/config.dart 文件
5. 将 'YOUR_DEEPSEEK_API_KEY' 替换为你的真实 API Key

每天有 100 次免费请求额度！

示例：
static const String deepSeekApiKey = 'sk-your-actual-api-key-here';''';
    }
    
    const url = 'https://api.deepseek.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': '你是一个可爱的AI助手，请用友好、有趣的方式回答用户的问题。',
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 401) {
        return '❌ API Key 无效，请检查你的 API Key 是否正确配置。';
      } else if (response.statusCode == 402) {
        return '''💰 账户余额不足

你的 DeepSeek 账户余额不足，需要充值才能继续使用。

解决方法：
1. 登录 https://platform.deepseek.com/
2. 进入控制台查看余额
3. 前往充值页面进行充值

或者，我可以为你提供一些预设的回复来演示功能！😊''';
      } else if (response.statusCode == 429) {
        return '⚠️ 今日免费额度已用完，请明天再试或升级到付费版本。';
      } else {
        return '❌ 请求失败，错误代码: ${response.statusCode}\n请稍后再试。';
      }
    } catch (e) {
      return '❌ 网络连接失败，请检查网络连接后重试。\n错误信息: $e';
    }
  }

  /// 离线模式 - 提供预设回复
  String _getOfflineResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('你好') || lowerMessage.contains('hello')) {
      return '你好！我是你的离线AI助手 🧠\n虽然现在无法连接真实的AI服务，但我还是可以和你聊天哦！';
    } else if (lowerMessage.contains('笑话') || lowerMessage.contains('funny')) {
      return '😄 为什么程序员总是分不清万圣节和圣诞节？\n因为 Oct 31 = Dec 25！\n（八进制的31等于十进制的25）';
    } else if (lowerMessage.contains('天气')) {
      return '🌤️ 抱歉，我无法获取实时天气信息。\n建议你查看手机天气应用或访问天气网站哦！';
    } else if (lowerMessage.contains('时间')) {
      return '⏰ 现在是 ${DateTime.now().toString().substring(0, 19)}';
    } else if (lowerMessage.contains('帮助') || lowerMessage.contains('help')) {
      return '''🤖 我是离线AI助手，可以帮你：

• 聊天解闷 😊
• 讲笑话 😄
• 显示时间 ⏰
• 简单问答 💭

要连接真实AI服务，请充值你的DeepSeek账户！''';
    } else {
      return '🤔 这个问题很有趣！不过我现在是离线模式，无法提供详细的AI回答。\n\n你可以试试问我：\n• 你好\n• 讲个笑话\n• 现在时间\n• 帮助';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI 聊天助手'),
        backgroundColor: Colors.purple[100],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[100]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // 聊天消息列表
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingMessage();
                  }
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            
            // 输入区域
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isLoading,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: _isLoading ? 'AI正在思考中...' : '输入你的问题...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        suffixIcon: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.purple,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: _isLoading ? Colors.grey[400] : Colors.purple,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: Icon(
                        _isLoading ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple[300],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.purple[100] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.pink[300],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple[300],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI正在思考中...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
} 