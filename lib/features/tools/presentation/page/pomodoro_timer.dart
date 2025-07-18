import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wan_android/core/log_util.dart';
import 'package:wan_android/core/services/pomodoro_background_service.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage>
    with TickerProviderStateMixin {
  final TextEditingController _taskController = TextEditingController();
  int _seconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  bool _isRunning = false;
  bool _showTomato = true;
  bool _isShaking = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<TimerEvent>? _eventSubscription;

  late AnimationController _shakeController;
  late AnimationController _progressController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 16).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      }
    });
    
    // 初始化事件监听
    _initializeTimerListener();
    // 加载初始状态
    _loadInitialState();
  }

  void _initializeTimerListener() {
    _eventSubscription = PomodoroBackgroundService.eventStream.listen((event) {
      logger.d('Timer page received event: ${event.type}');
      
      setState(() {
        _isRunning = event.isRunning;
        _seconds = event.remainingSeconds;
        
        // 只在计时器运行时更新任务名称，避免覆盖用户输入
        if (event.isRunning) {
          _taskController.text = event.taskName;
        }
      });
      
      // 处理特定事件类型
      switch (event.type) {
        case TimerEventType.started:
          logger.d('Timer started');
          break;
        case TimerEventType.updated:
          // 检查是否时间到了
          if (event.remainingSeconds <= 0) {
            setState(() {
              _isShaking = true;
            });
            _shakeController.forward();
            _onTimerEnd();
          }
          break;
        case TimerEventType.completed:
          logger.d('Timer completed');
          setState(() {
            _isShaking = true;
          });
          _shakeController.forward();
          _onTimerEnd();
          break;
        case TimerEventType.stopped:
          logger.d('Timer stopped');
          break;
        case TimerEventType.paused:
          logger.d('Timer paused');
          break;
      }
    });
  }

  void _loadInitialState() {
    final state = PomodoroBackgroundService.getCurrentState();
    setState(() {
      _isRunning = state['isRunning'];
      _seconds = state['remainingSeconds'];
      // 只在计时器运行时才加载任务名称
      if (state['isRunning']) {
        _taskController.text = state['taskName'];
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _taskController.dispose();
    _shakeController.dispose();
    _progressController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() async {
    if (_isRunning) return;
    
    logger.d("_startTimer: ${_taskController.text}");
    
    // 设置后台服务状态
    PomodoroBackgroundService.setTimerState(_taskController.text);
    
    // 启动后台服务
    await PomodoroBackgroundService.startService();
    
    setState(() {
      _isRunning = true;
      _isShaking = false;
    });
  }

  void _pauseTimer() async {
    if (!_isRunning) return;
    
    logger.d("_pauseTimer");
    
    // 停止后台服务
    await PomodoroBackgroundService.stopService();
    
    setState(() {
      _isRunning = false;
    });
  }

  void _onTimerEnd() async {
    logger.d("_onTimerEnd");
    
    // 停止后台服务
    await PomodoroBackgroundService.stopService();
    
    try {
      await _audioPlayer.setAsset('assets/audio/alarm.wav');
      await _audioPlayer.play();
    } catch (e) {
      print('音频播放失败: $e');
    }
  }

  void _reset() async {
    logger.d("_reset");
    
    // 停止后台服务
    await PomodoroBackgroundService.stopService();
    
    setState(() {
      _seconds = _totalSeconds;
      _isRunning = false;
      _isShaking = false;
      _taskController.clear(); // 清空任务内容
    });
  }

  String get _timeString {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    return (_totalSeconds - _seconds) / _totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🍅 番茄时间'),
          backgroundColor: Colors.pink[100],
          foregroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
                  // 任务输入框
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: TextField(
                      controller: _taskController,
                      enabled: !_isRunning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: '你要专注做什么呢？ 🎯',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.task_alt,
                          color: Colors.pink,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // 番茄计时器区域
                  if (_showTomato)
                    AnimatedBuilder(
                      animation: Listenable.merge([_shakeController, _progressController]),
                      builder: (context, child) {
                        double offset = _isShaking ? _shakeAnimation.value : 0;
                        return Transform.translate(
                          offset: Offset(offset * (_shakeController.status == AnimationStatus.reverse ? -1 : 1), 0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showTomato = false;
                              });
                            },
                            child: Container(
                              width: 200,
                              height: 200,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 可爱的圆形进度条
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: CustomPaint(
                                      painter: CuteProgressPainter(
                                        progress: _progress,
                                        isRunning: _isRunning,
                                      ),
                                    ),
                                  ),
                                  // 番茄图标
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/tomato.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // 时间文本
                                  Positioned(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        _timeString,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink,
                                          fontFamily: 'Comic Sans MS',
                                          letterSpacing: 2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // 隐藏番茄时的显示按钮
                  if (!_showTomato)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 40),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showTomato = true;
                          });
                        },
                        icon: const Icon(Icons.visibility, size: 24),
                        label: const Text(
                          '显示番茄 🍅',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[300],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // 控制按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isRunning ? _pauseTimer : _startTimer,
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 24),
                        label: Text(
                          _isRunning ? '暂停' : '开始',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRunning ? Colors.grey[400] : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh, size: 24),
                        label: const Text(
                          '重置',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 提示文本
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '💡 点击番茄可以隐藏/显示',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // 当前任务显示
                  if (_taskController.text.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.pink[200]!, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.task, color: Colors.pink, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '当前任务：${_taskController.text}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 可爱的进度条绘制器
class CuteProgressPainter extends CustomPainter {
  final double progress;
  final bool isRunning;

  CuteProgressPainter({required this.progress, required this.isRunning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 背景圆环
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // 进度圆环
    final progressPaint = Paint()
      ..shader = RadialGradient(
        colors: isRunning 
          ? [Colors.green, Colors.lightGreen, Colors.green.shade300]
          : [Colors.orange, Colors.deepOrange, Colors.orange.shade300],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // 绘制进度弧线
    final rect = Rect.fromCircle(center: center, radius: radius - 6);
    canvas.drawArc(
      rect,
      -90 * (3.14159 / 180), // 从12点钟方向开始
      progress * 2 * 3.14159, // 根据进度绘制弧线
      false,
      progressPaint,
    );

    // 添加可爱的装饰点
    if (isRunning) {
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final dotRadius = 3.0;
      final dotCount = 8;
      for (int i = 0; i < dotCount; i++) {
        final angle = (i / dotCount) * 2 * 3.14159;
        final dotX = center.dx + (radius - 20) * cos(angle);
        final dotY = center.dy + (radius - 20) * sin(angle);
        
        if (i / dotCount <= progress) {
          canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 