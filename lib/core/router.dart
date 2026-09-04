import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/pages/home_page.dart';
import '../features/planning/pages/plan_list_page.dart';
import '../features/planning/pages/plan_detail_page.dart';
import '../features/planning/pages/plan_create_page.dart';
import '../features/planning/pages/schedule_page.dart';
import '../features/planning/pages/focus_timer_page.dart';
import '../features/planning/pages/focus_history_page.dart';
import '../features/health/pages/health_page.dart';
import '../features/ai_chat/pages/chat_page.dart';
import '../features/ai_chat/pages/character_manage_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/settings/pages/theme_page.dart';
import '../features/settings/pages/api_key_page.dart';
import 'widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/planning',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlanListPage(),
          ),
          routes: [
            GoRoute(
              path: 'schedule',
              builder: (context, state) => const SchedulePage(),
            ),
            GoRoute(
              path: 'focus',
              builder: (context, state) => const FocusTimerPage(),
              routes: [
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const FocusHistoryPage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/health',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HealthPage(),
          ),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ChatPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/planning/create',
      builder: (context, state) => const PlanCreatePage(),
    ),
    GoRoute(
      path: '/planning/detail/:id',
      builder: (context, state) =>
          PlanDetailPage(goalId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/settings/theme',
      builder: (context, state) => const ThemePage(),
    ),
    GoRoute(
      path: '/settings/api-key',
      builder: (context, state) => const ApiKeyPage(),
    ),
    GoRoute(
      path: '/chat/characters',
      builder: (context, state) => const CharacterManagePage(),
    ),
  ],
);
