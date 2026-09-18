import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gigglego/services/storage_service.dart';
import 'package:gigglego/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Sound & Storage Preference Unit Tests', () {
    test('Default audio preferences are all enabled, quiet mode disabled', () async {
      expect(await StorageService.getSoundEnabled(), isTrue);
      expect(await StorageService.getMusicEnabled(), isTrue);
      expect(await StorageService.getEffectsEnabled(), isTrue);
      expect(await StorageService.getQuietMode(), isFalse);
      expect(await StorageService.getReducedMotion(), isFalse);
      expect(await StorageService.getTutorialCompleted(), isFalse);
    });

    test('Audio toggles persist and retrieve correctly', () async {
      await StorageService.setMusicEnabled(false);
      expect(await StorageService.getMusicEnabled(), isFalse);

      await StorageService.setEffectsEnabled(false);
      expect(await StorageService.getEffectsEnabled(), isFalse);

      await StorageService.setQuietMode(true);
      expect(await StorageService.getQuietMode(), isTrue);

      await StorageService.setReducedMotion(true);
      expect(await StorageService.getReducedMotion(), isTrue);

      await StorageService.setTutorialCompleted(true);
      expect(await StorageService.getTutorialCompleted(), isTrue);
    });

    test('Last played category persists correctly', () async {
      expect(await StorageService.getLastPlayedCategory(), isNull);

      await StorageService.setLastPlayedCategory('fruits');
      expect(await StorageService.getLastPlayedCategory(), 'fruits');
    });

    test('Sticker rewards unlock and persist without duplicates', () async {
      expect(await StorageService.getUnlockedStickers(), isEmpty);

      await StorageService.unlockSticker('fruits');
      await StorageService.unlockSticker('fruits');
      await StorageService.unlockSticker('animals');

      final stickers = await StorageService.getUnlockedStickers();
      expect(stickers.length, 2);
      expect(stickers, contains('fruits'));
      expect(stickers, contains('animals'));
    });

    test('resetAllStars clears star progress for all categories including alphabet', () async {
      await StorageService.addStars('alphabet', 8);
      await StorageService.addStars('fruits', 5);
      await StorageService.setTutorialCompleted(true);

      expect(await StorageService.getStars('alphabet'), 8);
      expect(await StorageService.getStars('fruits'), 5);
      expect(await StorageService.getTutorialCompleted(), isTrue);

      await StorageService.resetAllStars();

      expect(await StorageService.getStars('alphabet'), 0);
      expect(await StorageService.getStars('fruits'), 0);
      expect(await StorageService.getTutorialCompleted(), isTrue); // Must NOT reset tutorial
    });

    test('MusicContext enum contains expected contexts', () {
      expect(MusicContext.values, contains(MusicContext.home));
      expect(MusicContext.values, contains(MusicContext.activity));
    });
  });
}
