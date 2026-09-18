import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gigglego/screens/home_screen.dart';
import 'package:gigglego/widgets/tutorial_overlay.dart';
import 'package:gigglego/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TutorialOverlay & Stuck-Frame Prevention Tests', () {
    testWidgets('Tutorial runs through 4 steps and dismisses cleanly upon Next tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(forceTutorial: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Overlay is visible on Step 1
      expect(find.byType(TutorialOverlay), findsOneWidget);
      expect(find.text('Tap Colors! 🎨'), findsOneWidget);

      // Tap Colors category
      await tester.tap(find.text('Tap Colors! 🎨'));
      await tester.pump();

      // Transition through step 2 to step 3
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Find red! 🔴'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);

      // Tap Red card
      await tester.tap(find.text('Red'));
      await tester.pump();

      // Step 4 is now visible: 'Yay! You did it! 🎉'
      expect(find.text('Yay! You did it! 🎉'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap the Next button to finish
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Overlay should now be completely dismissed!
      expect(find.byType(TutorialOverlay), findsNothing);

      // Storage should reflect completion
      final completed = await StorageService.getTutorialCompleted();
      expect(completed, isTrue);
    });

    testWidgets('Step 4 automatically advances after celebration timer if not tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(forceTutorial: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 1 -> Step 3
      await tester.tap(find.text('Tap Colors! 🎨'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Tap Red to reach Step 4
      await tester.tap(find.text('Red'));
      await tester.pump();

      expect(find.text('Yay! You did it! 🎉'), findsOneWidget);

      // Wait for the 2.5s auto-advance timer to fire
      await tester.pump(const Duration(milliseconds: 2700));

      // Overlay should automatically dismiss without manual button tap
      expect(find.byType(TutorialOverlay), findsNothing);
      expect(await StorageService.getTutorialCompleted(), isTrue);
    });

    testWidgets('Step 4 advances when tapping anywhere on celebration text or mascot',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(forceTutorial: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 1 -> Step 3
      await tester.tap(find.text('Tap Colors! 🎨'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Tap Red to reach Step 4
      await tester.tap(find.text('Red'));
      await tester.pump();

      expect(find.text('Yay! You did it! 🎉'), findsOneWidget);

      // Tap the celebration text itself instead of the Next button
      await tester.tap(find.text('Yay! You did it! 🎉'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Overlay should dismiss
      expect(find.byType(TutorialOverlay), findsNothing);
      expect(await StorageService.getTutorialCompleted(), isTrue);
    });

    testWidgets('Skip Tutorial dismisses overlay cleanly and does not loop',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(forceTutorial: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TutorialOverlay), findsOneWidget);

      // Tap Skip Tutorial
      await tester.tap(find.text('Skip Tutorial'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Overlay is gone
      expect(find.byType(TutorialOverlay), findsNothing);
      expect(await StorageService.getTutorialCompleted(), isTrue);
    });
  });
}
