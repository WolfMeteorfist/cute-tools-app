import 'dart:async';
import 'dart:io';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:wan_android/core/log_util.dart';

// 计时器事件类型
enum TimerEventType {
  started,
  updated,
  paused,
  completed,
  stopped,
}

// 计时器事件
class TimerEvent {
  final TimerEventType type;
  final int remainingSeconds;
  final String taskName;
  final bool isRunning;

  TimerEvent({
    required this.type,
    required this.remainingSeconds,
    required this.taskName,
    required this.isRunning,
  });
}

// 事件流控制器
class TimerEventController {
  static final StreamController<TimerEvent> _controller = StreamController<TimerEvent>.broadcast();
  
  static Stream<TimerEvent> get stream => _controller.stream;
  
  static void emit(TimerEvent event) {
    _controller.add(event);
  }
  
  static void dispose() {
    _controller.close();
  }
}

// 抽象服务接口
abstract class PomodoroServiceStrategy {
  Future<void> initialize();
  Future<void> startService();
  Future<void> stopService();
  Future<bool> isServiceRunning();
  Future<void> sendNotification(String title, String content, {int id = 888});
  Future<void> sendTimerEndNotification(String taskName);
  Future<void> vibrate();
}

// 移动平台服务实现
class MobilePomodoroService implements PomodoroServiceStrategy {
  @override
  Future<void> initialize() async {
    try {
      final service = FlutterBackgroundService();
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: PomodoroBackgroundService.onStart,
          autoStart: false,
          isForegroundMode: true,
          notificationChannelId: 'pomodoro_timer_channel',
          initialNotificationTitle: '🍅 番茄计时器',
          initialNotificationContent: '正在运行中...',
          foregroundServiceNotificationId: 888,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: PomodoroBackgroundService.onStart,
          onBackground: PomodoroBackgroundService.onIosBackground,
        ),
      );
      await _initializeNotifications();
      logger.d('Mobile background service initialized');
    } catch (e) {
      logger.d('Failed to initialize mobile background service: $e');
    }
  }

  @override
  Future<void> startService() async {
    try {
      final service = FlutterBackgroundService();
      await service.startService();
      logger.d('Mobile background service started');
    } catch (e) {
      logger.d('Failed to start mobile background service: $e');
    }
  }

  @override
  Future<void> stopService() async {
    try {
      final service = FlutterBackgroundService();
      service.invoke('stopService');
      logger.d('Mobile background service stopped');
    } catch (e) {
      logger.d('Failed to stop mobile background service: $e');
    }
  }

  @override
  Future<bool> isServiceRunning() async {
    try {
      final service = FlutterBackgroundService();
      return await service.isRunning();
    } catch (e) {
      logger.d('Failed to check mobile service status: $e');
      return false;
    }
  }

  @override
  Future<void> sendNotification(String title, String content, {int id = 888}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomodoro_timer_channel',
      'Pomodoro Timer',
      channelDescription: 'Pomodoro timer notifications',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      enableVibration: false,
      enableLights: false,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await FlutterLocalNotificationsPlugin().show(
      id,
      title,
      content,
      platformChannelSpecifics,
    );
  }

  @override
  Future<void> sendTimerEndNotification(String taskName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomodoro_timer_channel',
      'Pomodoro Timer',
      channelDescription: 'Pomodoro timer notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await FlutterLocalNotificationsPlugin().show(
      889,
      '⏰ 番茄时间到！',
      '任务 "$taskName" 已完成',
      platformChannelSpecifics,
    );
  }

  @override
  Future<void> vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await FlutterLocalNotificationsPlugin().initialize(initializationSettings);
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pomodoro_timer_channel',
      'Pomodoro Timer',
      description: 'Pomodoro timer notifications',
      importance: Importance.high,
    );
    
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

// 桌面平台服务实现
class DesktopPomodoroService implements PomodoroServiceStrategy {
  @override
  Future<void> initialize() async {
    logger.d('Desktop service initialized (no background service needed)');
  }

  @override
  Future<void> startService() async {
    logger.d('Desktop service started (memory-based timer)');
  }

  @override
  Future<void> stopService() async {
    logger.d('Desktop service stopped');
  }

  @override
  Future<bool> isServiceRunning() async {
    // 桌面平台检查内存计时器状态
    return PomodoroBackgroundService._isRunning && PomodoroBackgroundService._timer != null;
  }

  @override
  Future<void> sendNotification(String title, String content, {int id = 888}) async {
    // 桌面平台不发送通知，只记录日志
    logger.d('Desktop notification: $title - $content');
  }

  @override
  Future<void> sendTimerEndNotification(String taskName) async {
    // 桌面平台不发送通知，只记录日志
    logger.d('Desktop timer end notification: 任务 "$taskName" 已完成');
  }

  @override
  Future<void> vibrate() async {
    // 桌面平台不震动
    logger.d('Desktop vibration skipped');
  }
}

// 服务工厂
class PomodoroServiceFactory {
  static PomodoroServiceStrategy createService() {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobilePomodoroService();
    } else {
      return DesktopPomodoroService();
    }
  }
}

@pragma('vm:entry-point')
class PomodoroBackgroundService {
  static const String _serviceId = 'pomodoro_timer_service';
  static const String _channelId = 'pomodoro_timer_channel';
  static const String _channelName = 'Pomodoro Timer';
  static const String _channelDescription = 'Pomodoro timer background service';

