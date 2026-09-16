import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'star_counter.dart';

/// Standardized Preschool Header (PRD Section 4).
/// Ensures the brand identity remains dominant while organizing secondary controls.
class GiggleHeader extends StatelessWidget {
  final int totalStars;
  final bool soundEnabled;
  final VoidCallback onToggleSound;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onBack;
  final String? title;

  const GiggleHeader({
    super.key,
    required this.totalStars,
    required this.soundEnabled,
    required this.onToggleSound,
    this.onOpenSettings,
    this.onBack,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 74, maxHeight: 88),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Left: Back button OR Brand Identity
          if (onBack != null) ...[
            _buildCircleIconButton(
              icon: Image.asset(
                'assets/images/ui/btn_back.png',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
              onTap: onBack!,
              size: AppSizes.minTouchTarget,
            ),
            const SizedBox(width: AppSpacing.sm),
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  style: AppTypography.screenTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
          ] else ...[
            // Dominant Giggle Go! Brand Group (150-210px wide)
            SizedBox(
              width: 175,
              height: 54,
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Giggle Go!',
                        style: AppTypography.brand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],

          // Right: Secondary controls [ Sound ] [ Stars ] [ Settings ]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sound Toggle Button (48-52px touch target)
              _buildCircleIconButton(
                size: AppSizes.minTouchTarget,
                icon: Icon(
                  soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  size: 22,
                  color: soundEnabled ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                ),
                onTap: onToggleSound,
              ),
              const SizedBox(width: AppSpacing.sm),

              // Star Counter (90-125px)
              StarCounter(count: totalStars),

              // Optional Settings / Parent Area Button
              if (onOpenSettings != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _buildCircleIconButton(
                  size: AppSizes.minTouchTarget,
                  icon: const Icon(
                    Icons.family_restroom_rounded,
                    size: 22,
                    color: Color(0xFF64748B),
                  ),
                  onTap: onOpenSettings!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required Widget icon,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          boxShadow: AppShadows.soft,
        ),
        child: icon,
      ),
    );
  }
}
