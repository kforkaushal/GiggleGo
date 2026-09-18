import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../widgets/smooth_mascot.dart';
import 'home_screen.dart';

/// Cheerful, toddler-first Welcome Screen.
/// Features a colorful cute background with floating clouds and stars,
/// friendly waving mascot companion, and a giant animated "PLAY!" button.
/// Tapping PLAY smoothly transitions to HomeScreen, immediately launching
/// the toddler demonstration tutorial if it is the child's first time.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _sunburstController;

  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the big PLAY button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Floating animation for mascot & clouds
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Continuous slow rotation for ambient background shine
    _sunburstController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _initAudioAndPreferences();
  }

  Future<void> _initAudioAndPreferences() async {
    final sound = await StorageService.getSoundEnabled();
    if (mounted) {
      setState(() => _soundEnabled = sound);
      if (sound) {
        SoundService.playHomeMusic();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _sunburstController.dispose();
    super.dispose();
  }

  Future<void> _onPlayTap() async {
    SoundService.playPop();
    SoundService.playTap();

    final tutorialCompleted = await StorageService.getTutorialCompleted();

    if (!mounted) return;

    // Navigate to HomeScreen; if tutorial is not completed, start tutorial from play!
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
          forceTutorial: !tutorialCompleted,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _toggleSound() async {
    final next = !_soundEnabled;
    await StorageService.setSoundEnabled(next);
    if (mounted) {
      setState(() => _soundEnabled = next);
    }
    await SoundService.onSoundToggled(next, currentContext: 'home');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 600;
    final isCompact = size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Cute Pastel Sky Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F7FA), // Soft cyan sky
                  Color(0xFFFFF9C4), // Gentle sunshine yellow
                  Color(0xFFFFE0B2), // Warm soft peach
                  Color(0xFFF3E5F5), // Cheerful pastel lavender at bottom
                ],
                stops: [0.0, 0.35, 0.70, 1.0],
              ),
            ),
          ),

          // 2. Soft Ambient Background Illustration Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/backgrounds/bg_2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 3. Ambient Rotating Sunburst Glow
          Center(
            child: RotationTransition(
              turns: _sunburstController,
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  'assets/images/ui/shine.png',
                  width: math.min(size.width * 1.1, 480),
                  height: math.min(size.width * 1.1, 480),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // 4. Floating Decorative Cute Clouds & Stars
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Top left cute star
                  Positioned(
                    top: size.height * 0.11 + _floatAnimation.value * 0.7,
                    left: 24,
                    child: Image.asset(
                      'assets/images/ui/star_gold.png',
                      width: isCompact ? 30 : 38,
                      height: isCompact ? 30 : 38,
                    ),
                  ),
                  // Top right floating star
                  Positioned(
                    top: size.height * 0.14 - _floatAnimation.value * 0.8,
                    right: 28,
                    child: Image.asset(
                      'assets/images/ui/star_gold.png',
                      width: isCompact ? 26 : 34,
                      height: isCompact ? 26 : 34,
                    ),
                  ),
                  // Mid right sparkles
                  Positioned(
                    top: size.height * 0.38 + _floatAnimation.value * 0.5,
                    right: 20,
                    child: Opacity(
                      opacity: 0.85,
                      child: Image.asset(
                        'assets/images/ui/sparkles.png',
                        width: isCompact ? 28 : 36,
                        height: isCompact ? 28 : 36,
                      ),
                    ),
                  ),
                  // Mid left sparkles
                  Positioned(
                    top: size.height * 0.45 - _floatAnimation.value * 0.6,
                    left: 18,
                    child: Opacity(
                      opacity: 0.85,
                      child: Image.asset(
                        'assets/images/ui/sparkles.png',
                        width: isCompact ? 24 : 32,
                        height: isCompact ? 24 : 32,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 5. Sound toggle at top-right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: Semantics(
                  button: true,
                  label: _soundEnabled ? 'Mute sound' : 'Turn sound on',
                  child: GestureDetector(
                    onTap: _toggleSound,
                    child: Container(
                      width: isCompact ? 46 : 52,
                      height: isCompact ? 46 : 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFFFD54F),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _soundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: _soundEnabled
                            ? const Color(0xFFFF8F00)
                            : const Color(0xFF9E9E9E),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 6. Main Interactive Content (Scrollable to guarantee ZERO overflow on short screens)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Logo with clean soft shadow
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 320 : (isCompact ? 210 : 250),
                      ),
                      child: Image.asset(
                        'assets/images/trans-logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: isCompact ? 8 : 14),

                    // Cute Speech Bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.roundedPill,
                        border: Border.all(
                          color: const Color(0xFFFFB74D),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9800).withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '🌟 Let\'s Learn & Play! 🎈',
                          style: TextStyle(
                            fontFamily: AppTypography.fontDisplay,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE65100),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isCompact ? 12 : 18),

                    // Animated Cheerful Mascot with floating motion
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: SmoothMascot(
                          action: 'happy',
                          size: isTablet ? 150 : (isCompact ? 110 : 130),
                        ),
                      ),
                    ),

                    SizedBox(height: isCompact ? 20 : 28),

                    // Giant Toddler PLAY Button with Bouncing Scale Animation
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Semantics(
                        button: true,
                        label: 'Start playing games',
                        child: GestureDetector(
                          onTap: _onPlayTap,
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: isTablet ? 260 : (isCompact ? 200 : 230),
                              maxWidth: 320,
                              minHeight: isCompact ? 70 : 78,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF9100), // Vibrant Amber Orange
                                  Color(0xFFFF3D00), // Energetic Coral Red
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(44),
                              border: Border.all(
                                color: Colors.white,
                                width: 3.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF3D00).withValues(alpha: 0.42),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                const BoxShadow(
                                  color: Colors.white70,
                                  blurRadius: 0,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Play Icon Disk
                                  Container(
                                    width: isCompact ? 42 : 48,
                                    height: isCompact ? 42 : 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/ui/btn_play.png',
                                        width: isCompact ? 26 : 32,
                                        height: isCompact ? 26 : 32,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Bold Friendly PLAY! Text
                                  Text(
                                    'PLAY!',
                                    style: TextStyle(
                                      fontFamily: AppTypography.fontDisplay,
                                      fontSize: isCompact ? 28 : 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x66000000),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Star Accent
                                  Image.asset(
                                    'assets/images/ui/star_gold.png',
                                    width: isCompact ? 24 : 28,
                                    height: isCompact ? 24 : 28,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isCompact ? 14 : 20),

                    // Toddler Friendly Sub-caption
                    const Text(
                      'Tap to explore fun games!',
                      style: TextStyle(
                        fontFamily: AppTypography.fontBody,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
