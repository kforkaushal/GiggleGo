import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gigglego/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeScreen Responsiveness and Layout Safety Tests', () {
    const screenSizes = [
      Size(320, 568),  // Compact screen (iPhone SE / small Android)
      Size(360, 640),  // Standard Android viewport
      Size(412, 915),  // Modern tall Android (Pixel 8)
      Size(800, 1280), // Android Tablet
    ];

    for (final size in screenSizes) {
      testWidgets('HomeScreen renders with ZERO overflow at ${size.width}x${size.height}',
          (WidgetTester tester) async {
        // Set physical constraints
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(
            home: HomeScreen(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Verify no Flutter yellow-and-black overflow error was thrown
        expect(tester.takeException(), isNull,
            reason: 'Overflow or layout error detected at ${size.width}x${size.height}');

        // Verify key widgets are present
        expect(find.text('Giggle Go!'), findsOneWidget);
        expect(find.text('Pick a game'), findsOneWidget);
        expect(find.text('Colors'), findsOneWidget);
        expect(find.text('Fruits'), findsOneWidget);
      });
    }

    testWidgets('First-time user sees "Start playing!" prompt', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'tutorial_completed': false});

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Start playing!'), findsOneWidget);
    });

    testWidgets('Returning user sees "Play again!" prompt', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'tutorial_completed': true,
        'last_played_category': 'fruits',
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Play again!'), findsOneWidget);
    });
  });
}
