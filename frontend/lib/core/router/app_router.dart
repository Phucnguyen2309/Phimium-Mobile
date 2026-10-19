import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/bookmark/presentation/pages/bookmark_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/drama/presentation/pages/drama_detail_page.dart';
import '../../features/drama/presentation/pages/video_player_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../features/comment/presentation/pages/comment_page.dart';
import 'app_shell.dart';

/// App Router using GoRouter with nested navigation
class AppRouter {
  AppRouter._();

  // Route paths
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String bookmarks = '/bookmarks';
  static const String profile = '/profile';
  static const String dramaDetail = '/drama/:id';
  static const String videoPlayer = '/drama/:id/episode/:episodeId';
  static const String payment = '/payment';
  static const String comments = '/drama/:id/comments';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: search,
            name: 'search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchPage(),
            ),
          ),
          GoRoute(
            path: bookmarks,
            name: 'bookmarks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookmarkPage(),
            ),
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),

      // Detail routes (outside shell - full screen)
      GoRoute(
        path: dramaDetail,
        name: 'dramaDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DramaDetailPage(dramaId: id);
        },
      ),
      GoRoute(
        path: videoPlayer,
        name: 'videoPlayer',
        builder: (context, state) {
          final dramaId = state.pathParameters['id']!;
          final episodeId = state.pathParameters['episodeId']!;
          return VideoPlayerPage(
            dramaId: dramaId,
            episodeId: episodeId,
          );
        },
      ),
      GoRoute(
        path: payment,
        name: 'payment',
        builder: (context, state) => const PaymentPage(),
      ),
      GoRoute(
        path: comments,
        name: 'comments',
        builder: (context, state) {
          final dramaId = state.pathParameters['id']!;
          return CommentPage(dramaId: dramaId);
        },
      ),
    ],
  );
}
