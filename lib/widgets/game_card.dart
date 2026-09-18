import 'package:flutter/material.dart';
import '../data/category_meta.dart';
import '../services/sound_service.dart';
import '../theme/tokens.dart';
import 'game_graphic.dart';
import 'progress_badge.dart';

/// Standardized Category Card for the Home Screen Grid (PRD Sections 6, 7, 8 & Improvement PRD Section 3.3).
/// Employs a toddler-first layout:
/// - Large centered artwork container (white circular backing)
/// - Short one-word title with zero subtitle noise
/// - Progress badge (stars)
/// - Minimum 120dp tap area and accessible semantics
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
  final bool showSubtitle;

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
    this.showSubtitle = false,
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
    if (widget.categoryId == null || widget.categoryId!.isEmpty) return null;
    return getCategoryMeta(widget.categoryId!).iconPath;
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
    return Semantics(
      button: true,
      label: '${widget.title}, ${widget.totalStars} stars earned',
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.minCardTap),
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
                // Soft ambient background circles
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

                // Top-Right Progress Badge
                Positioned(
                  top: AppSpacing.sm + 2,
                  right: AppSpacing.sm + 2,
                  child: ProgressBadge(count: widget.totalStars),
                ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: widget.isHorizontal
                      ? _buildHorizontalContent()
                      : _buildVerticalContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive artwork sizing ensuring comfortable space for title
        final artworkSize = constraints.maxHeight < 135
            ? 56.0
            : constraints.maxHeight < 160
                ? 66.0
                : 76.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Centered Artwork Zone
            Center(child: _buildArtwork(size: artworkSize)),

            const Spacer(flex: 3),

            // Short Single-Word Title (centered)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                widget.title,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (widget.showSubtitle && widget.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.subtitle!,
                style: AppTypography.cardSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const Spacer(flex: 1),
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
              if (widget.showSubtitle && widget.subtitle != null) ...[
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
