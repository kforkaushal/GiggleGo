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
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
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
      duration: Duration(milliseconds: 400 + widget.starsEarned * 120),
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

  Color get _accentColor {
    const map = {
      'colors': Color(0xFFFF8A65),
      'fruits': Color(0xFF66BB6A),
      'animals': Color(0xFF42A5F5),
      'vehicles': Color(0xFFAB47BC),
      'shapes': Color(0xFFFFCA28),
    };
    return map[widget.categoryId] ?? const Color(0xFFFFAB40);
  }

  String get _resultEmoji {
    final pct = widget.starsEarned / widget.totalQuestions;
    if (pct == 1.0) return '🏆';
    if (pct >= 0.7) return '🌟';
    if (pct >= 0.5) return '😊';
    return '💪';
  }

  String get _resultTitle {
    final pct = widget.starsEarned / widget.totalQuestions;
    if (pct == 1.0) return 'Perfect!';
    if (pct >= 0.7) return 'Well done!';
    if (pct >= 0.5) return 'Good job!';
    return 'Keep going!';
  }

  void _playAgain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
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
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy / result emoji
                  Text(
                    _resultEmoji,
                    style: const TextStyle(fontSize: 90),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    _resultTitle,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: _accentColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    _categoryName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF90A4AE),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Score
                  AnimatedBuilder(
                    animation: _starsAnim,
                    builder: (context, child) {
                      return Column(
                        children: [
                          // Star row
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 4,
                            children: List.generate(
                              widget.totalQuestions,
                              (i) => Text(
                                i < _starsAnim.value ? '⭐' : '☆',
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_starsAnim.value} out of ${widget.totalQuestions}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF37474F),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Buttons
                  _ActionButton(
                    label: '🔄  Play Again',
                    color: _accentColor,
                    onTap: _playAgain,
                  ),
                  const SizedBox(height: 14),
                  _ActionButton(
                    label: '🏠  Home',
                    color: const Color(0xFF78909C),
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
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
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
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
