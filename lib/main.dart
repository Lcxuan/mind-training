import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mind_training/app/mind_training_app.dart';

void main() {
  // 先初始化 Flutter，再挂载全局 ProviderScope，供各页面共享状态和数据依赖。
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MindTrainingApp()));
}
