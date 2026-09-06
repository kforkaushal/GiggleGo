import 'package:flutter/material.dart';
import '../widgets/game_card.dart';
import '../widgets/star_counter.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';
import 'parent_area_screen.dart';

/// Home screen — shows all 5 game category cards.
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

  void _openParentArea() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ParentAreaScreen()),
    );
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
                  // App title
                  const Expanded(
                    child: Text(
                      'Giggle Go! 🎉',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF37474F),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Total star counter
                  StarCounter(count: _totalStars),
                  const SizedBox(width: 10),
                  // Settings (parental gate) icon
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
