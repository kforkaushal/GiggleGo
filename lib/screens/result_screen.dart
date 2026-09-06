import 'package:flutter/material.dart';
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

    _entryController.forward().then((_) => _starsController.forward());
  }

  @override
  void dispose() {
    _entryController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  String get _categoryName {
    const map = {
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
      'colors': [Color(0xFFFF5277), Color(0xFFFF7A45)],
      'fruits': [Color(0xFF00B074), Color(0xFF52D68A)],
      'animals': [Color(0xFFFF9500), Color(0xFFFF5E3A)],
      'vehicles': [Color(0xFF0088FF), Color(0xFF00C6FF)],
      'shapes': [Color(0xFF8E24AA), Color(0xFFBA68C8)],
    };
    return map[widget.categoryId] ?? const [Color(0xFFFF9500), Color(0xFFFF5E3A)];
  }

  Color get _accentColor => _gradientColors.first;

  String get _resultEmoji {
    final pct = widget.starsEarned / widget.totalQuestions;
    if (pct == 1.0) return '🏆';
    if (pct >= 0.7) return '🌟';
    if (pct >= 0.5) return '🎉';
    return '💪';
  }

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
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _categoryName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _accentColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Trophy / Mascot Halo
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 8,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      _resultEmoji,
                      style: const TextStyle(fontSize: 84),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title & Subtitle
                  Text(
                    _resultTitle,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.3,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _resultSubtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Star Showcase Card
                  AnimatedBuilder(
                    animation: _starsAnim,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
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
                            // 10 Stars row
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 6,
                              runSpacing: 6,
                              children: List.generate(
                                widget.totalQuestions,
                                (i) {
                                  final isEarned = i < _starsAnim.value;
                                  return AnimatedScale(
                                    scale: isEarned ? 1.05 : 0.9,
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      isEarned ? '⭐' : '☆',
                                      style: TextStyle(
                                        fontSize: 26,
                                        color: isEarned ? const Color(0xFFFFB300) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Score Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFE082)),
                              ),
                              child: Text(
                                '${_starsAnim.value} of ${widget.totalQuestions} Stars Earned!',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Play Again Button (Primary tactile button)
                  _ActionButton(
                    label: '🔄  Play Again',
                    gradient: _gradientColors,
                    shadowColor: _accentColor,
                    isPrimary: true,
                    onTap: _playAgain,
                  ),
                  const SizedBox(height: 12),

                  // Back to Home Button
                  _ActionButton(
                    label: '🏠  Back to Home',
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
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final List<Color>? gradient;
  final Color? color;
  final Color? shadowColor;
  final Color textColor;
  final Color? borderColor;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
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
      onTapDown: (_) => setState(() => _pressed = true),
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
          padding: const EdgeInsets.symmetric(vertical: 17),
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
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: widget.textColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
