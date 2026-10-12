import 'package:flutter/material.dart';

import 'package:mind_training/core/theme/app_theme.dart';
import 'package:mind_training/app/app_router.dart';

/// 配置应用主题和全局路由入口。
class MindTrainingApp extends StatelessWidget {
  const MindTrainingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '心智训练',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
