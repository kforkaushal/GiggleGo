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

  static const _praisePhrases = ['Yay! 🎉', 'Great! 🌟', 'Awesome! 🎊'];

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  late AnimationController _correctController;
  late Animation<double> _correctScale;

  @override
  void initState() {
    super.initState();
    _allItems = _dataFor(widget.categoryId);
    _setupQuestions();
    _buildChoices();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeController);

    _correctController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _correctScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _correctController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _correctController.dispose();
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

  // ─── UI helpers ───────────────────────────────────────────────────────────

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
      'colors': Color(0xFFFF8A65),
      'fruits': Color(0xFF66BB6A),
      'animals': Color(0xFF42A5F5),
      'vehicles': Color(0xFFAB47BC),
      'shapes': Color(0xFFFFCA28),
    };
    return map[widget.categoryId] ?? const Color(0xFFFFAB40);
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
      // Session complete — persist stars then show result
      StorageService.addStars(widget.categoryId, _sessionStars);
      SoundService.playComplete();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
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

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              label: _categoryLabel(),
              accentColor: accentColor,
              sessionStars: _sessionStars,
              onBack: () => Navigator.of(context).pop(),
            ),
            _ProgressBar(
              progress: (_currentIndex + 1) / _questions.length,
              accentColor: accentColor,
              current: _currentIndex + 1,
              total: _questions.length,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Prompt
                    Text(
                      'Touch the ${target.name}!',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF37474F),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Target emoji with correct scale anim
                    ScaleTransition(
                      scale: _feedbackType == 'correct'
                          ? _correctScale
                          : const AlwaysStoppedAnimation(1.0),
                      child: _TargetEmoji(
                        emoji: target.emoji,
                        isCorrect: _feedbackType == 'correct',
                      ),
                    ),

                    // Feedback text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _feedbackType == null
                          ? const SizedBox(height: 36, key: ValueKey('empty'))
                          : Text(
                              _feedbackType == 'correct'
                                  ? _praiseText
                                  : '😅 Try again!',
                              key: ValueKey(_feedbackType),
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: _feedbackType == 'correct'
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFEF5350),
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),

                    // Choice cards
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

                        // Shake only the wrong tapped card
                        if (cardState == CardState.wrong) {
                          card = AnimatedBuilder(
                            animation: _shakeAnim,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(
                                  sin(_shakeAnim.value * pi * 7) * 9, 0),
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

                    const SizedBox(height: 8),
                  ],
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
  final VoidCallback onBack;

  const _TopBar({
    required this.label,
    required this.accentColor,
    required this.sessionStars,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: Color(0xFF37474F)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          StarCounter(count: sessionStars),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$current / $total',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, child) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetEmoji extends StatelessWidget {
  final String emoji;
  final bool isCorrect;

  const _TargetEmoji({required this.emoji, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
            : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isCorrect
                ? const Color(0xFF4CAF50).withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: isCorrect ? 4 : 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 80)),
    );
  }
}
