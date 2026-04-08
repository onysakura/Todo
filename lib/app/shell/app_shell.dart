import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _paths = <String>[
    AppRoutePath.calendar,
    AppRoutePath.upcoming,
    AppRoutePath.settings,
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
  Widget build(BuildContext context) {
    final currentIndex = _resolveIndex(location);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: _destinations,
        onDestinationSelected: (index) {
          context.go(_paths[index]);
        },
      ),
    );
  }

  int _resolveIndex(String location) {
    for (var index = 0; index < _paths.length; index++) {
      if (location.startsWith(_paths[index])) {
        return index;
      }
    }

    return 0;
  }
}
