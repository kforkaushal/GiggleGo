import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../widgets/smooth_mascot.dart';
import '../widgets/smooth_graphic.dart';
import 'game_screen.dart';

/// Data mapping each letter A-Z to its two companion cartoon objects.
class _LetterCompanion {
  final String letter;
  final String word1;
  final String obj1;
  final String word2;
  final String obj2;
  final String exampleSentence;

  const _LetterCompanion({
    required this.letter,
    required this.word1,
    required this.obj1,
    required this.word2,
    required this.obj2,
    required this.exampleSentence,
  });
}

const List<_LetterCompanion> _alphabetCompanions = [
  _LetterCompanion(letter: 'A', word1: 'Apple', obj1: 'apple', word2: 'Ant', obj2: 'ant', exampleSentence: 'A is for Apple & Ant! 🍎🐜'),
  _LetterCompanion(letter: 'B', word1: 'Ball', obj1: 'ball', word2: 'Bear', obj2: 'bear', exampleSentence: 'B is for Ball & Bear! ⚽🐻'),
  _LetterCompanion(letter: 'C', word1: 'Car', obj1: 'car', word2: 'Cat', obj2: 'cat', exampleSentence: 'C is for Car & Cat! 🚗🐱'),
  _LetterCompanion(letter: 'D', word1: 'Dog', obj1: 'dog', word2: 'Donut', obj2: 'donut', exampleSentence: 'D is for Dog & Donut! 🐶🍩'),
  _LetterCompanion(letter: 'E', word1: 'Elephant', obj1: 'elephant', word2: 'Egg', obj2: 'egg', exampleSentence: 'E is for Elephant & Egg! 🐘🥚'),
  _LetterCompanion(letter: 'F', word1: 'Frog', obj1: 'frog', word2: 'Flower', obj2: 'flower', exampleSentence: 'F is for Frog & Flower! 🐸🌸'),
  _LetterCompanion(letter: 'G', word1: 'Grape', obj1: 'grape', word2: 'Gift', obj2: 'gift', exampleSentence: 'G is for Grape & Gift! 🍇🎁'),
  _LetterCompanion(letter: 'H', word1: 'Hat', obj1: 'hat', word2: 'House', obj2: 'house', exampleSentence: 'H is for Hat & House! 🎩🏡'),
  _LetterCompanion(letter: 'I', word1: 'Ice Cream', obj1: 'ice_cream', word2: 'Igloo', obj2: 'igloo', exampleSentence: 'I is for Ice Cream & Igloo! 🍦🧊'),
  _LetterCompanion(letter: 'J', word1: 'Juice', obj1: 'juice', word2: 'Jelly', obj2: 'jelly', exampleSentence: 'J is for Juice & Jelly! 🧃🍮'),
  _LetterCompanion(letter: 'K', word1: 'Kite', obj1: 'kite', word2: 'Key', obj2: 'key', exampleSentence: 'K is for Kite & Key! 🪁🔑'),
  _LetterCompanion(letter: 'L', word1: 'Lion', obj1: 'lion', word2: 'Leaf', obj2: 'leaf', exampleSentence: 'L is for Lion & Leaf! 🦁🍃'),
  _LetterCompanion(letter: 'M', word1: 'Mango', obj1: 'mango', word2: 'Moon', obj2: 'moon', exampleSentence: 'M is for Mango & Moon! 🥭🌙'),
  _LetterCompanion(letter: 'N', word1: 'Nest', obj1: 'nest', word2: 'Notebook', obj2: 'notebook', exampleSentence: 'N is for Nest & Notebook! 🪺📓'),
  _LetterCompanion(letter: 'O', word1: 'Orange', obj1: 'orange', word2: 'Octopus', obj2: 'octopus', exampleSentence: 'O is for Orange & Octopus! 🍊🐙'),
  _LetterCompanion(letter: 'P', word1: 'Panda', obj1: 'panda', word2: 'Pencil', obj2: 'pencil', exampleSentence: 'P is for Panda & Pencil! 🐼✏️'),
  _LetterCompanion(letter: 'Q', word1: 'Queen', obj1: 'queen', word2: 'Quill', obj2: 'quill', exampleSentence: 'Q is for Queen & Quill! 👑🪶'),
  _LetterCompanion(letter: 'R', word1: 'Rocket', obj1: 'rocket', word2: 'Rainbow', obj2: 'rainbow', exampleSentence: 'R is for Rocket & Rainbow! 🚀🌈'),
  _LetterCompanion(letter: 'S', word1: 'Star', obj1: 'star', word2: 'Sun', obj2: 'sun', exampleSentence: 'S is for Star & Sun! ⭐☀️'),
  _LetterCompanion(letter: 'T', word1: 'Train', obj1: 'train', word2: 'Tree', obj2: 'tree', exampleSentence: 'T is for Train & Tree! 🚂🌳'),
  _LetterCompanion(letter: 'U', word1: 'Umbrella', obj1: 'umbrella', word2: 'Unicorn', obj2: 'unicorn', exampleSentence: 'U is for Umbrella & Unicorn! ☂️🦄'),
  _LetterCompanion(letter: 'V', word1: 'Volcano', obj1: 'volcano', word2: 'Vase', obj2: 'vase', exampleSentence: 'V is for Volcano & Vase! 🌋🏺'),
  _LetterCompanion(letter: 'W', word1: 'Watermelon', obj1: 'watermelon', word2: 'Whale', obj2: 'whale', exampleSentence: 'W is for Watermelon & Whale! 🍉🐳'),
  _LetterCompanion(letter: 'X', word1: 'Xylophone', obj1: 'xylophone', word2: 'X-Ray', obj2: 'x-ray', exampleSentence: 'X is for Xylophone & X-Ray! 🎵🩻'),
  _LetterCompanion(letter: 'Y', word1: 'Yacht', obj1: 'yacht', word2: 'Yo-Yo', obj2: 'yo-yo', exampleSentence: 'Y is for Yacht & Yo-Yo! ⛵🪀'),
  _LetterCompanion(letter: 'Z', word1: 'Zebra', obj1: 'zebra', word2: 'Zipper', obj2: 'zipper', exampleSentence: 'Z is for Zebra & Zipper! 🦓🤐'),
];

