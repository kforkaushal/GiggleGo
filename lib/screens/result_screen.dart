import 'package:flutter/material.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/smooth_mascot.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';

class ResultScreen extends StatefulWidget {
  final String categoryId;
  final int starsEarned;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.categoryId,
    required this.starsEarned,
    required this.totalQuestions,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  late AnimationController _starsController;
  late Animation<int> _starsAnim;

  late AnimationController _shineController;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _starsController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.starsEarned * 110),
    );
    _starsAnim = IntTween(begin: 0, end: widget.starsEarned)
        .animate(CurvedAnimation(parent: _starsController, curve: Curves.easeOut));

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _entryController.forward().then((_) => _starsController.forward());
  }

  @override
  void dispose() {
    _entryController.dispose();
    _starsController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  String get _categoryName {
    const map = {
      'alphabet': 'Alphabet',
      'colors': 'Colors',
      'fruits': 'Fruits',
      'animals': 'Animals',
      'vehicles': 'Vehicles',
      'shapes': 'Shapes',
    };
    return map[widget.categoryId] ?? 'Game';
  }

  List<Color> get _gradientColors {
    const map = {
      'alphabet': [Color(0xFF9C27B0), Color(0xFFBA68C8)],
      'colors': [Color(0xFFFF5277), Color(0xFFFF7A45)],
      'fruits': [Color(0xFF00B074), Color(0xFF52D68A)],
      'animals': [Color(0xFFFF9500), Color(0xFFFF5E3A)],
      'vehicles': [Color(0xFF0088FF), Color(0xFF00C6FF)],
      'shapes': [Color(0xFF5E35B1), Color(0xFF7E57C2)],
    };
    return map[widget.categoryId] ?? const [Color(0xFFFF9500), Color(0xFFFF5E3A)];
  }

  Color get _accentColor => _gradientColors.first;

  String get _resultTitle {
    final pct = widget.starsEarned / widget.totalQuestions;
    if (pct == 1.0) return 'Perfect Score!';
    if (pct >= 0.7) return 'Great Job!';
    if (pct >= 0.5) return 'Good Effort!';
    return 'Keep Practicing!';
  }

  String get _resultSubtitle {
    final pct = widget.starsEarned / widget.totalQuestions;
    if (pct == 1.0) return 'You are a master of $_categoryName!';
    if (pct >= 0.7) return 'You learned so many $_categoryName today!';
    if (pct >= 0.5) return 'You are getting better and better!';
    return 'Every play makes you smarter!';
  }

  String get _nextCategoryId {
    const cats = ['alphabet', 'colors', 'fruits', 'animals', 'vehicles', 'shapes'];
    final idx = cats.indexOf(widget.categoryId);
    if (idx >= 0 && idx < cats.length - 1) {
      return cats[idx + 1];
    }
    return cats.first;
  }

  void _playNextCategory() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(categoryId: _nextCategoryId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _playAgain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(categoryId: widget.categoryId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _goHome() {
    SoundService.playHomeMusic();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.starsEarned / widget.totalQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen cartoon celebration backdrop
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/images/backgrounds/bg_4.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: ConfettiBurst(
              isPlaying: true,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Celebration Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _categoryName.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'AnjaEliane',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _accentColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Trophy + Mascot Centerpiece Row (Winner Stage)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Jumping / Celebrating Animated Cat Mascot with 60fps physics
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SmoothMascot(
                                  key: ValueKey('result_mascot_${pct >= 0.5 ? "celebrate" : "happy"}'),
                                  action: pct >= 0.5 ? 'celebrate' : 'happy',
                                  size: 108,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: 70,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Golden Trophy or Star Halo on Podium
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Rotating sunburst shine effect
                                    RotationTransition(
                                      turns: _shineController,
                                      child: Opacity(
                                        opacity: 0.7,
                                        child: Image.asset(
                                          'assets/images/ui/shine.png',
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    // Halo circular badge
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _accentColor.withValues(alpha: 0.25),
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _accentColor.withValues(alpha: 0.25),
                                            blurRadius: 32,
                                            spreadRadius: 8,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        pct >= 0.8
                                            ? 'assets/images/ui/trophy.png'
                                            : pct >= 0.5
                                                ? 'assets/images/ui/star_gold.png'
                                                : 'assets/images/ui/star_bronze.png',
                                        height: 72,
                                        width: 72,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    // Twinkling magic sparkles accent
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Image.asset(
                                        'assets/images/ui/sparkles.png',
                                        width: 34,
                                        height: 34,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: 80,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Title & Subtitle
                        Text(
                          _resultTitle,
                          style: const TextStyle(
                            fontFamily: 'AnjaEliane',
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.4,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _resultSubtitle,
                          style: TextStyle(
                            fontFamily: 'AlteHaasGrotesk',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),

                        // Star Showcase Card
                        AnimatedBuilder(
                          animation: _starsAnim,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // 10 Stars row with real gold and silver stars
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(
                                      widget.totalQuestions,
                                      (i) {
                                        final isEarned = i < _starsAnim.value;
                                        return AnimatedScale(
                                          scale: isEarned ? 1.08 : 0.9,
                                          duration: const Duration(milliseconds: 200),
                                          child: Image.asset(
                                            isEarned
                                                ? 'assets/images/ui/star_gold.png'
                                                : 'assets/images/ui/star_silver.png',
                                            width: 28,
                                            height: 28,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Score Pill with Gold Star Icon
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFFFE082)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/ui/star_gold.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_starsAnim.value} of ${widget.totalQuestions} Stars Earned!',
                                          style: const TextStyle(
                                            fontFamily: 'AnjaEliane',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Action Buttons: Next Category (if earned >= 60%) or Play Again
                        if (pct >= 0.6) ...[
                          _ActionButton(
                            label: 'Next Category',
                            iconAsset: 'assets/images/ui/btn_next.png',
                            gradient: const [Color(0xFF00B074), Color(0xFF52D68A)],
                            shadowColor: const Color(0xFF00B074),
                            isPrimary: true,
                            onTap: _playNextCategory,
                          ),
                          const SizedBox(height: 10),
                          _ActionButton(
                            label: 'Play Again',
                            iconAsset: 'assets/images/ui/btn_replay.png',
                            color: Colors.white,
                            textColor: const Color(0xFF334155),
                            borderColor: const Color(0xFFCBD5E1),
                            onTap: _playAgain,
                          ),
                        ] else ...[
                          _ActionButton(
                            label: 'Play Again',
                            iconAsset: 'assets/images/ui/btn_replay.png',
                            gradient: _gradientColors,
                            shadowColor: _accentColor,
                            isPrimary: true,
                            onTap: _playAgain,
                          ),
                        ],
                        const SizedBox(height: 10),

                        // Back to Home Button (with home icon)
                        _ActionButton(
                          label: 'Back to Home',
                          iconAsset: 'assets/images/ui/btn_home.png',
                          color: Colors.white,
                          textColor: const Color(0xFF475569),
                          borderColor: const Color(0xFFE2E8F0),
                          onTap: _goHome,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final String? iconAsset;
  final List<Color>? gradient;
  final Color? color;
  final Color? shadowColor;
  final Color textColor;
  final Color? borderColor;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    this.iconAsset,
    this.gradient,
    this.color,
    this.shadowColor,
    this.textColor = Colors.white,
    this.borderColor,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        SoundService.playPop();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: widget.color,
            gradient: widget.gradient != null
                ? LinearGradient(
                    colors: widget.gradient!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(22),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              if (widget.isPrimary && widget.shadowColor != null)
                BoxShadow(
                  color: widget.shadowColor!.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.iconAsset != null) ...[
                Image.asset(
                  widget.iconAsset!,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AnjaEliane',
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: widget.textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
