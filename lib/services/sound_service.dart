import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

/// Wraps audioplayers for game sound effects.
/// Silently fails if sound files are not yet present (Phase 4 will supply them).
class SoundService {
  static AudioPlayer? _player;

  static AudioPlayer get _audioPlayer {
    if (_player == null) {
      _player = AudioPlayer();
      _player!.setPlayerMode(PlayerMode.lowLatency);
    }
    return _player!;
  }

  static Future<void> _play(String fileName) async {
    final enabled = await StorageService.getSoundEnabled();
    if (!enabled) return;
    try {
      // audioplayers AssetSource assumes assets/ folder prefix by default
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (_) {
      // Graceful fallback if audio is not supported on current device
    }
  }

  static Future<void> playCorrect() => _play('correct.wav');
  static Future<void> playWrong() => _play('wrong.wav');
  static Future<void> playComplete() => _play('complete.wav');
  static Future<void> playPop() => _play('pop.wav');

  static void disposePlayer() {
    _player?.dispose();
    _player = null;
  }
}
