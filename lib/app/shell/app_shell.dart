import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_router.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _bottomNavigationMaxWidth = 600.0;
  static const _expandedRailMinWidth = 840.0;

  static const _items = <_NavigationItem>[
    _NavigationItem(
      path: AppRoutePath.calendar,
      label: '日历',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
    ),
    _NavigationItem(
      path: AppRoutePath.upcoming,
      label: '近期',
      icon: Icons.schedule_outlined,
      selectedIcon: Icons.schedule,
    ),
    _NavigationItem(
      path: AppRoutePath.settings,
      label: '设置',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  bool? _railExpandedOverride;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final currentIndex = _resolveIndex(widget.location);
    final useBottomNavigation = width < _bottomNavigationMaxWidth;
    final allowExpandedRail = width >= _expandedRailMinWidth;
    final isRailExpanded =
        allowExpandedRail && (_railExpandedOverride ?? false);

    return Scaffold(
      body: useBottomNavigation
          ? SafeArea(child: widget.child)
          : Row(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
                    child: NavigationRail(
                      selectedIndex: currentIndex,
                      extended: isRailExpanded,
                      labelType: isRailExpanded
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.selected,
                      minWidth: 72,
                      minExtendedWidth: 176,
                      groupAlignment: -0.9,
                      leading: allowExpandedRail
                          ? IconButton(
                              tooltip: isRailExpanded ? '收起导航' : '展开导航',
                              onPressed: _toggleRailExpansion,
                              style: IconButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(40, 40),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: Icon(
                                isRailExpanded ? Icons.menu_open : Icons.menu,
                              ),
                            )
                          : null,
                      destinations: [
                        for (final item in _items)
                          NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon),
                            label: Text(item.label),
                          ),
                      ],
                      onDestinationSelected: (index) {
                        context.go(_items[index].path);
                      },
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: SafeArea(child: widget.child)),
              ],
            ),
      bottomNavigationBar: useBottomNavigation
          ? NavigationBar(
              selectedIndex: currentIndex,
              destinations: [
                for (final item in _items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
              onDestinationSelected: (index) {
                context.go(_items[index].path);
              },
            )
          : null,
    );
  }

  void _toggleRailExpansion() {
    setState(() {
      _railExpandedOverride = !(_railExpandedOverride ?? true);
    });
  }

  int _resolveIndex(String location) {
    for (var index = 0; index < _items.length; index++) {
      if (location.startsWith(_items[index].path)) {
        return index;
      }
    }

    return 0;
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
