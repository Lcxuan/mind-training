/// 一局 Stroop 练习完成后交给结果页展示和保存的数据。
class StroopResult {
  const StroopResult({
    required this.completedAt,
    required this.duration,
    required this.totalTrials,
    required this.correctCount,
    required this.incorrectCount,
    required this.totalReactionTimeMs,
  });

  /// 本局完成时间。
  final DateTime completedAt;

  /// 从第一题显示到最后一次作答的总时长。
  final Duration duration;

  /// 本局题目总数。
  final int totalTrials;

  /// 按字体颜色作答正确的题目数。
  final int correctCount;

  /// 作答错误的题目数。
  final int incorrectCount;

  /// 每道题作答时间的累计值，单位为毫秒。
  final int totalReactionTimeMs;

  /// 本局正确率，以百分比表示。
  double get accuracyPercent =>
      totalTrials == 0 ? 0 : correctCount * 100 / totalTrials;

  /// 平均每题反应时间，错误作答也计入平均值。
  int get averageReactionTimeMs =>
      totalTrials == 0 ? 0 : totalReactionTimeMs ~/ totalTrials;
}
