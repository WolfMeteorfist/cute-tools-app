import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wan_android/common_widgets/error_page.dart';
import 'package:wan_android/core/app_routes.dart';
import 'package:wan_android/features/article/router.dart';
import 'package:wan_android/features/auth/router.dart';

import '../core/log_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _backgroundColorAnimation = ColorTween(
      begin: Colors.pink[100],
      end: Colors.blue[100],
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('欢迎鸭 🦆'),
        backgroundColor: Colors.pink[100],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _backgroundColorAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _backgroundColorAnimation.value ?? Colors.pink[100]!,
                  Colors.blue[100]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 可爱的欢迎图标
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 欢迎标题
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          '欢迎来到可爱世界！',
                          style: TextStyle(
                            fontSize: 28,
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
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 副标题
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          '选择你想要的可爱功能吧～',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 60),

                      // 按钮区域
                      _buildCuteButton(
                        icon: Icons.login,
                        text: '登录鸭',
                        onPressed: () => context.go(AppRoutes.login),
                        delay: 0.2,
                      ),
                      const SizedBox(height: 20),

                      _buildCuteButton(
                        icon: Icons.person_add,
                        text: '注册鸭',
                        onPressed: () => context.go(AppRoutes.register),
                        delay: 0.4,
                      ),
                      const SizedBox(height: 20),

                      _buildCuteButton(
                        icon: Icons.square,
                        text: '广场鸭',
                        onPressed: () => context.go('/non-existent-route'),
                        delay: 0.6,
                        isError: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCuteButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    required double delay,
    bool isError = false,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: (800 + delay * 400).round()),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isError ? Colors.orange[300] : Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: isError ? Colors.orange.withOpacity(0.5) : Colors.pinkAccent.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 24),
                    const SizedBox(width: 12),
                    Text(text),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppRouterConfig {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    errorBuilder: (context, state) => const ErrorPage(),
    observers: [
      HeroController(),
      RouteObserver()
    ],
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      ...articleRoutes,
      ...authRoutes
    ]
  );
}
