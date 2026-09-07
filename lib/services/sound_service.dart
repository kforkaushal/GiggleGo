import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

/// Wraps audioplayers for game sound effects.
/// Silently fails if sound files are not yet present (Phase 4 will supply them).
class SoundService {
  static AudioPlayer? _sfxPlayer;
  static AudioPlayer? _musicPlayer;
  static String? _currentMusicTrack;

  static AudioPlayer get _sfx {
    if (_sfxPlayer == null) {
      _sfxPlayer = AudioPlayer();
      _sfxPlayer!.setPlayerMode(PlayerMode.lowLatency);
    }
    return _sfxPlayer!;
  }

  static AudioPlayer get _music {
    if (_musicPlayer == null) {
      _musicPlayer = AudioPlayer();
      _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      _musicPlayer!.setVolume(0.32);
    }
    return _musicPlayer!;
  }

  /// Play Home Screen ambient music (loops smoothly)
  static Future<void> playHomeMusic() async {
    final enabled = await StorageService.getSoundEnabled();
    if (!enabled) return;
    if (_currentMusicTrack == 'home') return;
    try {
      await _music.stop();
      _currentMusicTrack = 'home';
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.32);
      await _music.play(AssetSource('sounds/home_bg_music.wav'));
    } catch (_) {}
  }

  /// Play Activity / Game Screen energetic music (loops smoothly)
  static Future<void> playActivityMusic() async {
    final enabled = await StorageService.getSoundEnabled();
    if (!enabled) return;
    if (_currentMusicTrack == 'activity') return;
    try {
      await _music.stop();
      _currentMusicTrack = 'activity';
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.28);
      await _music.play(AssetSource('sounds/activity_bg_music.mp3'));
    } catch (_) {}
  }

  /// Stop all background music immediately
  static Future<void> stopMusic() async {
    try {
      _currentMusicTrack = null;
      await _musicPlayer?.stop();
    } catch (_) {}
  }

  /// Handle sound toggle
  static Future<void> onSoundToggled(bool enabled, {String currentContext = 'home'}) async {
    if (!enabled) {
      await stopMusic();
    } else {
      if (currentContext == 'home') {
        await playHomeMusic();
      } else {
        await playActivityMusic();
      }
    }
  }

  static Future<void> _play(String fileName) async {
    final enabled = await StorageService.getSoundEnabled();
    if (!enabled) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('sounds/$fileName'));
    } catch (_) {}
  }

  static Future<void> playCorrect() => _play('correct.wav');
  static Future<void> playWrong() => _play('wrong.wav');
  static Future<void> playComplete() => _play('complete.wav');
  static Future<void> playPop() => _play('pop.wav');

  static void disposePlayer() {
    _sfxPlayer?.dispose();
    _sfxPlayer = null;
    _musicPlayer?.dispose();
    _musicPlayer = null;
    _currentMusicTrack = null;
  }
}
