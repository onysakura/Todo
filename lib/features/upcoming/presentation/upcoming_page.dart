import 'package:flutter/material.dart';

import '../../../shared/presentation/placeholder_panel.dart';

class UpcomingPage extends StatelessWidget {
  const UpcomingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPanel(
      eyebrow: '次视图',
      title: '近期任务',
      description: '这里将展示未来 31 天内的任务，并叠加优先级与危险日排序。',
      items: ['未完成任务优先', '完成与取消任务仍保留展示', '后续将接入动态排序逻辑'],
    );
  }
}
