import 'package:go_router/go_router.dart';

//当你只想使用一个库中的少数几个特定部分时，使用 show 可以让代码更清晰地表达你的意图。
import 'package:wan_android/features/auth/presentation/page/login_page.dart'
    show LoginPage;
import 'package:wan_android/features/auth/presentation/page/register_page.dart';

final List<GoRoute> authRoutes = [
  GoRoute(
    path: '/login', 
    name: 'login',
    builder: (context, state) => const LoginPage()
  ),
  GoRoute(
    path: '/register', 
    name: 'register',
    builder: (context, state) => const RegisterPage()
  ),
];
