import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/game_card.dart';
import '../widgets/giggle_header.dart';
import '../widgets/welcome_banner.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';
import 'alphabet_screen.dart';
import 'parent_area_screen.dart';

/// Home screen — shows 5 category cards, sound toggle, and parental settings.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Category metadata: id, display title, emoji, rich gradients
  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'alphabet',
      'title': 'ABC Letters',
      'emoji': '🅰️',
      'subtitle': 'A to Z letter fun!',
      'gradient': [Color(0xFF9C27B0), Color(0xFFBA68C8)],
      'shadow': Color(0xFF9C27B0),
    },
    {
      'id': 'colors',
      'title': 'Colors',
      'emoji': '🌈',
      'subtitle': 'Red, blue & bright hues!',
      'gradient': [Color(0xFFFF5277), Color(0xFFFF7A45)],
      'shadow': Color(0xFFFF5277),
    },
    {
      'id': 'fruits',
      'title': 'Fruits',
      'emoji': '🍎',
      'subtitle': 'Apples, mangoes & berries!',
      'gradient': [Color(0xFF00B074), Color(0xFF52D68A)],
      'shadow': Color(0xFF00B074),
    },
    {
      'id': 'animals',
      'title': 'Animals',
      'emoji': '🦁',
      'subtitle': 'Lions, puppies & pandas!',
      'gradient': [Color(0xFFFF9500), Color(0xFFFF5E3A)],
      'shadow': Color(0xFFFF9500),
    },
    {
      'id': 'vehicles',
      'title': 'Vehicles',
      'emoji': '🚗',
      'subtitle': 'Cars, trains & rockets!',
      'gradient': [Color(0xFF0088FF), Color(0xFF00C6FF)],
      'shadow': Color(0xFF0088FF),
    },
    {
      'id': 'shapes',
      'title': 'Shapes',
      'emoji': '⭐',
      'subtitle': 'Stars, moons & patterns!',
      'gradient': [Color(0xFF5E35B1), Color(0xFF7E57C2)],
      'shadow': Color(0xFF5E35B1),
    },
  ];

  final Map<String, int> _starTotals = {};
  int _totalStars = 0;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    int total = 0;
    for (final cat in _categories) {
      final stars = await StorageService.getStars(cat['id'] as String);
      _starTotals[cat['id'] as String] = stars;
      total += stars;
    }
    final sound = await StorageService.getSoundEnabled();
    if (mounted) {
      setState(() {
        _totalStars = total;
        _soundEnabled = sound;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next ? '🔊 Sound & Music turned ON' : '🔇 Sound & Music muted'),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  void _openGame(String categoryId) async {
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
    SoundService.playHomeMusic();
    _loadState();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft ambient cartoon backdrop (PRD Section 25)
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'assets/images/backgrounds/bg_1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Standardized Preschool Header (PRD Section 4)
                GiggleHeader(
                  totalStars: _totalStars,
                  soundEnabled: _soundEnabled,
                  onToggleSound: _toggleSound,
                  onOpenSettings: _openParentArea,
                ),

                // Dedicated Preschool Welcome Banner (PRD Section 5)
                const WelcomeBanner(),

                // Category Section Header (PRD Section 41)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.xs,
                    AppSpacing.base,
                    AppSpacing.xs,
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'CHOOSE A CATEGORY',
                        style: TextStyle(
                          fontFamily: AppTypography.fontDisplay,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF64748B),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // 6 Game Cards Grid (2 columns x 3 rows, PRD Section 6)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: _buildGrid(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: [
        // Row 1: Alphabet & Colors
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCard(_categories[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildCard(_categories[1])),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Row 2: Fruits & Animals
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCard(_categories[2])),
              const SizedBox(width: 12),
              Expanded(child: _buildCard(_categories[3])),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Row 3: Vehicles & Shapes
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildCard(_categories[4])),
              const SizedBox(width: 12),
              Expanded(child: _buildCard(_categories[5])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> cat) {
    return GameCard(
      emoji: cat['emoji'] as String,
      title: cat['title'] as String,
      subtitle: cat['subtitle'] as String?,
      categoryId: cat['id'] as String?,
      gradientColors: cat['gradient'] as List<Color>,
      shadowColor: cat['shadow'] as Color,
      totalStars: _starTotals[cat['id']] ?? 0,
      onTap: () => _openGame(cat['id'] as String),
    );
  }
}

/// Sleek, minimalist adult math challenge (Parental Gate).
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
