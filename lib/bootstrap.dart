import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'core/logging/app_logger.dart';
import 'core/time/app_time.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.configure();

  FlutterError.onError = (details) {
    AppLogger.instance.severe(
      '捕获到 Flutter 框架异常',
      details.exception,
      details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.severe('捕获到未处理平台异常', error, stack);
    return true;
  };

  await AppTime.initialize();
  runApp(await builder());
}
