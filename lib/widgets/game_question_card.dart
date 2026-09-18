import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Centered Question Prompt Card for Gameplay (PRD Section 17 & V2 Add-on #1).
/// Provides high-contrast, uncluttered target question with semantic keyword accent
/// and a persistent "Hear it again" speaker replay button for pre-readers.
class GameQuestionCard extends StatelessWidget {
  final String targetName;
  final String? subtitleHint;
  final Color accentColor;
  final VoidCallback? onReplayPrompt;

  const GameQuestionCard({
    super.key,
    required this.targetName,
    this.subtitleHint,
    required this.accentColor,
    this.onReplayPrompt,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
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
              if (onReplayPrompt != null) ...[
                const SizedBox(width: AppSpacing.md),
                Semantics(
                  button: true,
                  label: 'Hear $targetName again',
                  child: GestureDetector(
                    onTap: onReplayPrompt,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
