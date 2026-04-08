import 'package:flutter/material.dart';

import '../../../shared/presentation/placeholder_panel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPanel(
      eyebrow: '辅助页',
      title: '设置',
      description: '这里将放置同步配置、节假日刷新、标签管理入口和后台选项。',
      items: ['WebDAV 配置', '节假日数据刷新', '标签与颜色管理'],
    );
  }
}
