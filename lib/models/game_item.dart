/// Represents a single learnable item in any game category.
class GameItem {
  final String emoji;
  final String name;
  final String category;
  final String? imagePath;
  final String? subtitle;

  const GameItem({
    required this.emoji,
    required this.name,
    required this.category,
    this.imagePath,
    this.subtitle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameItem &&
          runtimeType == other.runtimeType &&
          name.toLowerCase() == other.name.toLowerCase() &&
          category.toLowerCase() == other.category.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode ^ category.toLowerCase().hashCode;

  @override
  String toString() => 'GameItem(name: $name, category: $category, image: $imagePath)';
}
