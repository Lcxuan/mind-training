import 'dart:math';

/// 生成序列工作记忆训练要显示的数字序列。
class SequenceGenerator {
  SequenceGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// 生成指定长度的数字序列，数字范围为 0 到 9。
  List<int> generate(int length) {
    if (length <= 0) return const [];
    return List.generate(length, (_) => _random.nextInt(10));
  }
}
