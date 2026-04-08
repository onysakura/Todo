import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/app/app.dart';

void main() {
  testWidgets('应用壳加载三项主导航', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TodoApp()));
    await tester.pumpAndSettle();

    expect(find.text('日历'), findsOneWidget);
    expect(find.text('近期'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
