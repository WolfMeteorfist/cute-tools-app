import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wan_android/core/log_util.dart';
import 'package:wan_android/core/services/pomodoro_background_service.dart';

class PomodoroFloatingWidget extends StatefulWidget {
  const PomodoroFloatingWidget({super.key});

  @override
  State<PomodoroFloatingWidget> createState() => _PomodoroFloatingWidgetState();
}

class _PomodoroFloatingWidgetState extends State<PomodoroFloatingWidget>
    with TickerProviderStateMixin {
  Offset _position = const Offset(100, 200);
  bool _isDragging = false;
  bool _isVisible = false;
  int _remainingSeconds = 0;
  String _taskName = '';
  bool _isRunning = false;
  Timer? _updateTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkTimerState();
    _startUpdateTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkTimerState();
    });
  }

  void _checkTimerState() {
    final state = PomodoroBackgroundService.getCurrentState();

    if (state['isRunning'] && state['remainingSeconds'] > 0) {
      setState(() {
        _isVisible = true;
        _remainingSeconds = state['remainingSeconds'];
        _taskName = state['taskName'];
        _isRunning = true;
      });

      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      setState(() {
        _isVisible = false;
        _isRunning = false;
      });
      _pulseController.stop();
    }
  }

  String get _timeString {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    return (25 * 60 - _remainingSeconds) / (25 * 60);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          logger.d('Floating widget pan start');
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onPanEnd: (details) {
          logger.d('Floating widget pan end');
          setState(() {
            _isDragging = false;
          });
        },
        onTapDown: (details) {
          logger.d('Floating widget tap down');
        },
        onTapUp: (details) {
          logger.d('Floating widget tap up');
        },
        onTap: () {
          logger.d('Floating widget tapped!');
          _openPomodoroPage();
        },
        onTapCancel: () {
          logger.d('Floating widget tap cancelled');
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isRunning ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.pink[100]!.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 进度圆环
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: FloatingProgressPainter(
                          progress: _progress,
                          isRunning: _isRunning,
                        ),
                      ),
                    ),
                    // 番茄图标
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        'assets/tomato.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // 时间文本
                    Positioned(
                      bottom: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _timeString,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openPomodoroPage() {
    logger.d('Opening pomodoro page from floating widget');
  }
}

// 悬浮窗进度条绘制器
class FloatingProgressPainter extends CustomPainter {
  final double progress;
  final bool isRunning;

  FloatingProgressPainter({required this.progress, required this.isRunning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 背景圆环
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 2, backgroundPaint);

    // 进度圆环
    final progressPaint = Paint()
      ..shader = RadialGradient(
        colors: isRunning
            ? [Colors.green, Colors.lightGreen]
            : [Colors.orange, Colors.deepOrange],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // 绘制进度弧线
    final rect = Rect.fromCircle(center: center, radius: radius - 2);
    canvas.drawArc(
      rect,
      -90 * (3.14159 / 180), // 从12点钟方向开始
      progress * 2 * 3.14159, // 根据进度绘制弧线
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
