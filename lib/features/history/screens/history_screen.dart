import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mind_training/data/models/training_record.dart';
import 'package:mind_training/features/training_catalog/models/training_type.dart';
import 'package:mind_training/features/history/providers/training_history_provider.dart';

/// 从本地仓储读取练习记录，分别处理加载、错误、空状态和列表状态。
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod 会在仓储初始化和记录刷新后自动更新页面。
    final history = ref.watch(trainingHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('练习记录')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const _HistoryMessage(
          icon: Icons.sync_problem_rounded,
          title: '暂时无法读取记录',
          message: '请稍后重试。',
        ),
        data: (records) => records.isEmpty
            ? const _HistoryMessage(
                icon: Icons.insights_rounded,
                title: '完成训练后，记录会显示在这里',
                message: '练习记录保存在本机。',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: records.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final record = records[index];
                  final training = TrainingType.fromId(record.trainingId);
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.check_rounded),
                      ),
                      title: Text(training?.title ?? '训练'),
                      subtitle: Text(_recordSummary(record)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// 将三种训练的专属指标整理成历史列表中的简短摘要。
String _recordSummary(TrainingRecord record) {
  final details = <String>[
    _formatCompletedAt(record.completedAt),
    '${record.duration.inSeconds} 秒',
  ];

  if (record.trainingId == 'schulte') {
    final gridSize = record.metrics['gridSize'];
    if (gridSize is num) {
      final size = gridSize.toInt();
      details.add('$size × $size');
    }

    // 旧版记录没有 mode 字段，缺省时按原有正序玩法展示。
    final modeName = record.metrics['mode'] as String? ?? 'ascending';
    final modeLabel = switch (modeName) {
      'descending' => '倒序',
      'alternating' => '两端交替',
      _ => '正序',
    };
    details.add(modeLabel);
    details.add('误触 ${record.metrics['errorCount'] as num? ?? 0} 次');
  } else if (record.trainingId == 'stroop') {
    final accuracy = record.metrics['accuracyPercent'];
    final averageReaction = record.metrics['averageReactionTimeMs'];
    final totalTrials = record.metrics['totalTrials'];
    final correctCount = record.metrics['correctCount'];

    if (accuracy is num) {
      details.add('正确率 ${accuracy.toStringAsFixed(0)}%');
    }
    if (correctCount is num && totalTrials is num) {
      details.add('正确 ${correctCount.toInt()}/${totalTrials.toInt()} 题');
    }
    if (averageReaction is num) {
      details.add('平均 ${averageReaction.toInt()} ms/题');
    }
  } else if (record.trainingId == 'sequence') {
    final highestLength = record.metrics['highestCompletedLength'];
    final accuracy = record.metrics['accuracyPercent'];
    final correctRounds = record.metrics['correctRounds'];
    final attemptedRounds = record.metrics['attemptedRounds'];

    if (highestLength is num) {
      details.add(
        highestLength > 0 ? '最高 ${highestLength.toInt()} 位' : '未通过首轮',
      );
    }
    if (accuracy is num) {
      details.add('整轮正确率 ${accuracy.toStringAsFixed(0)}%');
    }
    if (correctRounds is num && attemptedRounds is num) {
      details.add('成功 ${correctRounds.toInt()}/${attemptedRounds.toInt()} 轮');
    }
  }

  return details.join(' · ');
}

String _formatCompletedAt(DateTime dateTime) {
  final local = dateTime.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$year/$month/$day $hour:$minute';
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
