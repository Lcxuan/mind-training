import 'package:flutter/material.dart';

import 'package:mind_training/features/training_catalog/models/training_type.dart';
import 'package:mind_training/core/widgets/standard_page.dart';

/// 通用训练会话外壳。
/// 后续各训练模块在这里接入题目呈现、作答处理、计时和结果计算。
class TrainingSessionScreen extends StatelessWidget {
  const TrainingSessionScreen({required this.trainingId, super.key});

  final String trainingId;

  @override
  Widget build(BuildContext context) {
    final training = TrainingType.fromId(trainingId);
    // 训练 id 无效时不创建会话，避免进入不完整的训练流程。
    if (training == null) {
      return const StandardPage(
        title: '训练不可用',
        child: Center(child: Text('请返回并选择其他训练。')),
      );
    }

    return StandardPage(
      title: training.title,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: '退出训练',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.construction_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              '训练会话框架已就绪',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              '接下来将在这里接入${training.title}的题目、计时、作答和结果计算。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text('返回训练说明'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
