import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wan_android/core/app_routes.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工具鸭 🛠️'),
        backgroundColor: Colors.pink[100],
        foregroundColor: Colors.white,
        elevation: 0,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
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
                    Icons.build,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  '可爱工具集',
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
                const SizedBox(height: 20),
                Text(
                  '选择你需要的可爱工具吧～',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                ElevatedButton.icon(
                  icon: const Icon(Icons.timer, size: 28),
                  label: const Text('番茄时间', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.pinkAccent.withOpacity(0.5),
                  ),
                  onPressed: () {
                    context.go(AppRoutes.pomodoro);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 