import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go(AppRoutes.square);
              },
              child: Text(key: Key('RegisterButton'), 'Register'),
            ),
          ],
        ),
      ),
    );
  }
}
