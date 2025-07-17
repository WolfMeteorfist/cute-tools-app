import 'package:go_router/go_router.dart';
import 'package:wan_android/core/app_routes.dart';
import 'package:wan_android/features/article/presentation/page/article_detail_page.dart';
import 'package:wan_android/features/article/presentation/page/article_list_page.dart';

final List<GoRoute> articleRoutes = [
  GoRoute(
    path: AppRoutes.article,
    name: 'article',
    builder: (context, state) => const ArticleListPage(),
    routes: [
      GoRoute(
        path: ':id',
        name: 'articleDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null) {
            throw Exception('Error');
          }
          return ArticleDetailPage('id: $id');
        },
      ),
    ],
  ),
];
