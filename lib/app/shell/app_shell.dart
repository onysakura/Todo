import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/upcoming/presentation/upcoming_page.dart';
import 'app_shell_controller.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _pages = <Widget>[
    CalendarPage(),
    UpcomingPage(),
    SettingsPage(),
  ];

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: '日历',
    ),
    NavigationDestination(
      icon: Icon(Icons.schedule_outlined),
      selectedIcon: Icon(Icons.schedule),
      label: '近期',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: '设置',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(appShellIndexProvider);

    return Scaffold(
      body: SafeArea(child: _pages[currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: _destinations,
        onDestinationSelected: (index) {
          ref.read(appShellIndexProvider.notifier).setIndex(index);
        },
      ),
    );
  }
}
