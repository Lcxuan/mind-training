import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mind_training/app/app_routes.dart';

/// 训练说明等全屏二级页面共用的标题栏和安全区域布局。
class StandardPage extends StatelessWidget {
  const StandardPage({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canReturnToPreviousPage = context.canPop();
    return PopScope(
      // 直接导航到训练详情时没有上一页，系统返回也要回到训练目录。
      canPop: canReturnToPreviousPage,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed(AppRouteNames.trainingCatalog);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            tooltip: '返回',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRouteNames.trainingCatalog);
              }
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(child: child),
      ),
    );
  }
}
