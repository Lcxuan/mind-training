import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/app/app_routes.dart';
import 'package:mind_training/features/training_catalog/models/training_type.dart';
import 'package:mind_training/core/theme/app_theme.dart';

/// 首页：提供今日训练入口，并展示三个训练项目的快捷入口。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.bubble_chart_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '心智训练',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              '每天几分钟，\n练习专注与记忆。',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.ink,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '选择一项轻量练习，按自己的节奏开始。',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Card(
              color: AppTheme.ink,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('今日练习', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    const Text(
                      '准备好开始了吗？',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.tonal(
                      onPressed: () =>
                          context.goNamed(AppRouteNames.trainingCatalog),
                      child: const Text('选择一项训练'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '训练项目',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.goNamed(AppRouteNames.trainingCatalog),
                  child: const Text('全部训练'),
                ),
              ],
            ),
            for (final training in TrainingType.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  training.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(training.subtitle),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => context.pushNamed(
                  AppRouteNames.trainingDetail,
                  pathParameters: {'id': training.id},
                ),
              ),
            const SizedBox(height: 8),
            Text(
              '训练结果用于记录个人练习过程，不用于医疗诊断。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
