import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Centered Question Prompt Card for Gameplay (PRD Section 17).
/// Provides high-contrast, uncluttered target question with semantic keyword accent.
class GameQuestionCard extends StatelessWidget {
  final String targetName;
  final String? subtitleHint;
  final Color accentColor;

  const GameQuestionCard({
    super.key,
    required this.targetName,
    this.subtitleHint,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.roundedLg,
            border: Border.all(
              color: AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: AppTypography.fontBody,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  children: [
                    const TextSpan(text: 'Touch the '),
                    TextSpan(
                      text: targetName,
                      style: TextStyle(
                        fontFamily: AppTypography.fontDisplay,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                      ),
                    ),
                    const TextSpan(text: '! ✨'),
                  ],
                ),
              ),
              if (subtitleHint != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitleHint!,
                  style: TextStyle(
                    fontFamily: AppTypography.fontBody,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: accentColor.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
