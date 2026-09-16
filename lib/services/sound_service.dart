import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Manages game sound effects and looping background music.
/// Supports seamless looping with event listeners and hardware-compliant audio formats.
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

      // Bulletproof loop fallback: whenever a track completes, immediately loop it back
      _musicPlayer!.onPlayerComplete.listen((_) async {
        if (_currentMusicTrack != null) {
          try {
            await _musicPlayer?.seek(Duration.zero);
            await _musicPlayer?.resume();
          } catch (e) {
            debugPrint('Music resume loop failed ($e), restarting track...');
            final track = _currentMusicTrack;
            _currentMusicTrack = null;
            if (track == 'home') {
              await playHomeMusic();
            } else if (track == 'activity') {
              await playActivityMusic();
            }
          }
        }
      });

      // Also listen to player state changes to recover from any unexpected stops
      _musicPlayer!.onPlayerStateChanged.listen((state) async {
        if (state == PlayerState.completed && _currentMusicTrack != null) {
          try {
            await _musicPlayer?.seek(Duration.zero);
            await _musicPlayer?.resume();
          } catch (_) {}
        }
      });
    }
    return _musicPlayer!;
  }

  /// Play Home Screen ambient music (loops smoothly and continuously)
  static Future<void> playHomeMusic() async {
    final enabled = await StorageService.getSoundEnabled();
    if (!enabled) return;

    // Only skip if this exact track is already actively playing
    if (_currentMusicTrack == 'home' && _musicPlayer?.state == PlayerState.playing) {
      return;
    }

    try {
      await _music.stop();
      _currentMusicTrack = 'home';
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.32);

      // Prefer optimized standard MP3 (887 KB), fall back to standard 16-bit PCM WAV
      try {
        await _music.play(AssetSource('sounds/home_bg_music.mp3'));
      } catch (e) {
        debugPrint('Playing home_bg_music.mp3 failed ($e), falling back to WAV...');
        await _music.play(AssetSource('sounds/home_bg_music.wav'));
      }
    } catch (e) {
      debugPrint('Error playing home music: $e');
    }
  }

  /// Play Activity / Game Screen energetic music (loops smoothly and continuously)
  static Future<void> playActivityMusic() async {
    final enabled = await StorageService.getSoundEnabled();
    if (!enabled) return;

    // Only skip if this exact track is already actively playing
    if (_currentMusicTrack == 'activity' && _musicPlayer?.state == PlayerState.playing) {
      return;
    }

    try {
      await _music.stop();
      _currentMusicTrack = 'activity';
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.28);
      await _music.play(AssetSource('sounds/activity_bg_music.mp3'));
    } catch (e) {
      debugPrint('Error playing activity music: $e');
    }
  }

  /// Stop all background music immediately
  static Future<void> stopMusic() async {
    try {
      _currentMusicTrack = null;
      await _musicPlayer?.stop();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
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
    } catch (e) {
      debugPrint('Error playing SFX $fileName: $e');
    }
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
