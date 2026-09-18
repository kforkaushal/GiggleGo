import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';

enum TutorialStep {
  step1SelectCategory,
  step2ShowQuestion,
  step3TapTarget,
  step4TapNext,
}

/// A toddler-friendly 4-step demonstration tutorial overlay.
/// Guides 2-year-olds through visual demonstration, avoiding heavy text.
/// Skippable by parents, respects reduced-motion settings, and persists completion.
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onCompleted;
  final VoidCallback onSkip;

  const TutorialOverlay({
    super.key,
    required this.onCompleted,
    required this.onSkip,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  TutorialStep _currentStep = TutorialStep.step1SelectCategory;
  bool _reducedMotion = false;
  bool _isFinishing = false;
  bool _isSkipping = false;
  Timer? _autoAdvanceTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _loadMotionSettings();
  }

  Future<void> _loadMotionSettings() async {
    final rm = await StorageService.getReducedMotion();
    if (mounted) {
      setState(() => _reducedMotion = rm);
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _finishTutorial() {
    if (_isFinishing || _isSkipping) return;
    _isFinishing = true;
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
    StorageService.setTutorialCompleted(true);
    SoundService.playComplete();
    widget.onCompleted();
  }

  void _skipTutorial() {
    if (_isFinishing || _isSkipping) return;
    _isSkipping = true;
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
    StorageService.setTutorialCompleted(true);
    widget.onSkip();
  }

  void _onCardTapped() {
    SoundService.playPop();
    setState(() {
      _currentStep = TutorialStep.step2ShowQuestion;
    });

    // Briefly show the question, then guide to the target
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _currentStep == TutorialStep.step2ShowQuestion) {
        setState(() {
          _currentStep = TutorialStep.step3TapTarget;
        });
      }
    });
  }

  void _onTargetTapped() {
    SoundService.playCorrect();
    setState(() {
      _currentStep = TutorialStep.step4TapNext;
    });
    _startAutoAdvanceTimer();
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    // Automatically advance after 2.5s celebration so toddlers never get stuck
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _currentStep == TutorialStep.step4TapNext) {
        _finishTutorial();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dim backdrop - tap anywhere on step 4 advances
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _currentStep == TutorialStep.step4TapNext ? _finishTutorial : null,
              child: Container(
                color: AppColors.tutorialBackdrop,
              ),
            ),
          ),

          // Top parent-facing "Skip" button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: TextButton.icon(
                  onPressed: _skipTutorial,
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                  label: const Text(
                    'Skip Tutorial',
                    style: TextStyle(
                      fontFamily: AppTypography.fontBody,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ),
            ),
          ),

          // Central demonstration content based on step
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildStepContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case TutorialStep.step1SelectCategory:
        return _buildStep1();
      case TutorialStep.step2ShowQuestion:
      case TutorialStep.step3TapTarget:
        return _buildStep2And3();
      case TutorialStep.step4TapNext:
        return _buildStep4();
    }
  }

  // ─── Step 1: Tap Category ───────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mascot pointing down
        AnimatedBuilder(
          animation: _bounceAnim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _reducedMotion ? 0 : _bounceAnim.value),
              child: child,
            );
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onCardTapped,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/mascot/pointing.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.roundedPill,
                    boxShadow: AppShadows.card,
                  ),
                  child: const Text(
                    'Tap Colors! 🎨',
                    style: TextStyle(
                      fontFamily: AppTypography.fontDisplay,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.colors,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Glowing, highlighted Colors category card
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            final scale = _reducedMotion ? 1.0 : _pulseAnim.value;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _onCardTapped,
            child: Container(
              width: 170,
              height: 190,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.roundedXl,
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tutorialHighlight.withValues(alpha: 0.6),
                    blurRadius: 28,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/categories/colors.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Colors',
                    style: TextStyle(
                      fontFamily: AppTypography.fontDisplay,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 2 & 3: Find Target & Demonstrate Tap ─────────────────────────────

  Widget _buildStep2And3() {
    final isDemonstrating = _currentStep == TutorialStep.step3TapTarget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Question prompt card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.roundedLg,
            boxShadow: AppShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/mascot/happy.png',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Find red! 🔴',
                style: TextStyle(
                  fontFamily: AppTypography.fontDisplay,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.colors,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // 2 Big Choice Cards: Red (Target) and Blue
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Target Card: Red (with pulse / hand prompt)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) {
                final scale = (!isDemonstrating || _reducedMotion) ? 1.0 : _pulseAnim.value;
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: _onTargetTapped,
                    child: Container(
                      width: 140,
                      height: 155,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(
                          color: isDemonstrating ? AppColors.colors : AppColors.borderLight,
                          width: isDemonstrating ? 3.5 : 2.0,
                        ),
                        boxShadow: [
                          if (isDemonstrating)
                            BoxShadow(
                              color: AppColors.colors.withValues(alpha: 0.45),
                              blurRadius: 22,
                              spreadRadius: 4,
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/items/colors/red.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Red',
                            style: TextStyle(
                              fontFamily: AppTypography.fontDisplay,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.colors,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Animated finger pointing indicator on step 3
                  if (isDemonstrating)
                    Positioned(
                      bottom: -22,
                      right: -10,
                      child: AnimatedBuilder(
                        animation: _bounceAnim,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _reducedMotion ? 0 : _bounceAnim.value),
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 8),
                            ],
                          ),
                          child: const Icon(
                            Icons.touch_app_rounded,
                            size: 32,
                            color: AppColors.colors,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // Distractor Card: Blue
            Opacity(
              opacity: 0.65,
              child: Container(
                width: 140,
                height: 155,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(color: AppColors.borderLight, width: 2.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/items/colors/blue.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Blue',
                      style: TextStyle(
                        fontFamily: AppTypography.fontDisplay,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.vehicles,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Step 4: Teach Continuation with Large Next Action ─────────────────────

  Widget _buildStep4() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _finishTutorial,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mascot Celebrating
          Image.asset(
            'assets/images/mascot/celebrate.png',
            width: 96,
            height: 96,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Yay! You did it! 🎉',
            style: TextStyle(
              fontFamily: AppTypography.fontDisplay,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Large Bouncing "Next" Button
          AnimatedBuilder(
            animation: _bounceAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _reducedMotion ? 0 : _bounceAnim.value),
                child: child,
              );
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _finishTutorial,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B074), Color(0xFF52D68A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.roundedPill,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B074).withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: AppTypography.fontDisplay,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Image.asset(
                      'assets/images/ui/btn_next.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
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
