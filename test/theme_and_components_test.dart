import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

void main() {
  group('NeoTheme Tests', () {
    testWidgets('NeoTheme provides NeoThemeData and synchronizes CupertinoTheme',
        (WidgetTester tester) async {
      late NeoThemeData retrievedTheme;
      late CupertinoThemeData retrievedCupertinoTheme;
      late BuildContext capturedContext;

      await tester.pumpWidget(
        NeoTheme(
          data: NeoThemeData.dark(
            primaryColor: CupertinoColors.systemPurple,
          ),
          child: Builder(
            builder: (context) {
              capturedContext = context;
              retrievedTheme = NeoTheme.of(context);
              retrievedCupertinoTheme = CupertinoTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(retrievedTheme.brightness, Brightness.dark);
      expect(retrievedTheme.primaryColor, CupertinoColors.systemPurple);
      expect(
        CupertinoDynamicColor.resolve(retrievedCupertinoTheme.primaryColor, capturedContext),
        CupertinoDynamicColor.resolve(CupertinoColors.systemPurple, capturedContext),
      );
      expect(retrievedCupertinoTheme.brightness, Brightness.dark);
    });
  });

  group('NeoWheelPicker Tests', () {
    testWidgets('NeoWheelPicker renders children and selection lens',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 200,
              child: NeoWheelPicker(
                itemExtent: 40,
                onSelectedItemChanged: (_) {},
                children: const [
                  Text('Option 1'),
                  Text('Option 2'),
                  Text('Option 3'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.byType(CupertinoPicker), findsOneWidget);
    });
  });

  group('NeoActionSheet Tests', () {
    testWidgets('NeoActionSheet renders actions and handles tap',
        (WidgetTester tester) async {
      bool editTapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: NeoActionSheet(
            title: const Text('Actions'),
            message: const Text('Choose an action below'),
            actions: [
              NeoActionSheetAction(
                child: const Text('Edit Item'),
                onPressed: () => editTapped = true,
              ),
            ],
            cancelButton: NeoActionSheetAction(
              child: const Text('Cancel'),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Choose an action below'), findsOneWidget);
      expect(find.text('Edit Item'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Edit Item'));
      expect(editTapped, isTrue);
    });
  });

  group('NeoTooltip Tests', () {
    testWidgets('NeoTooltip triggers on long press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: NeoTooltip(
                message: 'Help Information',
                child: Text('Hover or Press Me'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hover or Press Me'), findsOneWidget);
      expect(find.text('Help Information'), findsNothing);

      await tester.longPress(find.text('Hover or Press Me'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Help Information'), findsOneWidget);
    });
  });

  group('NeoPullToRefresh Tests', () {
    testWidgets('NeoPullToRefresh wraps CustomScrollView properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: NeoPullToRefresh.list(
            onRefresh: () async {},
            children: const [
              Text('Item 1'),
              Text('Item 2'),
            ],
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.byType(GlassSliverRefreshControl, skipOffstage: false), findsOneWidget);
    });
  });
}