/// Interactive Alphabet Board & Explorer Screen.
/// Follows PRD Sections 10, 11, 12 with prominent 116px active letter centerpiece,
/// clean navigation controls, mascot phonics guide, and centered uniform 6-column A-Z grid.
class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _obj1TapCount = 0;
  int _obj2TapCount = 0;
  late AnimationController _shineController;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _loadSoundState();
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
    _shineController.dispose();
    SoundService.playHomeMusic();
    super.dispose();
  }

  void _onLetterSelected(int index) {
    SoundService.playPop();
    setState(() {
      _selectedIndex = index;
      _obj1TapCount = 0;
      _obj2TapCount = 0;
    });
  }

  void _nextLetter() {
    SoundService.playPop();
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % _alphabetCompanions.length;
      _obj1TapCount = 0;
      _obj2TapCount = 0;
    });
  }

  void _prevLetter() {
    SoundService.playPop();
    setState(() {
      _selectedIndex = (_selectedIndex - 1 + _alphabetCompanions.length) % _alphabetCompanions.length;
      _obj1TapCount = 0;
      _obj2TapCount = 0;
    });
  }

  void _replayObj1() {
    SoundService.playPop();
    setState(() => _obj1TapCount++);
  }

  void _replayObj2() {
    SoundService.playPop();
    setState(() => _obj2TapCount++);
  }

  void _startAlphabetGame() {
    StorageService.setLastPlayedCategory('alphabet');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameScreen(categoryId: 'alphabet'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Widget _buildLetterTile(int index, double tileSize) {
    final item = _alphabetCompanions[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onLetterSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3E5F5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.alphabet : AppColors.borderLight,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.alphabet.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppShadows.soft,
        ),
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: isSelected
            ? SmoothGraphic(
                key: ValueKey('grid_alpha_${item.letter}'),
                size: tileSize - 10,
                popOnEntry: true,
                autoFloat: false,
                child: Image.asset(
                  'assets/images/alphabet/${item.letter.toLowerCase()}.png',
                  fit: BoxFit.contain,
                ),
              )
            : Image.asset(
                'assets/images/alphabet/${item.letter.toLowerCase()}.png',
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companion = _alphabetCompanions[_selectedIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Header Bar ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.sm,
                AppSpacing.base,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  // Back Button (min 48px touch target)
                  Semantics(
                    button: true,
                    label: 'Back to Home',
                    child: GestureDetector(
                      onTap: () {
                        SoundService.playHomeMusic();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: AppSizes.minTouchTarget,
                        height: AppSizes.minTouchTarget,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/ui/btn_back.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Screen Title Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.alphabet.withValues(alpha: 0.12),
                      borderRadius: AppRadius.roundedPill,
                    ),
                    child: Text(
                      'ABC EXPLORER',
                      style: AppTypography.screenTitle.copyWith(
                        fontSize: 16,
                        color: AppColors.alphabet,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Quick Sound Toggle Button (min 48px touch target)
                  Semantics(
                    button: true,
                    label: _soundEnabled ? 'Mute Music' : 'Unmute Music',
                    child: GestureDetector(
                      onTap: _toggleSound,
                      child: Container(
                        width: AppSizes.minTouchTarget,
                        height: AppSizes.minTouchTarget,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Icon(
                          _soundEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          size: 22,
                          color: _soundEnabled
                              ? AppColors.textDark
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Scrollable / Adaptive Core Content ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  children: [
                    // --- Active Letter Showcase Card (PRD Section 10) ---
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(
                          color: const Color(0xFFE1BEE7),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.alphabet.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Top Row: Flanking Arrows & Centerpiece Active Letter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Previous Letter Arrow (min 48px hit area)
                              GestureDetector(
                                onTap: _prevLetter,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E5F5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFCE93D8),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/images/ui/btn_back.png',
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              // Centerpiece Letter Showcase (116px container per PRD Section 10)
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  RotationTransition(
                                    turns: _shineController,
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: Image.asset(
                                        'assets/images/ui/shine.png',
                                        width: 118,
                                        height: 118,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 96,
                                    height: 96,
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.alphabet.withValues(alpha: 0.16),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: SmoothGraphic(
                                      key: ValueKey('smooth_alpha_${companion.letter}'),
                                      size: 80,
                                      popOnEntry: true,
                                      autoFloat: true,
                                      child: Image.asset(
                                        'assets/images/alphabet/${companion.letter.toLowerCase()}.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Next Letter Arrow (min 48px hit area)
                              GestureDetector(
                                onTap: _nextLetter,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E5F5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFCE93D8),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/images/ui/btn_next.png',
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Middle Row: Mascot Guide + Companion Object 1 + Companion Object 2
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Mascot Phonics Guide
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SmoothMascot(
                                    key: ValueKey('alpha_mascot_${companion.letter}'),
                                    action: 'happy',
                                    size: 52,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E5F5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Letter ${companion.letter}',
                                      style: AppTypography.body.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF7B1FA2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Companion Object 1
                              GestureDetector(
                                onTap: _replayObj1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.sm),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: AppColors.borderLight),
                                        boxShadow: AppShadows.soft,
                                      ),
                                      child: SmoothGraphic(
                                        key: ValueKey('smooth_${companion.obj1}_$_obj1TapCount'),
                                        size: 56,
                                        popOnEntry: true,
                                        autoFloat: false,
                                        child: Image.asset(
                                          'assets/images/objects/${companion.obj1}.png',
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      companion.word1,
                                      style: AppTypography.category.copyWith(
                                        fontSize: 13,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Companion Object 2
                              GestureDetector(
                                onTap: _replayObj2,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.sm),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: AppColors.borderLight),
                                        boxShadow: AppShadows.soft,
                                      ),
                                      child: SmoothGraphic(
                                        key: ValueKey('smooth_${companion.obj2}_$_obj2TapCount'),
                                        size: 56,
                                        popOnEntry: true,
                                        autoFloat: false,
                                        child: Image.asset(
                                          'assets/images/objects/${companion.obj2}.png',
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      companion.word2,
                                      style: AppTypography.category.copyWith(
                                        fontSize: 13,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Phonics Example Sentence Pill
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs + 2,
                              horizontal: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5FC),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Text(
                              companion.exampleSentence,
                              style: AppTypography.body.copyWith(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF7B1FA2),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // --- Centered Uniform A-Z Grid (PRD Section 11) ---
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 7.0;
                        final totalSpacing = spacing * 5;
                        final tileSize = ((constraints.maxWidth - totalSpacing) / 6).clamp(38.0, 52.0);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Rows 1 to 4 (Letters A to X, 6 items each)
                            for (int r = 0; r < 4; r++) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  for (int c = 0; c < 6; c++)
                                    _buildLetterTile(r * 6 + c, tileSize),
                                ],
                              ),
                              const SizedBox(height: spacing),
                            ],
                            // Row 5: Y and Z Centered (avoiding awkward lopsided gap)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLetterTile(24, tileSize),
                                const SizedBox(width: spacing),
                                _buildLetterTile(25, tileSize),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),

            // --- Bottom Primary CTA Button: Play Alphabet Quiz (PRD Section 12) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: GestureDetector(
                onTap: _startAlphabetGame,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.gradientAlphabet,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.roundedLg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.alphabet.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ui/btn_play.png',
                        width: 26,
                        height: 26,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Play Alphabet Quiz',
                        style: AppTypography.category.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
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
