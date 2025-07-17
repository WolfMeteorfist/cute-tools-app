import 'package:go_router/go_router.dart';

import 'package:wan_android/features/tools/presentation/page/tools_page.dart'
    show ToolsPage;
import 'package:wan_android/features/tools/presentation/page/pomodoro_timer.dart'
    show PomodoroTimerPage;
import 'package:wan_android/features/tools/presentation/page/ai_talk_page.dart'
    show AITalkPage;

final List<GoRoute> toolsRoutes = [
  GoRoute(
    path: '/tools',
    name: 'tools',
    builder: (context, state) => const ToolsPage(),
    routes: [
      GoRoute(
        path: 'pomodoro',
        name: 'pomodoro',
        builder: (context, state) => const PomodoroTimerPage(),
      ),
      GoRoute(
        path: 'ai-talk',
        name: 'aiTalk',
        builder: (context, state) => const AITalkPage(),
      ),
    ],
  ),
]; 