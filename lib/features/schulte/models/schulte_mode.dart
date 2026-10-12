/// 舒尔特训练支持的目标查找顺序。
enum SchulteMode {
  /// 从 1 开始依次找到最大的数字。
  ascending,

  /// 从最大数字开始依次找到 1。
  descending,

  /// 在最小和最大数字之间交替查找，例如 1、N、2、N-1。
  alternating,
}

extension SchulteModeDetails on SchulteMode {
  /// 面向用户展示的玩法名称。
  String get label => switch (this) {
    SchulteMode.ascending => '正序',
    SchulteMode.descending => '倒序',
    SchulteMode.alternating => '两端交替',
  };

  /// 说明本玩法的查找规则。
  String get instruction => switch (this) {
    SchulteMode.ascending => '从 1 开始，按顺序找到所有数字。',
    SchulteMode.descending => '从最大数字开始，倒着找到 1。',
    SchulteMode.alternating => '交替寻找最小和最大数字，例如 1、N、2、N-1。',
  };

  /// 根据网格数字总数生成本局要查找的数字顺序。
  List<int> targetSequence(int count) {
    switch (this) {
      case SchulteMode.ascending:
        return List.generate(count, (index) => index + 1);
      case SchulteMode.descending:
        return List.generate(count, (index) => count - index);
      case SchulteMode.alternating:
        return List.generate(count, (index) {
          final offset = index ~/ 2;
          return index.isEven ? offset + 1 : count - offset;
        });
    }
  }
}
