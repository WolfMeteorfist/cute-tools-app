import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wan_android/core/app_routes.dart';
import 'cute_dialog.dart';

// 将 ErrorPage 改为 StatefulWidget
class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  bool _isNavigating = false; // 添加一个标志位，防止重复导航
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 延迟显示弹窗，确保页面完全加载
    if (!_isDialogShown) {
      _isDialogShown = true;
      //这个非常关键，确保页面完全加载后再显示弹窗！！！！
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog();
      });
    }
  }

  void _showErrorDialog() {
    CuteDialogHelper.show(
      context: context,
      title: '哎呀！出错了鸭 🦆',
      content: '这个页面还在开发中呢，请稍后再来看看吧～',
      leftButtonText: '返回首页',
      rightButtonText: '再试一次',
      onLeftButtonPressed: () {
        Navigator.of(context).pop(); // 关闭弹窗
        context.goNamed('home');
      },
      onRightButtonPressed: () {
        Navigator.of(context).pop(); // 关闭弹窗
        // 可以在这里添加重试逻辑
        _showErrorDialog(); // 重新显示弹窗
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.pink[100],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[100]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 100,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 20),
              Text(
                '页面出错了',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '别担心，我们正在努力修复中～',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // 如果正在导航中，则直接返回，不执行任何操作
                  if (_isNavigating) {
                    return;
                  }

                  // 设置标志位为 true，表示导航开始
                  setState(() {
                    _isNavigating = true;
                  });

                  context.goNamed('home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
