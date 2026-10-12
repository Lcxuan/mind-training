import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/features/history/screens/history_screen.dart';
import 'package:mind_training/features/home/screens/home_screen.dart';
import 'package:mind_training/features/schulte/models/schulte_result.dart';
import 'package:mind_training/features/schulte/screens/schulte_result_screen.dart';
import 'package:mind_training/features/schulte/screens/schulte_training_screen.dart';
import 'package:mind_training/features/sequence_memory/models/sequence_memory_result.dart';
import 'package:mind_training/features/sequence_memory/screens/sequence_memory_result_screen.dart';
import 'package:mind_training/features/sequence_memory/screens/sequence_memory_training_screen.dart';
import 'package:mind_training/features/settings/screens/settings_screen.dart';
import 'package:mind_training/features/stroop/models/stroop_result.dart';
import 'package:mind_training/features/stroop/screens/stroop_result_screen.dart';
import 'package:mind_training/features/stroop/screens/stroop_training_screen.dart';
import 'package:mind_training/features/training_catalog/screens/training_catalog_screen.dart';
import 'package:mind_training/features/training_catalog/screens/training_detail_screen.dart';
import 'package:mind_training/features/training_catalog/screens/training_session_screen.dart';
import 'package:mind_training/app/app_routes.dart';
import 'package:mind_training/app/app_shell.dart';

/// 根导航器承载底部导航壳之外的训练说明、训练过程和结果页面。
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// 全局共享一个路由器实例，避免应用重建时重置导航栈。
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    _buildMainNavigationRoute(),
    ..._buildTrainingRoutes(),
    ..._buildResultRoutes(),
  ],
);

/// 创建四个保留各自导航状态的底部标签分支。
StatefulShellRoute _buildMainNavigationRoute() {
  return StatefulShellRoute.indexedStack(
    // 把当前导航分支交给 AppShell，由它展示页面并处理底部标签切换。
    builder: (context, state, navigationShell) =>
        AppShell(navigationShell: navigationShell),
    // 分支顺序对应底部标签顺序；indexedStack 会保留未选中分支的状态。
    branches: [
      // 首页
      StatefulShellBranch(
        routes: [
          GoRoute(
            name: AppRouteNames.home,
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
      // 训练
      StatefulShellBranch(
        routes: [
          GoRoute(
            name: AppRouteNames.trainingCatalog,
            path: '/training',
            builder: (context, state) => const TrainingCatalogScreen(),
          ),
        ],
      ),
      // 训练
      StatefulShellBranch(
        routes: [
          GoRoute(
            name: AppRouteNames.history,
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
      ),
      // 设置
      StatefulShellBranch(
        routes: [
          GoRoute(
            name: AppRouteNames.settings,
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// 训练说明和训练过程显示在根导航器上，因此不会带出底部导航栏。
List<GoRoute> _buildTrainingRoutes() {
  return [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: AppRouteNames.trainingDetail,
      path: '/exercise/:id',
      builder: (context, state) =>
          TrainingDetailScreen(trainingId: state.pathParameters['id']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: AppRouteNames.trainingSession,
      path: '/session/:id',
      builder: (context, state) => _buildTrainingSession(state),
    ),
  ];
}

/// 按训练类型创建对应的会话页面；restart 参数会触发一个全新的页面状态。
Widget _buildTrainingSession(GoRouterState state) {
  final trainingId = state.pathParameters['id']!;
  final sessionKey = state.uri.queryParameters['restart'] ?? 'initial';

  switch (trainingId) {
    case 'schulte':
      return SchulteTrainingScreen(
        key: ValueKey(sessionKey),
        restartFrom: state.extra as SchulteResult?,
      );
    case 'stroop':
      return StroopTrainingScreen(key: ValueKey(sessionKey));
    case 'sequence':
      return SequenceMemoryTrainingScreen(key: ValueKey(sessionKey));
    default:
      return TrainingSessionScreen(trainingId: trainingId);
  }
}

/// 结果页面同样放在根导航器，保持现有的返回和关闭流程。
List<GoRoute> _buildResultRoutes() {
  return [
    // 舒尔特方格结果页
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: AppRouteNames.schulteResult,
      path: '/result/schulte',
      builder: (context, state) =>
          SchulteResultScreen(result: state.extra! as SchulteResult),
    ),
    // Stroop 训练结果页。
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: AppRouteNames.stroopResult,
      path: '/result/stroop',
      builder: (context, state) =>
          StroopResultScreen(result: state.extra! as StroopResult),
    ),
    // 序列记忆训练结果页。
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: AppRouteNames.sequenceResult,
      path: '/result/sequence',
      builder: (context, state) => SequenceMemoryResultScreen(
        result: state.extra! as SequenceMemoryResult,
      ),
    ),
  ];
}
