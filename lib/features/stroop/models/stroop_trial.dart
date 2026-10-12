/// Stroop 练习使用的四种颜色。
enum StroopColor { red, blue, green, yellow }

extension StroopColorDetails on StroopColor {
  /// 显示在题目和作答选项中的中文颜色名称。
  String get label => switch (this) {
    StroopColor.red => '红色',
    StroopColor.blue => '蓝色',
    StroopColor.green => '绿色',
    StroopColor.yellow => '黄色',
  };
}

/// 一道 Stroop 题目：文字含义与实际字体颜色可以相同，也可以不同。
class StroopTrial {
  const StroopTrial({required this.wordColor, required this.fontColor});

  /// 文字所表达的颜色含义。
  final StroopColor wordColor;

  /// 文字实际显示的颜色，也是本题正确答案。
  final StroopColor fontColor;
}
