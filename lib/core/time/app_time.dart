import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;

final class AppTime {
  AppTime._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    _initialized = true;
  }

  static DateTime nowLocal() => DateTime.now().toLocal();

  static String formatDateTime(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(value.toLocal());
  }

  static String formatDate(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(value.toLocal());
  }
}
