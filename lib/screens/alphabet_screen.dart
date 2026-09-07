import 'package:flutter/material.dart';
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
/// Kids can tap any letter button to see it bounce and watch its companion objects appear!
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

  @override
  Widget build(BuildContext context) {
    final companion = _alphabetCompanions[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FC),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft ambient cartoon backdrop
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/backgrounds/bg_1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // --- Top Bar ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          SoundService.playHomeMusic();
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          'assets/images/ui/btn_back.png',
                          width: 44,
                          height: 44,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'ABC EXPLORER',
                          style: TextStyle(
                            fontFamily: 'AnjaEliane',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF9C27B0),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Quick Sound Toggle Button
                      GestureDetector(
                        onTap: _toggleSound,
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            size: 19,
                            color: _soundEnabled ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Active Letter Showcase Card ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE1BEE7), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top Tier: Previous Button <--- [ Active Letter Spotlight ] ---> Next Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous Letter Button
                            GestureDetector(
                              onTap: _prevLetter,
                              child: Image.asset(
                                'assets/images/ui/btn_back.png',
                                width: 42,
                                height: 42,
                                fit: BoxFit.contain,
                              ),
                            ),

                            // Active Letter Centerpiece with Rotating Sunburst Shine
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                RotationTransition(
                                  turns: _shineController,
                                  child: Opacity(
                                    opacity: 0.55,
                                    child: Image.asset(
                                      'assets/images/ui/shine.png',
                                      width: 98,
                                      height: 98,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E5F5),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9C27B0).withValues(alpha: 0.16),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: SmoothGraphic(
                                    key: ValueKey('smooth_alpha_${companion.letter}'),
                                    size: 68,
                                    popOnEntry: true,
                                    autoFloat: true,
                                    child: Image.asset(
                                      'assets/images/alphabet/${companion.letter.toLowerCase()}.png',
                                      width: 68,
                                      height: 68,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Next Letter Button
                            GestureDetector(
                              onTap: _nextLetter,
                              child: Image.asset(
                                'assets/images/ui/btn_next.png',
                                width: 42,
                                height: 42,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Middle Tier: Mascot Guide + Companion Object 1 + Companion Object 2
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Cheerful Mascot Guide
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SmoothMascot(
                                  key: ValueKey('alpha_mascot_${companion.letter}'),
                                  action: 'happy',
                                  size: 48,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E5F5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Letter ${companion.letter}',
                                    style: const TextStyle(
                                      fontFamily: 'AlteHaasGrotesk',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7B1FA2),
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
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: SmoothGraphic(
                                      key: ValueKey('smooth_${companion.obj1}_$_obj1TapCount'),
                                      size: 48,
                                      popOnEntry: true,
                                      autoFloat: false,
                                      child: Image.asset(
                                        'assets/images/objects/${companion.obj1}.png',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    companion.word1,
                                    style: const TextStyle(
                                      fontFamily: 'AnjaEliane',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF334155),
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
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: SmoothGraphic(
                                      key: ValueKey('smooth_${companion.obj2}_$_obj2TapCount'),
                                      size: 48,
                                      popOnEntry: true,
                                      autoFloat: false,
                                      child: Image.asset(
                                        'assets/images/objects/${companion.obj2}.png',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    companion.word2,
                                    style: const TextStyle(
                                      fontFamily: 'AnjaEliane',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Bottom Tier: Example Phonics Sentence
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF5FC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            companion.exampleSentence,
                            style: const TextStyle(
                              fontFamily: 'AlteHaasGrotesk',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7B1FA2),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Alphabet Letter Buttons Grid (A to Z) ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: _alphabetCompanions.length,
                      itemBuilder: (context, index) {
                        final item = _alphabetCompanions[index];
                        final isSelected = _selectedIndex == index;

                        return GestureDetector(
                          onTap: () => _onLetterSelected(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE1BEE7)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF8E24AA)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xFF8E24AA).withValues(alpha: 0.25)
                                      : Colors.black.withValues(alpha: 0.04),
                                  blurRadius: isSelected ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: isSelected
                                ? SmoothGraphic(
                                    key: ValueKey('grid_alpha_${item.letter}'),
                                    size: 38,
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
                      },
                    ),
                  ),
                ),

                // --- Bottom Play Alphabet Quiz Button ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                  child: GestureDetector(
                    onTap: _startAlphabetGame,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C27B0).withValues(alpha: 0.35),
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
                          const SizedBox(width: 8),
                          const Text(
                            'Play Alphabet Quiz',
                            style: TextStyle(
                              fontFamily: 'AnjaEliane',
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
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
        ],
      ),
    );
  }
}
