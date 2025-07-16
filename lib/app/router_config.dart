import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wan_android/common_widgets/error_page.dart';
import 'package:wan_android/core/app_routes.dart';
import 'package:wan_android/features/article/router.dart';
import 'package:wan_android/features/auth/router.dart';

import '../core/log_util.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.go(AppRoutes.login);
                    },
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go(AppRoutes.register);
                    },
                    child: const Text('Register'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go("/non-existent-route");
                    },
                    child: const Text('Square'),
                  ),
                ]
            )
        )
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