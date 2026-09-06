import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../data/colors_data.dart';
import '../data/fruits_data.dart';
import '../data/animals_data.dart';
import '../data/vehicles_data.dart';
import '../data/shapes_data.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../widgets/star_counter.dart';
import '../widgets/answer_card.dart';
import '../widgets/game_graphic.dart';
import '../widgets/confetti_overlay.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final String categoryId;
  const GameScreen({super.key, required this.categoryId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<GameItem> _allItems;
  late List<GameItem> _questions;
  int _currentIndex = 0;
  late List<GameItem> _choices;

  int _sessionStars = 0;
  String? _feedbackType; // null | 'correct' | 'wrong'
  String _praiseText = '';
  int? _tappedIndex;
  bool _isAdvancing = false;
  int _lastPraiseIndex = -1;
  bool _soundEnabled = true;

  static const _praisePhrases = [
    'Yay! 🎉',
    'Great Job! 🌟',
    'Awesome! 🎊',
    'Super Star! ⭐',
    'You Did It! 🎈',
  ];

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  late AnimationController _correctController;
  late Animation<double> _correctScale;
  late AnimationController _idleController;
  late Animation<double> _idleScale;

  @override
  void initState() {
    super.initState();
    _allItems = _dataFor(widget.categoryId);
    _setupQuestions();
    _buildChoices();
    _loadSoundState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeController);

    _correctController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _correctScale = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _correctController, curve: Curves.elasticOut),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _idleScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );
  }

  Future<void> _loadSoundState() async {
    final sound = await StorageService.getSoundEnabled();
    if (mounted) setState(() => _soundEnabled = sound);
  }

  Future<void> _toggleSound() async {
    final next = !_soundEnabled;
    await StorageService.setSoundEnabled(next);
    if (mounted) {
      setState(() => _soundEnabled = next);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _correctController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  List<GameItem> _dataFor(String id) {
    switch (id) {
      case 'colors': return colorsData;
      case 'fruits': return fruitsData;
      case 'animals': return animalsData;
      case 'vehicles': return vehiclesData;
      case 'shapes': return shapesData;
      default: return colorsData;
    }
  }

  void _setupQuestions() {
    final shuffled = List<GameItem>.from(_allItems)..shuffle();
    _questions = shuffled.take(min(10, shuffled.length)).toList();
  }

  void _buildChoices() {
    final target = _questions[_currentIndex];
    final pool = List<GameItem>.from(_allItems)..remove(target);
    pool.shuffle();
    _choices = [target, pool[0], pool[1]]..shuffle();
  }

  // ─── Theming helpers ──────────────────────────────────────────────────────

  String _categoryLabel() {
    const map = {
      'colors': 'Colors',
      'fruits': 'Fruits',
      'animals': 'Animals',
      'vehicles': 'Vehicles',
      'shapes': 'Shapes',
    };
    return map[widget.categoryId] ?? 'Game';
  }

  Color _categoryColor() {
    const map = {
      'colors': Color(0xFFFF5277),
      'fruits': Color(0xFF00B074),
      'animals': Color(0xFFFF9500),
      'vehicles': Color(0xFF0088FF),
      'shapes': Color(0xFF8E24AA),
    };
    return map[widget.categoryId] ?? const Color(0xFFFF9500);
  }

  Color _backgroundColor() {
    const map = {
      'colors': Color(0xFFFFF7F9),
      'fruits': Color(0xFFF3FAF6),
      'animals': Color(0xFFFFFBF5),
      'vehicles': Color(0xFFF4F8FD),
      'shapes': Color(0xFFFAF4FC),
    };
    return map[widget.categoryId] ?? const Color(0xFFFAF9F6);
  }

  String _nextPraise() {
    int idx;
    do { idx = Random().nextInt(_praisePhrases.length); }
    while (idx == _lastPraiseIndex && _praisePhrases.length > 1);
    _lastPraiseIndex = idx;
    return _praisePhrases[idx];
  }

  // ─── Game logic ───────────────────────────────────────────────────────────

  void _onChoiceTapped(int index) {
    if (_feedbackType != null || _isAdvancing) return;

    final tapped = _choices[index];
    final target = _questions[_currentIndex];

    setState(() { _tappedIndex = index; });

    if (tapped == target) {
      final praise = _nextPraise();
      setState(() {
        _feedbackType = 'correct';
        _praiseText = praise;
        _sessionStars++;
      });
      SoundService.playCorrect();
      _correctController.forward(from: 0);
      _isAdvancing = true;
      Future.delayed(const Duration(milliseconds: 900), _advance);
    } else {
      setState(() { _feedbackType = 'wrong'; });
      SoundService.playWrong();
      _shakeController.forward(from: 0).whenComplete(() {
        if (mounted) {
          setState(() {
            _feedbackType = null;
            _tappedIndex = null;
          });
          _shakeController.reset();
        }
      });
    }
  }

  void _advance() {
    if (!mounted) return;

    if (_currentIndex + 1 >= _questions.length) {
      StorageService.addStars(widget.categoryId, _sessionStars);
      SoundService.playComplete();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(
            categoryId: widget.categoryId,
            starsEarned: _sessionStars,
            totalQuestions: _questions.length,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } else {
      setState(() {
        _currentIndex++;
        _feedbackType = null;
        _tappedIndex = null;
        _isAdvancing = false;
      });
      _correctController.reset();
      _buildChoices();
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final target = _questions[_currentIndex];
    final accentColor = _categoryColor();
    final bgColor = _backgroundColor();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Navigation Bar ---
            _TopBar(
              label: _categoryLabel(),
              accentColor: accentColor,
              sessionStars: _sessionStars,
              soundEnabled: _soundEnabled,
              onToggleSound: _toggleSound,
              onBack: () => Navigator.of(context).pop(),
            ),

            // --- Progress Bar ---
            _ProgressBar(
              progress: (_currentIndex + 1) / _questions.length,
              accentColor: accentColor,
              current: _currentIndex + 1,
              total: _questions.length,
            ),

            // --- Game Area with Confetti Burst ---
            Expanded(
              child: ConfettiBurst(
                isPlaying: _feedbackType == 'correct',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Prompt with highlighted target keyword
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                            ),
                            children: [
                              const TextSpan(text: 'Touch the '),
                              TextSpan(
                                text: target.name,
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const TextSpan(text: '! ✨'),
                            ],
                          ),
                        ),
                      ),

                      // Target Illustrated Graphic with gentle idle breathing & victory bounce
                      ScaleTransition(
                        scale: _feedbackType == 'correct'
                            ? _correctScale
                            : _idleScale,
                        child: _TargetGraphic(
                          item: target,
                          accentColor: accentColor,
                          isCorrect: _feedbackType == 'correct',
                        ),
                      ),

                      // Cheerful Floating Feedback Pill
                      SizedBox(
                        height: 48,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _feedbackType == null
                                ? const SizedBox.shrink(key: ValueKey('empty'))
                                : Container(
                                    key: ValueKey(_feedbackType),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _feedbackType == 'correct'
                                          ? const Color(0xFFE8F8EE)
                                          : const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: _feedbackType == 'correct'
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFFE53935),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_feedbackType == 'correct'
                                                  ? const Color(0xFF2E7D32)
                                                  : const Color(0xFFE53935))
                                              .withValues(alpha: 0.15),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _feedbackType == 'correct'
                                          ? _praiseText
                                          : '😅 Try again!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: _feedbackType == 'correct'
                                            ? const Color(0xFF1B5E20)
                                            : const Color(0xFFB71C1C),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // 3 Answer Choices (One-handed thumb reach)
                      Row(
                        children: List.generate(3, (i) {
                          final item = _choices[i];
                          final isSelected = _tappedIndex == i;

                          CardState cardState = CardState.idle;
                          if (isSelected && _feedbackType == 'correct') {
                            cardState = CardState.correct;
                          } else if (isSelected && _feedbackType == 'wrong') {
                            cardState = CardState.wrong;
                          }

                          Widget card = AnswerCard(
                            item: item,
                            state: cardState,
                            onTap: () => _onChoiceTapped(i),
                          );

                          // Shake animation on incorrect choice
                          if (cardState == CardState.wrong) {
                            card = AnimatedBuilder(
                              animation: _shakeAnim,
                              builder: (context, child) => Transform.translate(
                                offset: Offset(
                                  sin(_shakeAnim.value * pi * 8) * 8, 0,
                                ),
                                child: child,
                              ),
                              child: card,
                            );
                          }

                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: i == 0 ? 0 : 6,
                                right: i == 2 ? 0 : 6,
                              ),
                              child: card,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String label;
  final Color accentColor;
  final int sessionStars;
  final bool soundEnabled;
  final VoidCallback onToggleSound;
  final VoidCallback onBack;

  const _TopBar({
    required this.label,
    required this.accentColor,
    required this.sessionStars,
    required this.soundEnabled,
    required this.onToggleSound,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Category Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),

          // Quick Sound Toggle
          GestureDetector(
            onTap: onToggleSound,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                size: 18,
                color: soundEnabled ? const Color(0xFF475569) : const Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Session Star Counter
          StarCounter(count: sessionStars, isCompact: true),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color accentColor;
  final int current;
  final int total;

  const _ProgressBar({
    required this.progress,
    required this.accentColor,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              builder: (context, value, child) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetGraphic extends StatelessWidget {
  final GameItem item;
  final Color accentColor;
  final bool isCorrect;

  const _TargetGraphic({
    required this.item,
    required this.accentColor,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCorrect ? const Color(0xFF4CAF50) : accentColor.withValues(alpha: 0.18),
          width: isCorrect ? 4 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? const Color(0xFF4CAF50) : accentColor)
                .withValues(alpha: isCorrect ? 0.3 : 0.12),
            blurRadius: isCorrect ? 28 : 18,
            spreadRadius: isCorrect ? 6 : 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: GameGraphic.fromItem(
        item,
        size: 96,
      ),
    );
  }
}
