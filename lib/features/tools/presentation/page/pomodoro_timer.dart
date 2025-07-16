import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _taskController = TextEditingController();
  int _seconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  bool _showTomato = true;
  bool _isShaking = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 16).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    _shakeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _isShaking = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer?.cancel();
        _onTimerEnd();
      }
    });
  }

  void _onTimerEnd() async {
    setState(() {
      _isShaking = true;
    });
    _shakeController.forward();
    try {
      await _audioPlayer.setAsset('assets/audio/alarm.wav');
      await _audioPlayer.play();
    } catch (e) {
      // 如果音频播放失败，至少显示摇晃动画
      print('音频播放失败: $e');
    }
  }

  void _reset() {
    setState(() {
      _timer?.cancel();
      _seconds = _totalSeconds;
      _isRunning = false;
      _isShaking = false;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍅 番茄时间'),
        backgroundColor: Colors.pink[100],
        foregroundColor: Colors.white,
        centerTitle: true,
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
                    animation: _shakeController,
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
                                // 圆形进度条
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: CircularProgressIndicator(
                                    value: _progress,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isRunning ? Colors.green : Colors.orange,
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
                      onPressed: _isRunning ? null : _startTimer,
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
    );
  }
} 