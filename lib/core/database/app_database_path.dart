import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const appDatabaseFileName = 'todo_app.sqlite';

Future<String> resolveAppDatabasePath() async {
  final directory = await getApplicationSupportDirectory();
  return path.join(directory.path, appDatabaseFileName);
}
