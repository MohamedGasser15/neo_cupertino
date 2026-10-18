import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

void main() {
  testWidgets(
      'GlassSearchBar renders collapsed pill when idle and expands on focus',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    bool cancelled = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: SizedBox(
              width: 380,
              child: GlassSearchBar(
                controller: controller,
                focusNode: focusNode,
                collapsedWidth: 200.0,
                placeholder: 'Search items...',
                onCancel: () => cancelled = true,
              ),
            ),
          ),
        ),
      ),
    );

    // Initial state: idle
    expect(find.text('Search items...'), findsOneWidget);
    expect(focusNode.hasFocus, isFalse);

    // Tap to focus
    await tester.tap(find.byType(CupertinoTextField));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(focusNode.hasFocus, isTrue);
    expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);

    // Enter text
    controller.text = 'Hello';
    await tester.pump();

    // Tap cancel button
    await tester.tap(find.byIcon(CupertinoIcons.xmark));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(cancelled, isTrue);
    expect(controller.text, isEmpty);
    expect(focusNode.hasFocus, isFalse);

    controller.dispose();
    focusNode.dispose();
  });

  testWidgets('GlassSearchBar supports RTL layout with Directionality',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    await tester.pumpWidget(
      CupertinoApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: CupertinoPageScaffold(
            child: Center(
              child: SizedBox(
                width: 380,
                child: GlassSearchBar(
                  controller: controller,
                  focusNode: focusNode,
                  collapsedWidth: 240.0,
                  placeholder: 'بحث في التصنيفات...',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('بحث في التصنيفات...'), findsOneWidget);

    // Focus field in RTL
    focusNode.requestFocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(focusNode.hasFocus, isTrue);
    expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);

    controller.dispose();
    focusNode.dispose();
  });

  testWidgets('GlassSearchBar supports custom leading and actions',
      (WidgetTester tester) async {
    const customLeadingKey = Key('custom_leading');
    const customActionKey = Key('custom_action');

    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: SizedBox(
              width: 380,
              child: GlassSearchBar(
                leading: Icon(CupertinoIcons.mic_fill, key: customLeadingKey),
                actions: [
                  Icon(CupertinoIcons.slider_horizontal_3,
                      key: customActionKey),
                ],
                placeholder: 'Filter items...',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(customLeadingKey), findsOneWidget);
    expect(find.byKey(customActionKey), findsOneWidget);
    expect(find.text('Filter items...'), findsOneWidget);
  });

  testWidgets(
      'GlassSearchBar supports text cancel button and custom cancel button builder',
      (WidgetTester tester) async {
    final focusNode = FocusNode();

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: SizedBox(
              width: 380,
              child: GlassSearchBar(
                focusNode: focusNode,
                cancelButtonType: GlassCancelButtonType.text,
                cancelButtonText: 'إلغاء',
              ),
            ),
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('إلغاء'), findsOneWidget);

    focusNode.dispose();
  });
}
