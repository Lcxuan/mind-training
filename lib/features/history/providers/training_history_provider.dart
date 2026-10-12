import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mind_training/data/models/training_record.dart';
import 'package:mind_training/data/providers/training_record_repository_provider.dart';

/// 订阅本地训练记录；数据库变化时会自动推送最新列表。
final trainingHistoryProvider = StreamProvider<List<TrainingRecord>>(
  (ref) => ref.watch(trainingRecordRepositoryProvider).watchAll(),
);
