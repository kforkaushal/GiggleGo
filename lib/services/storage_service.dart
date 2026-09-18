import 'package:shared_preferences/shared_preferences.dart';
import '../data/category_meta.dart' as meta;

/// Wraps shared_preferences to persist Giggle Go! game data and preferences.
/// Offline-first, local-only storage for stars, audio preferences, accessibility, and onboarding.
class StorageService {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _effectsEnabledKey = 'effects_enabled';
  static const String _quietModeKey = 'quiet_mode';
  static const String _reducedMotionKey = 'reduced_motion';
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _lastPlayedCategoryKey = 'last_played_category';
  static const String _unlockedStickersKey = 'unlocked_stickers';

  /// All category IDs derived from canonical CategoryMeta (guaranteed to include 'alphabet').
  static List<String> get allCategories => meta.allCategories.map((c) => c.id).toList();

  static String starsKey(String category) => 'stars_$category';

  // ─── Stars & Progress ───────────────────────────────────────────────────────

  /// Load total stars for a given category. Returns 0 if not set.
  static Future<int> getStars(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(starsKey(category)) ?? 0;
  }

  /// Add [count] stars to the persisted total for [category].
  static Future<void> addStars(String category, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(starsKey(category)) ?? 0;
    await prefs.setInt(starsKey(category), current + count);
  }

  /// Returns total stars earned across all categories.
  static Future<int> getTotalStars() async {
    int total = 0;
    for (final cat in allCategories) {
      total += await getStars(cat);
    }
    return total;
  }

  /// Returns count of categories that have at least 1 star.
  static Future<int> getCategoriesTriedCount() async {
    int count = 0;
    for (final cat in allCategories) {
      if (await getStars(cat) > 0) {
        count++;
      }
    }
    return count;
  }

  /// Reset stars for all categories back to 0. Does NOT reset tutorial completion.
  static Future<void> resetAllStars() async {
    final prefs = await SharedPreferences.getInstance();
    for (final cat in allCategories) {
      await prefs.remove(starsKey(cat));
    }
  }

  // ─── Audio Preferences ─────────────────────────────────────────────────────

  /// Get whether master sound is enabled. Defaults to true.
  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  /// Set master sound enabled/disabled.
  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  /// Get whether background music is enabled. Defaults to true.
  static Future<bool> getMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicEnabledKey) ?? true;
  }

  /// Set background music enabled/disabled.
  static Future<void> setMusicEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, value);
  }

  /// Get whether sound effects are enabled. Defaults to true.
  static Future<bool> getEffectsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_effectsEnabledKey) ?? true;
  }

  /// Set sound effects enabled/disabled.
  static Future<void> setEffectsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_effectsEnabledKey, value);
  }

  /// Get whether quiet mode is active (disables background music, preserves feedback SFX).
  static Future<bool> getQuietMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_quietModeKey) ?? false;
  }

  /// Set quiet mode active/inactive.
  static Future<void> setQuietMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quietModeKey, value);
  }

  // ─── Accessibility & Motion ────────────────────────────────────────────────

  /// Get whether reduced motion mode is active (gentle fades/pulses instead of bouncy movement).
  static Future<bool> getReducedMotion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reducedMotionKey) ?? false;
  }

  /// Set reduced motion mode active/inactive.
  static Future<void> setReducedMotion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reducedMotionKey, value);
  }

  // ─── Onboarding & Tutorial ─────────────────────────────────────────────────

  /// Get whether the child has completed the first-use tutorial. Defaults to false.
  static Future<bool> getTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  /// Mark the tutorial as completed.
  static Future<void> setTutorialCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, value);
  }

  /// Alias for getTutorialCompleted per V2 specification.
  static Future<bool> getHasSeenTutorial() => getTutorialCompleted();

  /// Alias for setTutorialCompleted per V2 specification.
  static Future<void> setHasSeenTutorial(bool value) => setTutorialCompleted(value);

  // ─── Recent Play Shortcut ──────────────────────────────────────────────────

  /// Get the ID of the most recently played category (e.g. 'colors').
  static Future<String?> getLastPlayedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPlayedCategoryKey);
  }

  /// Persist the most recently played category ID.
  static Future<void> setLastPlayedCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedCategoryKey, categoryId);
  }

  // ─── Sticker Shelf Rewards ─────────────────────────────────────────────────

  /// Get unlocked sticker IDs.
  static Future<List<String>> getUnlockedStickers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unlockedStickersKey) ?? [];
  }

  /// Unlock a new sticker ID if not already unlocked.
  static Future<void> unlockSticker(String stickerId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_unlockedStickersKey) ?? [];
    if (!list.contains(stickerId)) {
      list.add(stickerId);
      await prefs.setStringList(_unlockedStickersKey, list);
    }
  }
}
