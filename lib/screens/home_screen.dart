import 'dart:math';
import 'package:flutter/material.dart';
import '../data/category_meta.dart';
import '../theme/tokens.dart';
import '../widgets/game_card.dart';
import '../widgets/giggle_header.dart';
import '../widgets/welcome_banner.dart';
import '../widgets/tutorial_overlay.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';
import 'alphabet_screen.dart';
import 'parent_area_screen.dart';

/// Responsive, toddler-friendly Home Screen.
/// Employs a scrollable sliver architecture (zero overflow on any screen size),
/// first-session onboarding vs returning-session shortcuts, and large touch targets.
class HomeScreen extends StatefulWidget {
  final bool forceTutorial;

  const HomeScreen({
    super.key,
    this.forceTutorial = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static List<CategoryMeta> get _baseCategories => allCategories;

  final Map<String, int> _starTotals = {};
  int _totalStars = 0;
  bool _soundEnabled = true;
  bool _tutorialCompleted = false;
  String? _lastPlayedCategory;
  bool _showTutorial = false;
  bool _hasHandledInitialTutorial = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    int total = 0;
    for (final cat in _baseCategories) {
      final stars = await StorageService.getStars(cat.id);
      _starTotals[cat.id] = stars;
      total += stars;
    }

    final sound = await StorageService.getSoundEnabled();
    final tutorialDone = await StorageService.getTutorialCompleted();
    final lastCategory = await StorageService.getLastPlayedCategory();

    if (mounted) {
      setState(() {
        _totalStars = total;
        _soundEnabled = sound;
        _tutorialCompleted = tutorialDone;
        _lastPlayedCategory = lastCategory;
        if (widget.forceTutorial && !_hasHandledInitialTutorial) {
          _hasHandledInitialTutorial = true;
          _showTutorial = true;
        }
      });

      if (sound) {
        SoundService.playHomeMusic();
      }
    }
  }

  Future<void> _toggleSound() async {
    final next = !_soundEnabled;
    await StorageService.setSoundEnabled(next);
    if (mounted) {
      setState(() => _soundEnabled = next);
    }
    await SoundService.onSoundToggled(next, currentContext: 'home');
  }

  List<CategoryMeta> get _displayCategories {
    if (_lastPlayedCategory == null) return _baseCategories;

    // Prioritize the last played category first for returning children
    final list = List<CategoryMeta>.from(_baseCategories);
    final idx = list.indexWhere((c) => c.id == _lastPlayedCategory);
    if (idx > 0) {
      final item = list.removeAt(idx);
      list.insert(0, item);
    }
    return list;
  }

  void _openGame(String categoryId) async {
    await StorageService.setLastPlayedCategory(categoryId);
    if (!mounted) return;

    if (categoryId == 'alphabet') {
      await Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AlphabetScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
        ),
      );
      if (!mounted) return;
      SoundService.playHomeMusic();
      _loadState();
      return;
    }

    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(categoryId: categoryId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
    if (!mounted) return;
    SoundService.playHomeMusic();
    _loadState();
  }

  void _onPrimaryActionTap() {
    SoundService.playPop();
    if (!_tutorialCompleted) {
      // First session: open tutorial demonstration
      setState(() {
        _hasHandledInitialTutorial = false;
        _showTutorial = true;
      });
    } else {
      // Returning session: quick play last category or colors
      _openGame(_lastPlayedCategory ?? 'colors');
    }
  }

  void _openParentArea() async {
    final passedGate = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _ParentalGateDialog(),
    );

