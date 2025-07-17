import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:wan_android/core/log_util.dart';

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

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // 配置Android服务
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'pomodoro_timer_channel',
        initialNotificationTitle: '🍅 番茄计时器',
        initialNotificationContent: '正在运行中...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    // 初始化本地通知
    await _initializeNotifications();
  }

  static Future<void> _initializeNotifications() async {
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
    
    // 创建通知渠道
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
      await _sendTimerEndNotification(_taskName);
      await _vibrate();
      _clearTimerState();
      return;
    }

    // 启动计时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _remainingSeconds--;
      
      // 更新通知
      await _updateNotification(_remainingSeconds, _taskName);
      
      // 发送进度更新事件
      service.invoke('updateProgress', {
        'remainingSeconds': _remainingSeconds,
        'taskName': _taskName,
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        // 时间到，发送通知并震动
        await _sendTimerEndNotification(_taskName);
        await _vibrate();
        _clearTimerState();
        service.stopSelf();
      }
    });
  }

  static Future<void> _updateNotification(int remainingSeconds, String taskName) async {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
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
      888,
      '🍅 番茄计时器',
      '任务: $taskName | 剩余时间: $timeString',
      platformChannelSpecifics,
    );
  }

  static Future<void> _sendTimerEndNotification(String taskName) async {
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

  static Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }
  }

  static void _clearTimerState() {
    _startTime = null;
    _isRunning = false;
    _taskName = '';
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = 0;
  }

  // 启动后台服务
  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
    logger.d('Pomodoro background service started');
  }

  // 停止后台服务
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
    _clearTimerState();
    logger.d('Pomodoro background service stopped');
  }

  // 检查服务是否运行
  static Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  // 设置计时器状态
  static void setTimerState(String taskName) {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _isRunning = true;
    _taskName = taskName;
    logger.d('Timer state set: $_startTime, $_isRunning, $_taskName');
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
  }
} 