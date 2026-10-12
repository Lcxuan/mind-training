import 'package:mind_training/features/schulte/models/schulte_mode.dart';

/// 舒尔特表格一局完成后交给结果页展示和保存的数据。
class SchulteResult {
  const SchulteResult({
    required this.completedAt,
    required this.duration,
    required this.errorCount,
    required this.gridSize,
    required this.mode,
    required this.hideCompletedHighlight,
  });

  /// 本局训练完成的本地时间，用作结果展示和记录时间。
  final DateTime completedAt;

  /// 从开始计时到完成最后一个目标所用的时长。
  final Duration duration;

  /// 点击非当前目标数字的次数。
  final int errorCount;

  /// 本局网格的边长；5 表示使用 5×5 网格。
  final int gridSize;

  /// 本局使用的目标查找顺序。
  final SchulteMode mode;

  /// 本局是否关闭已完成数字的高亮标记。
  final bool hideCompletedHighlight;
}
