import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mind_training/database/app_database_provider.dart';
import 'package:mind_training/data/repositories/training_record_repository.dart';

/// 为训练结果页提供共享的本地记录仓储。
final trainingRecordRepositoryProvider = Provider<TrainingRecordRepository>(
  (ref) => DriftTrainingRecordRepository(ref.watch(appDatabaseProvider)),
);
