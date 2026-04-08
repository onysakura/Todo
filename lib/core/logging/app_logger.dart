import 'dart:developer' as developer;

import 'package:logging/logging.dart';

final class AppLogger {
  AppLogger._();

  static final Logger instance = Logger('todo_app');
  static bool _configured = false;

  static void configure() {
    if (_configured) {
      return;
    }

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      developer.log(
        record.message,
        name: record.loggerName,
        level: record.level.value,
        time: record.time,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    });

    _configured = true;
  }
}
