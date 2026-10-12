/// 训练目录的静态元数据；新增训练时同步补充页面路由和训练实现。
enum TrainingType {
  schulte(
    id: 'schulte',
    title: '舒尔特表格',
    subtitle: '在网格中按顺序寻找数字',
    description: '按顺序点击网格中的数字，完成后查看本次用时和误触情况。',
    icon: 'grid',
    duration: '约 2 分钟',
  ),
  stroop(
    id: 'stroop',
    title: 'Stroop 训练',
    subtitle: '忽略词义，识别字体颜色',
    description: '观察颜色词并选择字体实际显示的颜色，题目包含文字与颜色一致和冲突的情况。',
    icon: 'palette',
    duration: '约 3 分钟',
  ),
  sequenceMemory(
    id: 'sequence',
    title: '序列工作记忆',
    subtitle: '记住并按顺序复现数字',
    description: '从 3 位数字开始记忆并按顺序输入，答对后逐步增加长度，最高挑战 9 位。',
    icon: 'memory',
    duration: '约 3 分钟',
  );

  const TrainingType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.duration,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final String duration;

  /// 根据路由参数解析训练类型；未知 id 返回 null，供页面展示兜底状态。
  static TrainingType? fromId(String id) {
    for (final type in values) {
      if (type.id == id) return type;
    }
    return null;
  }
}
