import 'package:flutter/material.dart';

import '../../../shared/presentation/placeholder_panel.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPanel(
      eyebrow: '主视图',
      title: '日历视图',
      description: '这里将承载纵向无限滚动的全量任务日历流。',
      items: ['按天展开并连续滚动', '支持危险日高亮', '支持单点任务与截止型任务展示'],
    );
  }
}
