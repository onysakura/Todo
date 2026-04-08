import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell/app_shell.dart';
import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/upcoming/presentation/upcoming_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutePath.calendar,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutePath.calendar,
            builder: (context, state) => const CalendarPage(),
          ),
          GoRoute(
            path: AppRoutePath.upcoming,
            builder: (context, state) => const UpcomingPage(),
          ),
          GoRoute(
            path: AppRoutePath.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});

final class AppRoutePath {
  const AppRoutePath._();

  static const calendar = '/calendar';
  static const upcoming = '/upcoming';
  static const settings = '/settings';
}
