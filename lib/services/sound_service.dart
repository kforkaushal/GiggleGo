import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'storage_service.dart';

/// Supported background music contexts.
enum MusicContext { home, activity }

/// Manages game sound effects and looping background music.
/// Provides resilient self-healing audio recovery across app lifecycle events,
/// route changes, audio interruptions, and separate music/effects settings.
class SoundService {
  static AudioPlayer? _sfxPlayer;
  static AudioPlayer? _musicPlayer;

  static MusicContext? _desiredContext;
  static String? _currentSource;
  static bool _appIsResumed = true;
  static bool _musicError = false;

  /// Internal serialization lock to prevent overlapping playback during rapid navigation.
  static Future<void> _musicLock = Future.value();

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

      // Auto-recover if OS pauses or interrupts player during foreground notifications/calls
      _musicPlayer!.onPlayerStateChanged.listen((state) async {
        if (state == PlayerState.paused && _appIsResumed && _desiredContext != null) {
          final masterEnabled = await StorageService.getSoundEnabled();
          final musicEnabled = await StorageService.getMusicEnabled();
          final quietMode = await StorageService.getQuietMode();
          if (masterEnabled && musicEnabled && !quietMode) {
            try {
              await _musicPlayer?.resume();
            } catch (e) {
              debugPrint('SoundService: error auto-resuming from paused state: $e');
            }
          }
        }
      });
    }
    return _musicPlayer!;
  }

  // ─── Lifecycle Recovery ───────────────────────────────────────────────────

  /// Called from the root WidgetsBindingObserver in main.dart.
  static void onAppLifecycleChanged(AppLifecycleState state) {
    debugPrint('SoundService: app lifecycle state changed to $state');
    switch (state) {
      case AppLifecycleState.resumed:
        _appIsResumed = true;
        resumeDesiredMusic();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _appIsResumed = false;
        _pauseMusic();
        break;
      case AppLifecycleState.detached:
        _appIsResumed = false;
        disposePlayer();
        break;
    }
  }

  static Future<void> _pauseMusic() async {
    try {
      await _musicPlayer?.pause();
    } catch (e) {
      debugPrint('SoundService: error pausing music on lifecycle change: $e');
    }
  }

  /// Attempts to resume the desired background track if conditions are met.
  static Future<void> resumeDesiredMusic() async {
    if (!_appIsResumed || _desiredContext == null) return;

    final masterEnabled = await StorageService.getSoundEnabled();
    final musicEnabled = await StorageService.getMusicEnabled();
    final quietMode = await StorageService.getQuietMode();

    if (!masterEnabled || !musicEnabled || quietMode) {
      await stopMusic();
      return;
    }

    // Retry or continue desired track
    await setMusicContext(_desiredContext!);
  }

  // ─── Music Playback ───────────────────────────────────────────────────────

  /// Serialized navigation contract to set background music context.
  static Future<void> setMusicContext(MusicContext context) async {
    _desiredContext = context;

    // Chain the task to guarantee serialized execution
    final completer = Completer<void>();
    _musicLock = _musicLock.then((_) async {
      try {
        await _executeSetMusicContext(context);
      } catch (e) {
        debugPrint('SoundService: setMusicContext error: $e');
      } finally {
        completer.complete();
      }
    });

    return completer.future;
  }

  static Future<void> _executeSetMusicContext(MusicContext context) async {
    if (!_appIsResumed) return;

    final masterEnabled = await StorageService.getSoundEnabled();
    final musicEnabled = await StorageService.getMusicEnabled();
    final quietMode = await StorageService.getQuietMode();

    if (!masterEnabled || !musicEnabled || quietMode) {
      await _musicPlayer?.stop();
      _currentSource = null;
      return;
    }

    final source = context == MusicContext.home
        ? 'sounds/home_bg_music.mp3'
        : 'sounds/activity_bg_music.mp3';

    // If already playing the desired track, do not restart
    if (_currentSource == source &&
        _musicPlayer?.state == PlayerState.playing &&
        !_musicError) {
      return;
    }

    try {
      await _music.stop();
      _currentSource = source;
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(context == MusicContext.home ? 0.32 : 0.28);
      await _music.play(AssetSource(source));
      _musicError = false;
    } catch (e) {
      debugPrint('SoundService: error playing $source: $e');
      _musicError = true;

      // Fallback for home music if mp3 fails
      if (context == MusicContext.home) {
        try {
          await _music.play(AssetSource('sounds/home_bg_music.wav'));
          _musicError = false;
        } catch (e2) {
          debugPrint('SoundService: fallback home WAV failed: $e2');
        }
      }
    }
  }

  /// Convenience method: play Home music.
  static Future<void> playHomeMusic() => setMusicContext(MusicContext.home);

  /// Convenience method: play Activity music.
  static Future<void> playActivityMusic() => setMusicContext(MusicContext.activity);

  /// Stops current music without losing desired context.
  static Future<void> stopMusic() async {
    try {
      _currentSource = null;
      await _musicPlayer?.stop();
    } catch (e) {
      debugPrint('SoundService: error stopping music: $e');
    }
  }

  /// Master sound toggle handler.
  static Future<void> onSoundToggled(bool enabled, {String currentContext = 'home'}) async {
    if (!enabled) {
      await stopMusic();
    } else {
      _musicError = false;
      final ctx = currentContext == 'activity' ? MusicContext.activity : MusicContext.home;
      await setMusicContext(ctx);
    }
  }

  // ─── Sound Effects ────────────────────────────────────────────────────────

  static Future<void> _playSfx(String fileName) async {
    final masterEnabled = await StorageService.getSoundEnabled();
    final effectsEnabled = await StorageService.getEffectsEnabled();

    if (!masterEnabled || !effectsEnabled) return;

    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint('SoundService: error playing SFX $fileName: $e');
    }
  }

  static Future<void> playCorrect() => _playSfx('correct.wav');
  static Future<void> playWrong() => _playSfx('wrong.wav');
  static Future<void> playComplete() => _playSfx('complete.wav');
  static Future<void> playPop() => _playSfx('pop.wav');
  static Future<void> playTap() => _playSfx('pop.wav');

  // ─── Disposal ─────────────────────────────────────────────────────────────

  static void disposePlayer() {
    _sfxPlayer?.dispose();
    _sfxPlayer = null;
    _musicPlayer?.dispose();
    _musicPlayer = null;
    _currentSource = null;
  }
}