  // 内存状态管理
  static int? _startTime;
  static bool _isRunning = false;
  static String _taskName = '';
  static Timer? _timer;
  static int _remainingSeconds = 0;

  // 服务策略
  static late PomodoroServiceStrategy _serviceStrategy;

  static Future<void> initialize() async {
    _serviceStrategy = PomodoroServiceFactory.createService();
    await _serviceStrategy.initialize();
    
    // 检查是否有正在运行的计时器，如果有则发送初始事件
    _emitInitialStateIfRunning();
  }

  // 检查并发送初始状态事件
  static void _emitInitialStateIfRunning() {
    if (_isRunning && _startTime != null) {
      // 计算当前剩余时间
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedSeconds = (now - _startTime!) ~/ 1000;
      final remainingSeconds = (25 * 60) - elapsedSeconds;
      
      if (remainingSeconds > 0) {
        _remainingSeconds = remainingSeconds;
        // 发送更新事件
        _emitEvent(TimerEventType.updated);
        logger.d('Emitted initial state event for running timer');
      } else {
        // 计时器已完成，清除状态
        _clearTimerState();
        _emitEvent(TimerEventType.completed);
        logger.d('Timer was already completed, cleared state');
      }
    }
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    logger.d('Pomodoro background service started');

    // 设置前台服务通知
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // 启动计时器
    await _startTimer(service);
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  static Future<void> _startTimer(ServiceInstance service) async {
    if (!_isRunning || _startTime == null) {
      logger.d('No timer to start');
      return;
    }

    // 计算剩余时间
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (now - _startTime!) ~/ 1000;
    _remainingSeconds = (25 * 60) - elapsedSeconds;
    
    if (_remainingSeconds <= 0) {
      // 时间已到，发送通知并震动
      await _serviceStrategy.sendTimerEndNotification(_taskName);
      await _serviceStrategy.vibrate();
      _clearTimerState();
      _emitEvent(TimerEventType.completed);
      return;
    }

    // 启动计时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _remainingSeconds--;
      
      // 更新通知
      await _updateNotification(_remainingSeconds, _taskName);
      
      // 发送事件到UI
      _emitEvent(TimerEventType.updated);

      if (_remainingSeconds <= 0) {
        timer.cancel();
        // 时间到，发送通知并震动
        await _serviceStrategy.sendTimerEndNotification(_taskName);
        await _serviceStrategy.vibrate();
        _clearTimerState();
        _emitEvent(TimerEventType.completed);
        service.stopSelf();
      }
    });
  }

  static Future<void> _updateNotification(int remainingSeconds, String taskName) async {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    await _serviceStrategy.sendNotification(
      '🍅 番茄计时器',
      '任务: $taskName | 剩余时间: $timeString',
    );
  }

  static void _clearTimerState() {
    _startTime = null;
    _isRunning = false;
    _taskName = '';
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = 0;
  }

  // 发送事件到UI
  static void _emitEvent(TimerEventType type) {
    TimerEventController.emit(TimerEvent(
      type: type,
      remainingSeconds: _remainingSeconds,
      taskName: _taskName,
      isRunning: _isRunning,
    ));
  }

  // 启动后台服务
  static Future<void> startService() async {
    await _serviceStrategy.startService();
    // 在桌面平台上启动内存计时器
    if (!(Platform.isAndroid || Platform.isIOS) && _isRunning && _startTime != null) {
      _startMemoryTimer();
    }
  }

  // 停止后台服务
  static Future<void> stopService() async {
    await _serviceStrategy.stopService();
    _clearTimerState();
    _emitEvent(TimerEventType.stopped);
  }

  // 检查服务是否运行
  static Future<bool> isServiceRunning() async {
    return await _serviceStrategy.isServiceRunning();
  }

  // 在桌面平台上启动内存计时器
  static void _startMemoryTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      
      // 发送事件到UI
      _emitEvent(TimerEventType.updated);
      
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _clearTimerState();
        _emitEvent(TimerEventType.completed);
        logger.d('Memory timer completed');
      }
    });
  }

  // 设置计时器状态
  static void setTimerState(String taskName) {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _isRunning = true;
    _taskName = taskName;
    _remainingSeconds = 25 * 60; // 25分钟
    logger.d('Timer state set: $_startTime, $_isRunning, $_taskName');
    
    // 发送开始事件
    _emitEvent(TimerEventType.started);
    
    // 在桌面平台上启动内存计时器
    if (!(Platform.isAndroid || Platform.isIOS)) {
      _startMemoryTimer();
    }
  }

  // 获取当前状态
  static Map<String, dynamic> getCurrentState() {
    if (!_isRunning || _startTime == null) {
      return {
        'isRunning': false,
        'remainingSeconds': 25 * 60,
        'taskName': '',
      };
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (now - _startTime!) ~/ 1000;
    final remainingSeconds = (25 * 60) - elapsedSeconds;

    return {
      'isRunning': _isRunning,
      'remainingSeconds': remainingSeconds > 0 ? remainingSeconds : 0,
      'taskName': _taskName,
    };
  }

  // 清除计时器状态
  static void clearTimerState() {
    _clearTimerState();
    _emitEvent(TimerEventType.stopped);
  }

  // 获取事件流
  static Stream<TimerEvent> get eventStream => TimerEventController.stream;
} 