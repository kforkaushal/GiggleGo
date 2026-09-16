import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Standardized progress badge capsule for Category Cards (PRD Section 8).
/// Positioned at the top-right of cards with secondary visual weight.
class ProgressBadge extends StatelessWidget {
  final int count;

  const ProgressBadge({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: AppRadius.roundedPill,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/ui/star_gold.png',
            width: 18,
            height: 18,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$count',
            style: AppTypography.badge,
          ),
        ],
      ),
    );
  }
}
