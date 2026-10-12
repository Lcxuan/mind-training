import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/app/app_routes.dart';
import 'package:mind_training/features/history/providers/training_history_provider.dart';
import 'package:mind_training/features/sequence_memory/models/sequence_memory_result.dart';
import 'package:mind_training/data/models/training_record.dart';
import 'package:mind_training/data/providers/training_record_repository_provider.dart';

/// 展示序列工作记忆成绩，并保存本局指标。
class SequenceMemoryResultScreen extends ConsumerStatefulWidget {
  const SequenceMemoryResultScreen({required this.result, super.key});

  final SequenceMemoryResult result;

  @override
  ConsumerState<SequenceMemoryResultScreen> createState() =>
      _SequenceMemoryResultScreenState();
}

class _SequenceMemoryResultScreenState
    extends ConsumerState<SequenceMemoryResultScreen> {
  late final Future<void> _saveOperation;

  @override
  void initState() {
    super.initState();
    _saveOperation = _saveResult();
  }

  Future<void> _saveResult() async {
    final result = widget.result;
    final record = TrainingRecord(
      id: result.completedAt.microsecondsSinceEpoch.toString(),
      trainingId: 'sequence',
      completedAt: result.completedAt,
      duration: result.duration,
      metrics: {
        'highestCompletedLength': result.highestCompletedLength,
        'correctRounds': result.correctRounds,
        'attemptedRounds': result.attemptedRounds,
        'accuracyPercent': result.accuracyPercent,
        'maxSequenceLength': result.maxSequenceLength,
        'reachedMaximum': result.reachedMaximum,
      },
    );

    await ref.read(trainingRecordRepositoryProvider).save(record);
    // 数据库变更会更新 StreamProvider；显式失效让历史页读取最新成绩。
    ref.invalidate(trainingHistoryProvider);
  }

  String get _durationLabel {
    final duration = widget.result.duration;
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final centiseconds = ((duration.inMilliseconds % 1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$centiseconds';
  }

  void _restartTraining() {
    // 为每局生成新路由 key，保证重练时重新生成数字序列。
    final restartKey = DateTime.now().microsecondsSinceEpoch;
    context.goNamed(
      AppRouteNames.trainingSession,
      pathParameters: {'id': 'sequence'},
      queryParameters: {'restart': '$restartKey'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.result;
    final bestLength = result.highestCompletedLength == 0
        ? '未通过首轮'
        : '${result.highestCompletedLength} 位';

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练结果'),
        leading: IconButton(
          tooltip: '返回训练说明',
          onPressed: () => context.goNamed(
            AppRouteNames.trainingDetail,
            pathParameters: {'id': 'sequence'},
          ),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                result.reachedMaximum
                    ? Icons.emoji_events_rounded
                    : Icons.psychology_alt_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                result.reachedMaximum ? '完成最高挑战' : '本局结束',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 22,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '本次用时',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _durationLabel,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Divider(height: 32, indent: 12, endIndent: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 18,
                        children: [
                          _Metric(label: '最高完成长度', value: bestLength),
                          _Metric(
                            label: '整轮正确率',
                            value:
                                '${result.accuracyPercent.toStringAsFixed(0)}%',
                          ),
                          _Metric(
                            label: '成功轮数',
                            value:
                                '${result.correctRounds}/${result.attemptedRounds}',
                          ),
                          _Metric(
                            label: '挑战上限',
                            value: '${result.maxSequenceLength} 位',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FutureBuilder<void>(
                future: _saveOperation,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      '本次成绩已显示，但保存记录失败。',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.deepOrange),
                    );
                  }
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('正在保存练习记录…'),
                      ],
                    );
                  }
                  return const Text(
                    '练习记录已保存在本机。',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  );
                },
              ),
              const Spacer(),
              FilledButton(
                onPressed: _restartTraining,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('再练一次'),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.goNamed(AppRouteNames.history),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('查看练习记录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 结果卡片中的一个统计项。
class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
