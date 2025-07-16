import 'package:flutter/material.dart';

class CuteLoadingDialog extends StatefulWidget {
  final String? message;
  final bool showMessage;

  const CuteLoadingDialog({
    super.key,
    this.message,
    this.showMessage = true,
  });

  @override
  State<CuteLoadingDialog> createState() => _CuteLoadingDialogState();
}

class _CuteLoadingDialogState extends State<CuteLoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // 旋转动画控制器
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 旋转动画
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // 脉冲动画
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 启动动画
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[100]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 可爱的加载动画
              AnimatedBuilder(
                animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (widget.showMessage) ...[
                const SizedBox(height: 20),
                Text(
                  widget.message ?? '加载中...',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 便捷的显示方法
class CuteLoadingHelper {
  static void show({
    required BuildContext context,
    String? message,
    bool showMessage = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CuteLoadingDialog(
        message: message,
        showMessage: showMessage,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
