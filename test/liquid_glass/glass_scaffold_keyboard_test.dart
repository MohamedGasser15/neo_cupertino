import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_cupertino/neo_cupertino.dart';
import 'package:neo_cupertino/src/liquid_glass/widgets/shared/glass_page.dart';

void main() {
  setUp(() {
    // Disable setup guard in tests
    glassPageInitializeGuardEnabled = false;
  });

  group('GlassScaffold and Keyboard Layout Audit', () {
    testWidgets('1. Regular GlassScaffold with TextField scrolls focused field above keyboard', (tester) async {
      addTearDown(() => tester.view.reset());
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = FakeViewPadding.zero;

      final controller = ScrollController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        CupertinoApp(
          home: GlassScaffold(
            background: Container(color: CupertinoColors.systemTeal),
            body: ListView(
              controller: controller,
              children: [
                Container(height: 550, color: CupertinoColors.systemIndigo),
                GlassTextField(
                  key: const Key('target_field'),
                  focusNode: focusNode,
                  placeholder: 'Enter name',
                ),
                Container(height: 300, color: CupertinoColors.systemGreen),
              ],
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      // Native keyboard opens (height 300)
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      // Field must be positioned above the keyboard (y <= 500)
      final fieldFinder = find.byKey(const Key('target_field'));
      expect(fieldFinder, findsOneWidget);
      final fieldBottom = tester.getBottomLeft(fieldFinder).dy;
      expect(fieldBottom, lessThanOrEqualTo(500.0));
      expect(controller.offset, greaterThan(0.0));
    });

    testWidgets('2. Login form with multiple fields and submit button remains fully accessible', (tester) async {
      addTearDown(() => tester.view.reset());
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = FakeViewPadding.zero;

      final emailFocus = FocusNode();
      final passwordFocus = FocusNode();
      bool submitted = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: GlassScaffold(
            extendBody: false,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(height: 200, color: CupertinoColors.systemGrey),
                  GlassTextField(
                    key: const Key('email_field'),
                    focusNode: emailFocus,
                    placeholder: 'Email',
                  ),
                  const SizedBox(height: 20),
                  GlassTextField(
                    key: const Key('password_field'),
                    focusNode: passwordFocus,
                    placeholder: 'Password',
                  ),
                  const SizedBox(height: 30),
                  CupertinoButton(
                    key: const Key('submit_button'),
                    onPressed: () => submitted = true,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      passwordFocus.requestFocus();
      await tester.pumpAndSettle();

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      final buttonFinder = find.byKey(const Key('submit_button'));
      expect(buttonFinder, findsOneWidget);
      // Tap the submit button above keyboard
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
      expect(submitted, isTrue);
    });

    testWidgets('3. Long scrollable form scrolls to bottom-most field', (tester) async {
      addTearDown(() => tester.view.reset());
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = FakeViewPadding.zero;

      final focusNode = FocusNode();
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: GlassScaffold(
            body: ListView(
              controller: controller,
              children: [
                for (int i = 0; i < 15; i++)
                  Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.blue.withValues(alpha: 0.2),
                    child: Center(child: Text('Form field \$i')),
                  ),
                GlassTextField(
                  key: const Key('last_field'),
                  focusNode: focusNode,
                  placeholder: 'Last field',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );

      // Scroll to bring the field into view, then request focus
      await tester.scrollUntilVisible(find.byKey(const Key('last_field')), 100);
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      final lastField = find.byKey(const Key('last_field'));
      expect(lastField, findsOneWidget);
      final fieldBottom = tester.getBottomLeft(lastField).dy;
      expect(fieldBottom, lessThanOrEqualTo(500.0));
    });

    testWidgets('4. Screen with fixed bottom action button lifts above keyboard and is tappable', (tester) async {
      addTearDown(() => tester.view.reset());
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = FakeViewPadding.zero;

      bool actionTapped = false;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        CupertinoApp(
          home: GlassScaffold(
            body: ListView(
              children: [
                GlassTextField(
                  key: const Key('text_input'),
                  focusNode: focusNode,
                ),
              ],
            ),
            bottomBar: Container(
              height: 60,
              color: CupertinoColors.activeOrange,
              child: CupertinoButton(
                key: const Key('action_btn'),
                onPressed: () => actionTapped = true,
                child: const Text('Fixed Action'),
              ),
            ),
          ),
        ),
      );

      // Verify bottomBar is initially near the bottom of the screen (y = 740 to 800)
      final btnFinder = find.byKey(const Key('action_btn'));
      expect(btnFinder, findsOneWidget);
      expect(tester.getBottomLeft(btnFinder).dy, greaterThan(700.0));

      // Open keyboard
      focusNode.requestFocus();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      // Bottom bar must now be lifted above the 300px keyboard (bottom <= 500)
      final liftedBottom = tester.getBottomLeft(btnFinder).dy;
      expect(liftedBottom, lessThanOrEqualTo(500.0));

      // Must be tappable above the keyboard
      await tester.tap(btnFinder);
      await tester.pumpAndSettle();
      expect(actionTapped, isTrue);
    });

    testWidgets('5. Screen with no background configured renders properly in both light and dark', (tester) async {
      addTearDown(() => tester.view.reset());
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = FakeViewPadding.zero;

      // Dark mode
      await tester.pumpWidget(
        const CupertinoApp(
          theme: CupertinoThemeData(brightness: Brightness.dark),
          home: GlassScaffold(
            body: Center(child: Text('Dark page with no background')),
          ),
        ),
      );
      expect(find.text('Dark page with no background'), findsOneWidget);

      // Light mode
      await tester.pumpWidget(
        const CupertinoApp(
          theme: CupertinoThemeData(brightness: Brightness.light),
          home: GlassScaffold(
            body: Center(child: Text('Light page with no background')),
          ),
        ),
      );
      expect(find.text('Light page with no background'), findsOneWidget);
    });

    testWidgets('6. Respects explicit resizeToAvoidBottomInset: false', (tester) async {
      addTearDown(() => tester.view.reset());
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = FakeViewPadding.zero;

      final focusNode = FocusNode();

      await tester.pumpWidget(
        CupertinoApp(
          home: GlassScaffold(
            resizeToAvoidBottomInset: false,
            bottomBar: const SizedBox(
              height: 60,
              key: Key('fixed_bottom_bar'),
              child: Text('Stays at bottom'),
            ),
            body: ListView(
              children: [
                GlassTextField(focusNode: focusNode),
              ],
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      // When resizeToAvoidBottomInset is explicitly false, bottomBar stays at screen bottom
      final barFinder = find.byKey(const Key('fixed_bottom_bar'));
      expect(tester.getBottomLeft(barFinder).dy, 800.0);
    });

    testWidgets('7. GlassTextField passes keyboardAppearance correctly', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: GlassScaffold(
            body: Column(
              children: [
                GlassTextField(
                  key: Key('light_field'),
                  keyboardAppearance: Brightness.light,
                ),
                GlassTextField(
                  key: Key('dark_field'),
                  keyboardAppearance: Brightness.dark,
                ),
              ],
            ),
          ),
        ),
      );

      final lightField = tester.widget<CupertinoTextField>(
        find.descendant(
          of: find.byKey(const Key('light_field')),
          matching: find.byType(CupertinoTextField),
        ),
      );
      expect(lightField.keyboardAppearance, Brightness.light);

      final darkField = tester.widget<CupertinoTextField>(
        find.descendant(
          of: find.byKey(const Key('dark_field')),
          matching: find.byType(CupertinoTextField),
        ),
      );
      expect(darkField.keyboardAppearance, Brightness.dark);
    });

    testWidgets('8. GlassModalSheet pads internal content while sheet surface extends under keyboard', (tester) async {
      addTearDown(() => tester.view.reset());
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = FakeViewPadding.zero;

      final focusNode = FocusNode();

      await tester.pumpWidget(
        CupertinoApp(
          home: Stack(
            children: [
              GlassModalSheet(
                initialState: GlassSheetState.full,
                child: ListView(
                  children: [
                    Container(height: 100, color: CupertinoColors.systemPink),
                    GlassTextField(
                      key: const Key('sheet_text_field'),
                      focusNode: focusNode,
                      placeholder: 'Type inside sheet',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      final sheetField = find.byKey(const Key('sheet_text_field'));
      expect(sheetField, findsOneWidget);
      // Field must be above the 300px keyboard
      final fieldBottom = tester.getBottomLeft(sheetField).dy;
      expect(fieldBottom, lessThanOrEqualTo(500.0));
    });

    testWidgets('9. Double-padding guard: sheet child with its own viewInsets padding is not pushed off screen', (tester) async {
      addTearDown(() => tester.view.reset());
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);

      final focusNode = FocusNode();

      await tester.pumpWidget(
        CupertinoApp(
          home: Stack(
            children: [
              GlassModalSheet(
                initialState: GlassSheetState.full,
                child: Builder(
                  builder: (context) {
                    // Simulating forgot_password_sheet or categories_management_screen:
                    // child applies its own viewInsets padding
                    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomInset + 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GlassTextField(
                              key: const Key('guarded_field'),
                              focusNode: focusNode,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final field = find.byKey(const Key('guarded_field'));
      expect(field, findsOneWidget);
      final fieldBottom = tester.getBottomLeft(field).dy;
      // Must be above the 300px keyboard (<= 500)
      expect(fieldBottom, lessThanOrEqualTo(500.0));
    });

    testWidgets('10. Exhaustive geometry verification across extendBody and bar combinations', (tester) async {
      addTearDown(() => tester.view.reset());
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 40, bottom: 30);
      tester.view.viewInsets = FakeViewPadding.zero;

      // Combination A: extendBody: true, appBar: true, bottomBar: true
      await tester.pumpWidget(
        CupertinoApp(
          home: GlassScaffold(
            extendBody: true,
            appBar: const PreferredSize(
              preferredSize: Size.fromHeight(44),
              child: SizedBox(height: 44),
            ),
            bottomBar: const PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: SizedBox(height: 60),
            ),
            body: Container(key: const Key('body_a')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Without keyboard: body fills full screen (height 800)
      expect(tester.getRect(find.byKey(const Key('body_a'))), const Rect.fromLTWH(0, 0, 400, 800));

      // Open keyboard (height 250)
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pumpAndSettle();

      // With keyboard: body height is reduced by exactly 250 (height 550)
      expect(tester.getRect(find.byKey(const Key('body_a'))), const Rect.fromLTWH(0, 0, 400, 550));

      // Combination B: extendBody: false, appBar: true, bottomBar: true
      await tester.pumpWidget(
        CupertinoApp(
          home: GlassScaffold(
            extendBody: false,
            appBar: const PreferredSize(
              preferredSize: Size.fromHeight(44),
              child: SizedBox(height: 44),
            ),
            bottomBar: const PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: SizedBox(height: 60),
            ),
            body: Container(key: const Key('body_b')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // top = topPad (40) + appBar (44) = 84
      // bottom = keyboardInset (250) + bottomBar (60) = 310
      // height = 800 - 84 - 310 = 406
      expect(tester.getRect(find.byKey(const Key('body_b'))), const Rect.fromLTWH(0, 84, 400, 406));
    });
  });
}
