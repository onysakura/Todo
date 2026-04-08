import 'package:flutter_riverpod/flutter_riverpod.dart';

final appShellIndexProvider = NotifierProvider<AppShellIndexNotifier, int>(
  AppShellIndexNotifier.new,
);

class AppShellIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}
