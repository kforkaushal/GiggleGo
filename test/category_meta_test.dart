import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigglego/data/category_meta.dart';
import 'package:gigglego/widgets/smooth_mascot.dart';
import 'package:gigglego/widgets/game_graphic.dart';
import 'package:gigglego/models/game_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CategoryMeta Canonical Asset Verification (Bug #1)', () {
    test('All 6 canonical categories exist and have valid single-object hero icons', () {
      expect(allCategories.length, 6);

      final expectedCategories = ['alphabet', 'colors', 'fruits', 'animals', 'vehicles', 'shapes'];
      for (final id in expectedCategories) {
        final meta = getCategoryMeta(id);
        expect(meta.id, id);
        expect(meta.title, isNotEmpty);
        expect(meta.iconPath, isNotEmpty);

        // Verify image exists on disk
        final file = File(meta.iconPath);
        expect(file.existsSync(), isTrue, reason: 'Icon missing: ${meta.iconPath}');
      }
    });

    test('Single-object hero icon mapping matches PRD Section 4.1', () {
      expect(getCategoryMeta('alphabet').iconPath, 'assets/images/alphabet/a.png');
      expect(getCategoryMeta('colors').iconPath, 'assets/images/items/colors/red.png');
      expect(getCategoryMeta('fruits').iconPath, 'assets/images/items/fruits/apple.png');
      expect(getCategoryMeta('animals').iconPath, 'assets/images/items/animals/lion.png');
      expect(getCategoryMeta('vehicles').iconPath, 'assets/images/items/vehicles/bus.png');
      expect(getCategoryMeta('shapes').iconPath, 'assets/images/items/shapes/star.png');
    });
  });

  group('Companion Mascot Psychology Verification (Bug #4)', () {
    testWidgets('SmoothMascot supports curious action without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothMascot(
              action: 'curious',
              size: 80,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(SmoothMascot), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('GameGraphic Simplified Renderer Verification (Part 2)', () {
    testWidgets('Renders with imagePath and fallback placeholder without error', (tester) async {
      const itemWithImage = GameItem(
        emoji: '🍎',
        name: 'Apple',
        category: 'fruits',
        imagePath: 'assets/images/fruits/apple.png',
      );

      const itemWithoutImage = GameItem(
        emoji: '🍌',
        name: 'Banana',
        category: 'fruits',
        imagePath: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GameGraphic.fromItem(itemWithImage, size: 60),
                GameGraphic.fromItem(itemWithoutImage, size: 60),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GameGraphic), findsNWidgets(2));
      expect(find.text('B'), findsOneWidget); // Fallback letter placeholder
      expect(tester.takeException(), isNull);
    });
  });
}
