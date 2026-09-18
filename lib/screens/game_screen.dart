import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../data/colors_data.dart';
import '../data/fruits_data.dart';
import '../data/animals_data.dart';
import '../data/vehicles_data.dart';
import '../data/shapes_data.dart';
import '../data/alphabet_data.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../theme/tokens.dart';
import '../widgets/star_counter.dart';
import '../widgets/answer_card.dart';
import '../widgets/game_question_card.dart';
import '../widgets/smooth_mascot.dart';
import '../widgets/smooth_graphic.dart';
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
  }

  Future<void> _loadSoundState() async {
    final sound = await StorageService.getSoundEnabled();
    if (mounted) {
      setState(() => _soundEnabled = sound);
      if (sound) {
        SoundService.playActivityMusic();
      }
    }
  }

  Future<void> _toggleSound() async {
    final next = !_soundEnabled;
    await StorageService.setSoundEnabled(next);
    if (mounted) {
      setState(() => _soundEnabled = next);
      await SoundService.onSoundToggled(next, currentContext: 'activity');
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    SoundService.playHomeMusic();
    super.dispose();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  List<GameItem> _dataFor(String id) {
    switch (id) {
      case 'alphabet': return alphabetData;
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

  // ─── Theming & Mascot helpers ─────────────────────────────────────────────

  String _categoryLabel() {
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

  Color _categoryColor() {
    const map = {
      'alphabet': Color(0xFF9C27B0),
      'colors': Color(0xFFFF5277),
      'fruits': Color(0xFF00B074),
      'animals': Color(0xFFFF9500),
      'vehicles': Color(0xFF0088FF),
      'shapes': Color(0xFF5E35B1),
    };
    return map[widget.categoryId] ?? const Color(0xFFFF9500);
  }

  String _mascotAction() {
    if (_feedbackType == 'correct') return 'celebrate';
    if (_feedbackType == 'wrong') return 'curious';
    return 'thinking';
  }

  void _replayPrompt() {
    SoundService.playTap();
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
      StorageService.setLastPlayedCategory(widget.categoryId);
      if (_sessionStars >= (_questions.length * 0.6).ceil()) {
        StorageService.unlockSticker(widget.categoryId);
      }
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
      _buildChoices();
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final target = _questions[_currentIndex];
    final accentColor = _categoryColor();

    return Scaffold(
      backgroundColor: Colors.white,
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: constraints.maxHeight > 540
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Standardized Prompt Card (PRD Section 17 & V2 Add-on #1)
                                    GameQuestionCard(
                                      targetName: target.name,
                                      subtitleHint: target.subtitle,
                                      accentColor: accentColor,
                                      onReplayPrompt: _replayPrompt,
                                    ),

                                    const SizedBox(height: AppSpacing.xl),

                                    // Mascot Guide + Dominant Target Stage Row (PRD Section 18)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // Encouraging Mascot Guide (~84px, secondary to target)
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SmoothMascot(
                                              key: ValueKey('mascot_${_mascotAction()}'),
                                              action: _mascotAction(),
                                              size: AppSizes.mascotGuide,
                                            ),
                                            const SizedBox(height: 2),
                                            Container(
                                              width: 54,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: AppSpacing.lg),

                                        // Visually Dominant Learning Target Graphic (~116px)
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _TargetGraphic(
                                              item: target,
                                              accentColor: accentColor,
                                              isCorrect: _feedbackType == 'correct',
                                            ),
                                            const SizedBox(height: 2),
                                            Container(
                                              width: 96,
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

                                    const SizedBox(height: AppSpacing.lg),

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

                                    const SizedBox(height: AppSpacing.xl),

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
          );
          },
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
          // Authentic Game Back Button
          GestureDetector(
            onTap: onBack,
            child: Image.asset(
              'assets/images/ui/btn_back.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),

          // Category Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'AnjaEliane',
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 1.2,
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
    final graphicContent = SmoothGraphic(
      key: ValueKey('smooth_target_${item.name}_$isCorrect'),
      size: 116,
      popOnEntry: true,
      autoFloat: !isCorrect,
      child: Image.asset(
        item.imagePath!,
        width: 116,
        height: 116,
        fit: BoxFit.contain,
      ),
    );

    final targetCircle = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCorrect ? const Color(0xFF4CAF50) : accentColor.withValues(alpha: 0.22),
          width: isCorrect ? 3.5 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? const Color(0xFF4CAF50) : accentColor)
                .withValues(alpha: isCorrect ? 0.35 : 0.12),
            blurRadius: isCorrect ? 24 : 16,
            spreadRadius: isCorrect ? 4 : 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: graphicContent,
    );

    if (!isCorrect) return targetCircle;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: 0.75,
          child: Image.asset(
            'assets/images/ui/shine.png',
            width: 168,
            height: 168,
            fit: BoxFit.contain,
          ),
        ),
        targetCircle,
        Positioned(
          top: -4,
          right: -4,
          child: Image.asset(
            'assets/images/ui/sparkles.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
