import 'package:flutter/material.dart';

/// Canonical metadata model for Giggle Go! learning categories.
/// Acts as the single source of truth for category IDs, names, display styling,
/// and developmentally-appropriate single-object hero artwork (PRD Section 4.1).
class CategoryMeta {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final Color shadow;
  final String iconPath;

  const CategoryMeta({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.shadow,
    required this.iconPath,
  });
}

/// The 6 canonical learning categories in Giggle Go!
/// Standardized on single-object icons (apple, lion, bus, star, red, a)
/// to eliminate cognitive overload for 2–3 year old toddlers.
const List<CategoryMeta> allCategories = [
  CategoryMeta(
    id: 'alphabet',
    title: 'ABC',
    subtitle: 'Learn letters A to Z',
    emoji: '🅰️',
    gradient: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
    shadow: Color(0xFF9C27B0),
    iconPath: 'assets/images/alphabet/a.png',
  ),
  CategoryMeta(
    id: 'colors',
    title: 'Colors',
    subtitle: 'Bright & colorful world',
    emoji: '🌈',
    gradient: [Color(0xFFFF5277), Color(0xFFFF7A45)],
    shadow: Color(0xFFFF5277),
    iconPath: 'assets/images/items/colors/red.png',
  ),
  CategoryMeta(
    id: 'fruits',
    title: 'Fruits',
    subtitle: 'Yummy healthy fruits',
    emoji: '🍎',
    gradient: [Color(0xFF00B074), Color(0xFF52D68A)],
    shadow: Color(0xFF00B074),
    iconPath: 'assets/images/items/fruits/apple.png',
  ),
  CategoryMeta(
    id: 'animals',
    title: 'Animals',
    subtitle: 'Cute animal friends',
    emoji: '🦁',
    gradient: [Color(0xFFFF9500), Color(0xFFFF5E3A)],
    shadow: Color(0xFFFF9500),
    iconPath: 'assets/images/items/animals/lion.png',
  ),
  CategoryMeta(
    id: 'vehicles',
    title: 'Vehicles',
    subtitle: 'Zooming cars & trains',
    emoji: '🚗',
    gradient: [Color(0xFF0088FF), Color(0xFF00C6FF)],
    shadow: Color(0xFF0088FF),
    iconPath: 'assets/images/items/vehicles/bus.png',
  ),
  CategoryMeta(
    id: 'shapes',
    title: 'Shapes',
    subtitle: 'Stars, circles & more',
    emoji: '⭐',
    gradient: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
    shadow: Color(0xFF5E35B1),
    iconPath: 'assets/images/items/shapes/star.png',
  ),
];

/// Helper to look up CategoryMeta by category ID with fallback.
CategoryMeta getCategoryMeta(String id) {
  return allCategories.firstWhere(
    (c) => c.id == id,
    orElse: () => allCategories.first,
  );
}
