import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gigglego/data/alphabet_data.dart';
import 'package:gigglego/data/animals_data.dart';
import 'package:gigglego/data/fruits_data.dart';
import 'package:gigglego/data/shapes_data.dart';
import 'package:gigglego/data/vehicles_data.dart';
import 'package:gigglego/data/colors_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Asset Integrity and Data Verification', () {
    test('Alphabet data has 26 letters and all PNG assets exist', () {
      expect(alphabetData.length, 26);
      for (final item in alphabetData) {
        expect(item.imagePath, isNotNull, reason: '${item.name} should have an imagePath');
        final file = File(item.imagePath!);
        expect(file.existsSync(), isTrue, reason: 'File should exist at ${item.imagePath}');
      }
    });

    test('All animal item imagePaths exist on disk', () {
      for (final item in animalsData) {
        if (item.imagePath != null) {
          final file = File(item.imagePath!);
          expect(file.existsSync(), isTrue, reason: 'Animal asset missing: ${item.imagePath}');
        }
      }
    });

    test('All fruit item imagePaths exist on disk', () {
      for (final item in fruitsData) {
        if (item.imagePath != null) {
          final file = File(item.imagePath!);
          expect(file.existsSync(), isTrue, reason: 'Fruit asset missing: ${item.imagePath}');
        }
      }
    });

    test('All vehicle item imagePaths exist on disk', () {
      for (final item in vehiclesData) {
        if (item.imagePath != null) {
          final file = File(item.imagePath!);
          expect(file.existsSync(), isTrue, reason: 'Vehicle asset missing: ${item.imagePath}');
        }
      }
    });

    test('All shape item imagePaths exist on disk', () {
      for (final item in shapesData) {
        if (item.imagePath != null) {
          final file = File(item.imagePath!);
          expect(file.existsSync(), isTrue, reason: 'Shape asset missing: ${item.imagePath}');
        }
      }
    });

    test('Mascot assets exist on disk', () {
      final mascots = [
        'assets/images/mascot/idle.png',
        'assets/images/mascot/happy.png',
        'assets/images/mascot/celebrate.png',
        'assets/images/mascot/jump.png',
        'assets/images/mascot/pointing.png',
        'assets/images/mascot/sad.png',
        'assets/images/mascot/thinking.png',
      ];
      for (final m in mascots) {
        expect(File(m).existsSync(), isTrue, reason: 'Mascot asset missing: $m');
      }
    });

    test('UI button and reward assets exist on disk', () {
      final uiAssets = [
        'assets/images/ui/btn_back.png',
        'assets/images/ui/btn_home.png',
        'assets/images/ui/btn_next.png',
        'assets/images/ui/btn_play.png',
        'assets/images/ui/btn_replay.png',
        'assets/images/ui/star_gold.png',
        'assets/images/ui/star_silver.png',
        'assets/images/ui/star_bronze.png',
        'assets/images/ui/trophy.png',
        'assets/images/ui/confetti.png',
        'assets/images/ui/sparkles.png',
      ];
      for (final u in uiAssets) {
        expect(File(u).existsSync(), isTrue, reason: 'UI asset missing: $u');
      }
    });

    test('All color item imagePaths exist on disk', () {
      for (final item in colorsData) {
        if (item.imagePath != null) {
          final file = File(item.imagePath!);
          expect(file.existsSync(), isTrue, reason: 'Color asset missing: ${item.imagePath}');
        }
      }
    });

    test('Background music and SFX sound assets exist on disk', () {
      final sounds = [
        'assets/sounds/home_bg_music.wav',
        'assets/sounds/activity_bg_music.mp3',
        'assets/sounds/correct.wav',
        'assets/sounds/wrong.wav',
        'assets/sounds/complete.wav',
        'assets/sounds/pop.wav',
      ];
      for (final s in sounds) {
        expect(File(s).existsSync(), isTrue, reason: 'Sound asset missing: $s');
      }
    });

    test('Original ALL-Assets folder has source bg music files intact', () {
      expect(File('ALL-Assets/home bg music.wav').existsSync(), isTrue);
      expect(File('ALL-Assets/activity bg music.mp3').existsSync(), isTrue);
    });
  });
}
