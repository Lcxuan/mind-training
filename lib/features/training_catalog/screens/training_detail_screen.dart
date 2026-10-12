import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/app/app_routes.dart';
import 'package:mind_training/features/training_catalog/models/training_type.dart';
import 'package:mind_training/core/widgets/standard_page.dart';

/// 单项训练的规则简介和开始入口；具体交互由训练会话页面承载。
class TrainingDetailScreen extends StatelessWidget {
  const TrainingDetailScreen({required this.trainingId, super.key});

  final String trainingId;

  @override
  Widget build(BuildContext context) {
    final training = TrainingType.fromId(trainingId);
    // 路由参数可能无效，需在界面上给出可理解的兜底提示。
    if (training == null) {
      return const StandardPage(
        title: '找不到训练',
        child: Center(child: Text('该训练暂不可用。')),
      );
    }

    return StandardPage(
      title: training.title,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                switch (training.icon) {
                  'grid' => Icons.grid_4x4_rounded,
                  'palette' => Icons.palette_outlined,
                  _ => Icons.memory_rounded,
                },
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              training.subtitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              training.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 22),
            _InfoRow(label: '预计时长', value: training.duration),
            const _InfoRow(label: '记录方式', value: '仅保存本次练习结果'),
            const Spacer(),
            FilledButton(
              onPressed: () => context.pushNamed(
                AppRouteNames.trainingSession,
                pathParameters: {'id': training.id},
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('开始练习'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '训练结果仅用于记录个人练习过程，不构成医疗评估。',
              textAlign: TextAlign.center,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
