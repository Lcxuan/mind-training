import 'dart:math';

import 'package:mind_training/features/stroop/models/stroop_trial.dart';

/// 生成一致题和冲突题各占一半的 Stroop 练习题目。
class StroopTrialGenerator {
  StroopTrialGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// 生成指定数量的题目，并打乱一致题与冲突题的出现顺序。
  List<StroopTrial> generate({int count = 20}) {
    if (count <= 0) return const [];

    final colors = StroopColor.values;
    final congruentCount = count ~/ 2;
    final trials = <StroopTrial>[];

    for (var index = 0; index < count; index++) {
      final wordColor = colors[_random.nextInt(colors.length)];
      if (index < congruentCount) {
        // 一致题中，文字含义与字体颜色相同。
        trials.add(StroopTrial(wordColor: wordColor, fontColor: wordColor));
      } else {
        // 冲突题的字体颜色必须与文字含义不同。
        final otherColors = colors
            .where((color) => color != wordColor)
            .toList(growable: false);
        final fontColor = otherColors[_random.nextInt(otherColors.length)];
        trials.add(StroopTrial(wordColor: wordColor, fontColor: fontColor));
      }
    }

    trials.shuffle(_random);
    return trials;
  }
}
