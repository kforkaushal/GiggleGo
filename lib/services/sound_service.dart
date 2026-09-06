import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

/// Wraps audioplayers for game sound effects.
/// Silently fails if sound files are not yet present (Phase 4 will supply them).
class SoundService {
  static AudioPlayer? _player;

  static AudioPlayer get _audioPlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  static Future<void> _play(String fileName) async {
    final enabled = await StorageService.getSoundEnabled();
    if (!enabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (_) {
      // Sound file not yet available — added in Phase 4.
    }
  }

  static Future<void> playCorrect() => _play('correct.mp3');
  static Future<void> playWrong() => _play('wrong.mp3');
  static Future<void> playComplete() => _play('complete.mp3');

  static void disposePlayer() {
    _player?.dispose();
    _player = null;
  }
}
