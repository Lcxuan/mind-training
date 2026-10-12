import 'package:flutter/material.dart';

class AppTheme {
  /// App 的基础色板，后续页面颜色优先从这里复用。
  static const ink = Color(0xFF18302D);
  static const green = Color(0xFF287A68);
  static const canvas = Color(0xFFF5F7F4);

  /// 全局 Material 3 主题，集中维护背景、主色和卡片样式。
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: green,
      primary: green,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: EdgeInsets.zero,
    ),
  );
}
