import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_routes.dart'; // 假设你的路由配置正确

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bgController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // 整体动画时长
      vsync: this,
    );
    _bgController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    // 按钮和其他元素的入场缩放动画
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // 弹性效果
    );

    // 整体页面的淡入效果
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn), // 动画的前半部分
      ),
    );

    // 背景颜色动画 - 从透明到最终颜色
    _backgroundColorAnimation = ColorTween(
      begin: Colors.red[100],
      end: Colors.blue[100],
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _controller.forward(); // 页面加载时启动动画
    _bgController.repeat(reverse: true); // <--- 关键：设置 reverse: true
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    // 模拟登录操作
    setState(() {
      _isButtonPressed = true;
    });
    // 按钮按下反馈动画
    _controller.reverse().then((_) {
      _controller.forward(); // 让元素回到原位或执行其他动画
      setState(() {
        _isButtonPressed = false;
      });
      // 实际的路由跳转
      context.goNamed('square'); // 注意：这里需要添加square路由的name
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // 返回首页
        context.goNamed('home');
      },
      child: Scaffold(
        // 可爱的渐变背景
        body: AnimatedBuilder(
          animation: _backgroundColorAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _backgroundColorAnimation.value ?? Colors.blue[100]!,
                    Colors.blue[100]!,
                  ], // 动态变化的粉色到蓝色渐变
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    // 防止内容过多时溢出
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Icon(
                            Icons.sentiment_very_satisfied, // 可爱的笑脸图标
                            size: 100,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 40),

                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Text(
                            '欢迎回来!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),

                        // 登录按钮 - 带有点击缩放效果和圆角
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            transform: Matrix4.identity()
                              ..scale(_isButtonPressed ? 0.95 : 1.0), // 点击时缩小
                            transformAlignment: Alignment.center,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 15,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    30.0,
                                  ), // 非常圆润的边角
                                ),
                                elevation: 8.0,
                                // 增加阴影
                                shadowColor: Colors.pinkAccent.withOpacity(0.5),
                              ),
                              onPressed: _onLoginPressed,
                              child: const Text('登录鸭'), // 可爱的文本
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        FadeTransition(
                          opacity: _fadeAnimation, // 延迟显示
                          child: TextButton(
                            onPressed: () {
                              // TODO: 忘记密码逻辑
                            },
                            child: Text(
                              '遇到问题了?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
