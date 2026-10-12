import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/app/app_routes.dart';
import 'package:mind_training/features/training_catalog/models/training_type.dart';
import 'package:mind_training/core/theme/app_theme.dart';

/// 展示当前支持的训练项目，并跳转到对应训练说明页。
class TrainingCatalogScreen extends StatelessWidget {
  const TrainingCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择训练')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            '挑一项练习，\n从几分钟开始。',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.ink,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '每项训练都可以独立完成，练习结果仅用于个人记录。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          for (final type in TrainingType.values) ...[
            _TrainingCard(
              type: type,
              onTap: () => context.pushNamed(
                AppRouteNames.trainingDetail,
                pathParameters: {'id': type.id},
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({required this.type, required this.onTap});

  final TrainingType type;
  final VoidCallback onTap;

  // 图标由训练元数据中的轻量标识映射，避免把 IconData 放进领域模型。
  IconData get _icon => switch (type.icon) {
    'grid' => Icons.grid_4x4_rounded,
    'palette' => Icons.palette_outlined,
    _ => Icons.memory_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(_icon, color: AppTheme.green),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type.duration,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
