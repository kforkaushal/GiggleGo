import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../theme/tokens.dart';

/// Lightweight, high-performance graphic renderer for Giggle Go! items.
/// Renders authentic PNG assets with clean error fallback and placeholder support.
class GameGraphic extends StatelessWidget {
  final String name;
  final String category;
  final String? imagePath;
  final double size;
  final bool animateBounce;

  const GameGraphic({
    super.key,
    required this.name,
    required this.category,
    this.imagePath,
    this.size = 60,
    this.animateBounce = false,
  });

  factory GameGraphic.fromItem(
    GameItem item, {
    double size = 60,
    bool animateBounce = false,
  }) {
    return GameGraphic(
      name: item.name,
      category: item.category,
      imagePath: item.imagePath,
      size: size,
      animateBounce: animateBounce,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          imagePath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: AppTypography.fontDisplay,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
