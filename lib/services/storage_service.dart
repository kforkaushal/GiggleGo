import 'package:shared_preferences/shared_preferences.dart';

/// Wraps shared_preferences to persist Giggle Go! game data.
/// Stores: `stars_<category>` (int), `sound_enabled` (bool).
/// Phase 1: stub — full implementation in Phase 4.
class StorageService {
  static const String _soundEnabledKey = 'sound_enabled';
  static String starsKey(String category) => 'stars_$category';

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

  /// Get whether sound is enabled. Defaults to true.
  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  /// Set sound enabled/disabled.
  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  /// Reset stars for all categories back to 0.
  static Future<void> resetAllStars() async {
    final prefs = await SharedPreferences.getInstance();
    const categories = ['colors', 'fruits', 'animals', 'vehicles', 'shapes'];
    for (final cat in categories) {
      await prefs.remove(starsKey(cat));
    }
  }
}
