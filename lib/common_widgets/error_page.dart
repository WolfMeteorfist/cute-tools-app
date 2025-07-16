import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wan_android/core/app_routes.dart';

// 将 ErrorPage 改为 StatefulWidget
class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  bool _isNavigating = false; // 添加一个标志位，防止重复导航

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 如果正在导航中，则直接返回，不执行任何操作
                if (_isNavigating) {
                  print("Navigation already in progress, ignoring tap."); // 可以加个日志观察
                  return;
                }

                // 设置标志位为 true，表示导航开始
                setState(() {
                  _isNavigating = true;
                });

                context.go(AppRoutes.home);
                // 对于 pop 操作，页面通常会被销毁，这个 State 对象也会被 dispose。
                // 因此，_isNavigating 状态会被自然重置。
                // 如果是 push 操作或者 pop 后页面依然存在且按钮可再次点击，
                // 你可能需要在导航动画完成后或者通过 Future.delayed 来重置 _isNavigating = false。
                // 但对于简单的 pop，通常这样就够了。
              },
              child: const Text('Back'),
            )
          ],
        ),
      ),
    );
  }
}