import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/game_card.dart';
import '../widgets/star_counter.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';
import 'parent_area_screen.dart';

/// Home screen — shows all 5 game category cards and parental settings access.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Category metadata: id, display title, emoji, card color, shadow color
  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'colors',
      'title': 'Colors',
      'emoji': '🌈',
      'color': Color(0xFFE91E63),
      'shadow': Color(0xFFE91E63),
    },
    {
      'id': 'fruits',
      'title': 'Fruits',
      'emoji': '🍎',
      'color': Color(0xFF4CAF50),
      'shadow': Color(0xFF4CAF50),
    },
    {
      'id': 'animals',
      'title': 'Animals',
      'emoji': '🦁',
      'color': Color(0xFFFF9800),
      'shadow': Color(0xFFFF9800),
    },
    {
      'id': 'vehicles',
      'title': 'Vehicles',
      'emoji': '🚗',
      'color': Color(0xFF2196F3),
      'shadow': Color(0xFF2196F3),
    },
    {
      'id': 'shapes',
      'title': 'Shapes',
      'emoji': '⭐',
      'color': Color(0xFF9C27B0),
      'shadow': Color(0xFF9C27B0),
    },
  ];

  // Persisted star totals per category
  final Map<String, int> _starTotals = {};
  int _totalStars = 0;

  @override
  void initState() {
    super.initState();
    _loadStars();
  }

  Future<void> _loadStars() async {
    int total = 0;
    for (final cat in _categories) {
      final stars = await StorageService.getStars(cat['id'] as String);
      _starTotals[cat['id'] as String] = stars;
      total += stars;
    }
    if (mounted) {
      setState(() {
        _totalStars = total;
      });
    }
  }

  void _openGame(String categoryId) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(categoryId: categoryId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
    // Refresh stars after returning from game
    _loadStars();
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
      // Refresh stars after returning from parent area (in case of reset)
      _loadStars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            // --- Top bar ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                children: [
                  // App logo
                  Expanded(
                    child: Image.asset(
                      'assets/images/trans-logo.png',
                      height: 56,
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Total star counter
                  StarCounter(count: _totalStars),
                  const SizedBox(width: 10),
                  // Settings (parental gate) icon - low emphasis for child-safety
                  GestureDetector(
                    onTap: _openParentArea,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        size: 22,
                        color: Color(0xFF90A4AE),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'What do you want to learn today?',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF78909C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Game cards grid ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildGrid(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    // 5 cards: 2-column grid with the last card centered
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildCard(_categories[0]),
              const SizedBox(width: 12),
              _buildCard(_categories[1]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              _buildCard(_categories[2]),
              const SizedBox(width: 12),
              _buildCard(_categories[3]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 5th card centred
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 56) / 2,
                child: _buildCard(_categories[4], expanded: false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> cat, {bool expanded = true}) {
    final card = GameCard(
      emoji: cat['emoji'] as String,
      title: cat['title'] as String,
      cardColor: cat['color'] as Color,
      shadowColor: cat['shadow'] as Color,
      totalStars: _starTotals[cat['id']] ?? 0,
      onTap: () => _openGame(cat['id'] as String),
    );
    return expanded ? Expanded(child: card) : card;
  }
}

/// Simple, calm adult math check (Parental Gate).
/// Not styled for kids — no bright colors or game sounds.
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_outline, size: 20, color: Color(0xFF607D8B)),
                SizedBox(width: 8),
                Text(
                  'Parents Only',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF37474F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Please solve this question to access settings:',
              style: TextStyle(fontSize: 13, color: Color(0xFF78909C)),
            ),
            const SizedBox(height: 16),

            // Math problem display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isWrong ? const Color(0xFFEF5350) : const Color(0xFFCFD8DC),
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
                      color: Color(0xFF37474F),
                    ),
                  ),
                  Text(
                    _input.isEmpty ? '?' : _input,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _input.isEmpty
                          ? const Color(0xFF90A4AE)
                          : const Color(0xFF1E88E5),
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
                  style: TextStyle(fontSize: 12, color: Color(0xFFEF5350), fontWeight: FontWeight.w600),
                ),
              ),

            const SizedBox(height: 18),

            // Plain numeric keypad
            _buildKeypad(),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF78909C))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _input.isNotEmpty ? _check : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF455A64),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Enter', style: TextStyle(fontWeight: FontWeight.w700)),
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
            padding: const EdgeInsets.only(bottom: 6),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF37474F),
          ),
        ),
      ),
    );
  }
}
