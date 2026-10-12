/// 一局序列工作记忆训练完成后交给结果页展示和保存的数据。
class SequenceMemoryResult {
  const SequenceMemoryResult({
    required this.completedAt,
    required this.duration,
    required this.highestCompletedLength,
    required this.correctRounds,
    required this.attemptedRounds,
    required this.maxSequenceLength,
  });

  /// 本局完成时间。
  final DateTime completedAt;

  /// 从第一组数字显示到本局结束的总时长。
  final Duration duration;

  /// 完整复现成功的最长序列长度；未通过首轮时为 0。
  final int highestCompletedLength;

  /// 完整复现正确的轮数。
  final int correctRounds;

  /// 本局尝试的序列总轮数，包含最后一次错误作答。
  final int attemptedRounds;

  /// 本训练允许挑战的最大序列长度。
  final int maxSequenceLength;

  /// 完整复现正确的轮数占尝试轮数的比例，以百分比表示。
  double get accuracyPercent =>
      attemptedRounds == 0 ? 0 : correctRounds * 100 / attemptedRounds;

  /// 是否完成了最长序列挑战。
  bool get reachedMaximum => highestCompletedLength >= maxSequenceLength;
}
