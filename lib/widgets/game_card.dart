import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../theme/tokens.dart';
import 'game_graphic.dart';
import 'progress_badge.dart';

/// Standardized Category Card for the Home Screen Grid (PRD Section 6, 7, 8).
/// Employs a consistent internal layout:
/// CategoryCard
/// ├── Top-right progress badge
/// ├── Artwork zone (standardized 80–96px container with white backing)
/// ├── Title
/// └── Subtitle
class GameCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final String? categoryId;
  final List<Color> gradientColors;
  final Color shadowColor;
  final int totalStars;
  final VoidCallback onTap;
  final bool isHorizontal;

  const GameCard({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.categoryId,
    required this.gradientColors,
    required this.shadowColor,
    required this.totalStars,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      lowerBound: 0.94,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.reverse();
    SoundService.playPop();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.forward();
    widget.onTap();
  }

  void _onTapCancel() => _controller.forward();

  String? _categoryImagePath() {
    final cat = widget.categoryId ?? '';
    switch (cat) {
      case 'alphabet': return 'assets/images/alphabet/a.png';
      case 'animals': return 'assets/images/categories/animals.png';
      case 'fruits': return 'assets/images/categories/fruits.png';
      case 'vehicles': return 'assets/images/categories/vehicles.png';
      case 'shapes': return 'assets/images/categories/shapes.png';
      case 'colors': return 'assets/images/categories/colors.png';
      default: return null;
    }
  }

  String _defaultGraphicName() {
    final cat = widget.categoryId ?? '';
    switch (cat) {
      case 'alphabet': return 'letter a';
      case 'fruits': return 'apple';
      case 'colors': return 'pink';
      case 'animals': return 'lion';
      case 'vehicles': return 'car';
      case 'shapes': return 'star';
      default: return 'apple';
    }
  }

  Widget _buildArtwork({required double size}) {
    final imgPath = _categoryImagePath();
    if (imgPath != null) {
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(AppSpacing.xs + 1),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(
          imgPath,
          fit: BoxFit.contain,
        ),
      );
    }

    if (widget.categoryId != null) {
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(AppSpacing.xs + 1),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: GameGraphic(
          name: _defaultGraphicName(),
          category: widget.categoryId!,
          size: size * 0.8,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Text(
        widget.emoji,
        style: TextStyle(fontSize: size * 0.55),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
            borderRadius: AppRadius.roundedXl,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: AppShadows.categoryCard(widget.shadowColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Ambient soft background circles for texture
              Positioned(
                top: -24,
                right: -24,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -28,
                left: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Top-Right Progress Badge (PRD Section 8)
              Positioned(
                top: AppSpacing.sm + 2,
                right: AppSpacing.sm + 2,
                child: ProgressBadge(count: widget.totalStars),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.md,
                ),
                child: widget.isHorizontal
                    ? _buildHorizontalContent()
                    : _buildVerticalContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt artwork size responsively based on available card height
        final artworkSize = constraints.maxHeight < 130
            ? 52.0
            : constraints.maxHeight < 155
                ? 62.0
                : 74.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standardized Artwork Zone (PRD Section 7)
            _buildArtwork(size: artworkSize),

            const Spacer(),

            // Title
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.title,
                style: AppTypography.cardTitle,
              ),
            ),

            // Subtitle
            if (widget.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.subtitle!,
                style: AppTypography.cardSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHorizontalContent() {
    return Row(
      children: [
        _buildArtwork(size: 64),
        const SizedBox(width: AppSpacing.base),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: AppTypography.cardTitle,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: AppTypography.cardSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
