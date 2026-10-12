import 'package:flutter/material.dart';

/// 设置页的静态布局；偏好项目前是占位，接入设置存储后启用交互。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const SwitchListTile.adaptive(
            value: true,
            onChanged: null,
            title: Text('声音反馈'),
            subtitle: Text('设置存储功能接入后可在这里调整'),
          ),
          const SwitchListTile.adaptive(
            value: false,
            onChanged: null,
            title: Text('振动反馈'),
            subtitle: Text('训练中的触觉反馈偏好'),
          ),
          const Divider(height: 24),
          ListTile(
            title: const Text('隐私说明'),
            subtitle: const Text('首版训练记录计划保存在本机'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: '心智训练',
              applicationVersion: '0.1.0',
              children: const [Text('训练内容用于日常练习与个人记录，不构成医疗建议、诊断或治疗。')],
            ),
          ),
          const ListTile(title: Text('版本'), subtitle: Text('0.1.0 · 基础框架')),
        ],
      ),
    );
  }
}
