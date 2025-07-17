import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // 返回首页
        context.goNamed('home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('注册鸭'),
          backgroundColor: Colors.pink[100],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.goNamed('home');
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.goNamed('square'); // 注意：这里需要添加square路由的name
                },
                child: Text(key: Key('RegisterButton'), 'Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
