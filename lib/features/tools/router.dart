import 'package:go_router/go_router.dart';

import 'package:wan_android/features/tools/presentation/page/tools_page.dart'
    show ToolsPage;
import 'package:wan_android/features/tools/presentation/page/pomodoro_timer.dart'
    show PomodoroTimerPage;

final List<GoRoute> toolsRoutes = [
  GoRoute(
    path: '/tools',
    builder: (context, state) => const ToolsPage(),
  ),
  GoRoute(
    path: '/tools/pomodoro',
    builder: (context, state) => const PomodoroTimerPage(),
  ),
]; 