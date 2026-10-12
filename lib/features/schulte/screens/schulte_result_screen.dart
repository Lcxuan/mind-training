import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/app/app_routes.dart';
import 'package:mind_training/features/history/providers/training_history_provider.dart';
import 'package:mind_training/features/schulte/models/schulte_mode.dart';
import 'package:mind_training/features/schulte/models/schulte_result.dart';
import 'package:mind_training/data/models/training_record.dart';
import 'package:mind_training/data/providers/training_record_repository_provider.dart';

/// 显示本局成绩，并在打开结果页时把完成记录写入 SQLite。
class SchulteResultScreen extends ConsumerStatefulWidget {
  const SchulteResultScreen({required this.result, super.key});

  final SchulteResult result;

  @override
  ConsumerState<SchulteResultScreen> createState() =>
      _SchulteResultScreenState();
}

class _SchulteResultScreenState extends ConsumerState<SchulteResultScreen> {
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
      trainingId: 'schulte',
      completedAt: result.completedAt,
      duration: result.duration,
      metrics: {
        'gridSize': result.gridSize,
        'targetCount': result.gridSize * result.gridSize,
        'errorCount': result.errorCount,
        // 保存稳定的枚举标识，历史页再转换成中文显示名称。
        'mode': result.mode.name,
      },
    );

    await ref.read(trainingRecordRepositoryProvider).save(record);
    // 数据库变更会更新 StreamProvider；显式失效确保结果页返回时重新订阅。
    ref.invalidate(trainingHistoryProvider);
  }

  void _restartTraining() {
    // 改变训练路由的 key，让上一局的完成状态不会被复用。
    final restartKey = DateTime.now().microsecondsSinceEpoch;
    context.goNamed(
      AppRouteNames.trainingSession,
      pathParameters: {'id': 'schulte'},
      queryParameters: {'restart': '$restartKey'},
      extra: widget.result,
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('训练结果'),
        leading: IconButton(
          tooltip: '返回首页',
          onPressed: () => context.goNamed(AppRouteNames.home),
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
                Icons.emoji_events_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '完成得很好',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
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
                      const Divider(height: 32, indent: 24, endIndent: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Metric(
                            label: '误触',
                            value: '${widget.result.errorCount} 次',
                          ),
                          _Metric(
                            label: '网格',
                            value:
                                '${widget.result.gridSize} × ${widget.result.gridSize}',
                          ),
                          _Metric(label: '玩法', value: widget.result.mode.label),
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

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}