    if (passedGate == true && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ParentAreaScreen()),
      );
      _loadState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft ambient cartoon backdrop
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'assets/images/backgrounds/bg_1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Responsive, scrollable main content with zero overflow
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header (Brand + 56dp Sound + Stars + Quiet Parent Gate)
                SliverToBoxAdapter(
                  child: GiggleHeader(
                    totalStars: _totalStars,
                    soundEnabled: _soundEnabled,
                    onToggleSound: _toggleSound,
                    onOpenSettings: _openParentArea,
                  ),
                ),

                // 2. Welcome Banner
                const SliverToBoxAdapter(
                  child: WelcomeBanner(),
                ),

                // 3. Child-First Primary Action ("Start playing" or "Play again")
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.xs + 2,
                    ),
                    child: _buildPrimaryActionCard(),
                  ),
                ),

                // 4. Clean Category Heading: "Pick a game"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.sm,
                      AppSpacing.base,
                      AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Pick a game',
                          style: AppTypography.category.copyWith(
                            fontSize: 15,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Responsive Category Grid (2 columns on mobile, 3 on tablet)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.xs,
                    AppSpacing.base,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCard(_displayCategories[index]),
                      childCount: _displayCategories.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isTablet ? 1.05 : 0.88,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interactive 4-step toddler tutorial overlay if triggered
          if (_showTutorial)
            TutorialOverlay(
              onCompleted: () {
                setState(() {
                  _showTutorial = false;
                  _hasHandledInitialTutorial = true;
                  _tutorialCompleted = true;
                });
                _loadState();
              },
              onSkip: () {
                setState(() {
                  _showTutorial = false;
                  _hasHandledInitialTutorial = true;
                  _tutorialCompleted = true;
                });
                _loadState();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionCard() {
    final isFirstSession = !_tutorialCompleted;
    final label = isFirstSession ? 'Start playing!' : 'Play again!';
    final subtitle = isFirstSession ? 'Learn how to tap & play ✨' : 'Jump right into learning fun ✨';

    return GestureDetector(
      onTap: _onPrimaryActionTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9500), Color(0xFFFFB300)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.roundedXl,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9500).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/ui/btn_play.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontDisplay,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontBody,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(CategoryMeta cat) {
    return GameCard(
      emoji: cat.emoji,
      title: cat.title,
      categoryId: cat.id,
      gradientColors: cat.gradient,
      shadowColor: cat.shadow,
      totalStars: _starTotals[cat.id] ?? 0,
      onTap: () => _openGame(cat.id),
    );
  }
}

/// Minimalist, adult math challenge (Parental Gate).
class _ParentalGateDialog extends StatefulWidget {
  const _ParentalGateDialog();

  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog> {
  late int _num1;
  late int _num2;
  late int _answer;
  String _input = '';
  bool _isWrong = false;

  @override
  void initState() {
    super.initState();
    _newProblem();
  }

  void _newProblem() {
    final r = Random();
    _num1 = 6 + r.nextInt(9); // 6–14
    _num2 = 7 + r.nextInt(9); // 7–15
    _answer = _num1 + _num2;
    _input = '';
    _isWrong = false;
  }

  void _appendDigit(int digit) {
    if (_input.length >= 3) return;
    setState(() {
      _input += '$digit';
      _isWrong = false;
    });
  }

  void _backspace() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
        _isWrong = false;
      });
    }
  }

  void _check() {
    final entered = int.tryParse(_input);
    if (entered == _answer) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isWrong = true;
        _newProblem();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock_rounded, size: 20, color: Color(0xFF475569)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Parents Only',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Please solve this simple math check to continue:',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // Math problem display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isWrong ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_num1 + $_num2 = ',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Text(
                    _input.isEmpty ? '?' : _input,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _input.isEmpty
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
            if (_isWrong)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Incorrect. Please try this new problem.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            const SizedBox(height: 18),

            // Keypad
            _buildKeypad(),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _input.isNotEmpty ? _check : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Enter',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                for (var col = 1; col <= 3; col++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _keyBtn('${row * 3 + col}', () => _appendDigit(row * 3 + col)),
                    ),
                  ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _keyBtn('C', () => setState(() => _input = '')),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _keyBtn('0', () => _appendDigit(0)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _keyBtn('⌫', _backspace),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _keyBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
