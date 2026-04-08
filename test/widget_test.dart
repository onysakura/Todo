import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/app/app.dart';
import 'package:todo_app/app/shell/app_shell.dart';
import 'package:todo_app/core/routing/app_router.dart';

void main() {
  testWidgets('应用壳加载三项主导航', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TodoApp()));
    await tester.pumpAndSettle();

    expect(find.text('日历'), findsOneWidget);
    expect(find.text('近期'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('窄屏使用底部导航', (tester) async {
    await _pumpShell(tester, const Size(390, 844));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('中等宽度使用紧凑侧边导航', (tester) async {
    await _pumpShell(tester, const Size(720, 1024));

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );
  });

  testWidgets('宽屏默认收起侧边导航并显示展开入口', (tester) async {
    await _pumpShell(tester, const Size(1280, 900));

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );
    expect(find.byTooltip('展开导航'), findsOneWidget);
  });
}

Future<void> _pumpShell(WidgetTester tester, Size surfaceSize) async {
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const MaterialApp(
      home: AppShell(location: AppRoutePath.calendar, child: SizedBox.expand()),
    ),
  );
  await tester.pumpAndSettle();
}
