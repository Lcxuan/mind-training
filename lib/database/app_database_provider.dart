import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mind_training/database/app_database.dart';

/// 由 ProviderScope 管理数据库连接，并在应用销毁时关闭连接。
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() {
    database.close();
  });
  return database;
});
