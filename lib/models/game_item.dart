/// Represents a single learnable item in any game category.
class GameItem {
  final String emoji;
  final String name;
  final String category;

  const GameItem({
    required this.emoji,
    required this.name,
    required this.category,
  });
}
