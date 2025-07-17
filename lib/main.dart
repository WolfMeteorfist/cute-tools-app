import 'package:flutter/material.dart';
import 'package:wan_android/app/router_config.dart';
import 'package:wan_android/core/services/pomodoro_background_service.dart';
import 'package:wan_android/core/widgets/pomodoro_floating_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化后台服务
  await PomodoroBackgroundService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouterConfig.router,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // 添加悬浮窗
            const PomodoroFloatingWidget(),
          ],
        );
      },
    );
  }
}