import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NeoSingleTapContextMenu Tests', () {
    testWidgets('renders child widget and handles actions with Flutter icons',
        (WidgetTester tester) async {
      String? selectedAction;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NeoSingleTapContextMenu(
                actions: [
                  NeoContextMenuAction(
                    id: 'favorite',
                    title: 'Favorite',
                    icon: CupertinoIcons.star,
                    iconSystemName: 'star',
                  ),
                  const NeoContextMenuDivider(),
                  NeoContextMenuAction(
                    id: 'delete',
                    title: 'Delete',
                    icon: CupertinoIcons.delete,
                    iconSystemName: 'trash',
                    destructive: true,
                  ),
                ],
                onSelected: (id) => selectedAction = id,
                child: const Text('Open Menu'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Open Menu'), findsOneWidget);
      expect(selectedAction, isNull);
    });

    testWidgets('equality and properties of NeoContextMenuAction',
        (WidgetTester tester) async {
      final a1 = NeoContextMenuAction(
        id: '1',
        title: 'Action',
        icon: CupertinoIcons.star,
        showTrailingCheckmark: true,
      );
      final a2 = NeoContextMenuAction(
        id: '1',
        title: 'Action',
        icon: CupertinoIcons.star,
        showTrailingCheckmark: true,
      );
      final a3 = NeoContextMenuAction(
        id: '2',
        title: 'Action',
        icon: CupertinoIcons.star,
      );

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
      expect(a1 == a3, isFalse);
    });
  });
}
