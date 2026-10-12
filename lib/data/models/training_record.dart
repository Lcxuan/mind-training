/// 一次已完成训练的持久化记录。
class TrainingRecord {
  const TrainingRecord({
    required this.id,
    required this.trainingId,
    required this.completedAt,
    required this.duration,
    required this.metrics,
  });

  final String id;
  final String trainingId;
  final DateTime completedAt;
  final Duration duration;

  /// 训练专属指标；除数字外，也可存储玩法名称等文本设置。
  final Map<String, Object?> metrics;

  /// 转成 JSON 友好的字段，供本地仓储保存。
  Map<String, Object?> toJson() => {
    'id': id,
    'trainingId': trainingId,
    'completedAt': completedAt.toIso8601String(),
    'durationMs': duration.inMilliseconds,
    'metrics': metrics,
  };

  /// 从本地 JSON 记录还原模型。
  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      id: json['id'] as String,
      trainingId: json['trainingId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      duration: Duration(milliseconds: json['durationMs'] as int),
      metrics: Map<String, Object?>.from(json['metrics'] as Map),
    );
  }
}
