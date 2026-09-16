import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'smooth_mascot.dart';

/// Dedicated Preschool Welcome Banner (PRD Section 5).
/// Guaranteed to render immediately on Home screen load without async delay.
class WelcomeBanner extends StatelessWidget {
  final String greeting;
  final String message;

  const WelcomeBanner({
    super.key,
    this.greeting = 'Hi friend! 👋',
    this.message = 'Pick a card to learn & play! ✨',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm + 2,
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
        children: [
          // Friendly Companion Cat Mascot
          const SizedBox(
            width: 58,
            height: 58,
            child: SmoothMascot(
              action: 'happy',
              size: 58,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Greeting & Instruction
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontDisplay,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7C3AED),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontBody,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
