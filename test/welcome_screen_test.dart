import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gigglego/screens/welcome_screen.dart';
import 'package:gigglego/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WelcomeScreen Visual Quality and Layout Tests', () {
    const screenSizes = [
      Size(320, 568),  // Compact screen
      Size(360, 640),  // Standard Android
      Size(412, 915),  // Modern tall Android
      Size(800, 1280), // Android Tablet
    ];

    for (final size in screenSizes) {
      testWidgets('WelcomeScreen renders with ZERO overflow at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: WelcomeScreen(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify no overflow exception was thrown
        expect(tester.takeException(), isNull,
            reason: 'Layout overflow error at ${size.width}x${size.height}');

        // Verify key widgets
        expect(find.text('PLAY!'), findsOneWidget);
        expect(find.text('🌟 Let\'s Learn & Play! 🎈'), findsOneWidget);
        expect(find.text('Tap to explore fun games!'), findsOneWidget);
      });
    }

    testWidgets('Tapping PLAY navigates towards HomeScreen and triggers tutorial for new player',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'tutorial_completed': false});

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final playButtonFinder = find.text('PLAY!');
      expect(playButtonFinder, findsOneWidget);

      await tester.tap(playButtonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should now be on HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
