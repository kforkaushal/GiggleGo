import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'star_counter.dart';

/// Standardized Preschool Header (PRD Section 4 & Improvement PRD Section 3.2).
/// Ensures brand identity remains prominent while providing generous 56dp+ touch targets for toddlers,
/// responsive title scaling on narrow screens, and discreet parent controls.
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;
    final isUltraCompact = screenWidth < 340;

    return Container(
      constraints: const BoxConstraints(minHeight: 72, maxHeight: 88),
      padding: EdgeInsets.fromLTRB(
        isUltraCompact ? AppSpacing.xs + 2 : (isCompact ? AppSpacing.sm : AppSpacing.base),
        AppSpacing.sm,
        isUltraCompact ? AppSpacing.xs + 2 : (isCompact ? AppSpacing.sm : AppSpacing.base),
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Left: Back button OR Brand Identity
          if (onBack != null) ...[
            _buildCircleIconButton(
              icon: Image.asset(
                'assets/images/ui/btn_back.png',
                width: isCompact ? 38 : 44,
                height: isCompact ? 38 : 44,
                fit: BoxFit.contain,
              ),
              onTap: onBack!,
              size: isCompact ? 44 : AppSizes.minTouchTarget,
              semanticsLabel: 'Back',
            ),
            SizedBox(width: isCompact ? AppSpacing.xs : AppSpacing.sm),
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  style: AppTypography.screenTitle.copyWith(
                    fontSize: AppTypography.responsiveTitleSize(screenWidth),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
          ] else ...[
            // Dominant Giggle Go! Brand Group (Flexible to avoid overflow)
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: isUltraCompact ? 36 : (isCompact ? 40 : 48),
                    height: isUltraCompact ? 36 : (isCompact ? 40 : 48),
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: isUltraCompact ? 4 : AppSpacing.xs),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Giggle Go!',
                        style: AppTypography.brand.copyWith(
                          fontSize: isUltraCompact ? 20 : (isCompact ? 22 : 26),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(width: isCompact ? 4 : AppSpacing.sm),

          // Right: Secondary controls [ Sound (56dp target) ] [ Stars ] [ Parent ]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Child Sound Toggle (Responsive: 48dp on compact, 56dp on standard/tablet)
              _buildCircleIconButton(
                size: isUltraCompact ? 46 : (isCompact ? 50 : AppSizes.soundButtonTarget),
                icon: Icon(
                  soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  size: isCompact ? 22 : 26,
                  color: soundEnabled ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                ),
                onTap: onToggleSound,
                semanticsLabel: soundEnabled ? 'Mute sound' : 'Turn sound on',
              ),
              SizedBox(width: isUltraCompact ? 4 : (isCompact ? 6 : AppSpacing.sm)),

              // Star Counter (passes isCompact flag)
              StarCounter(
                count: totalStars,
                isCompact: isCompact,
              ),

              // Quiet Parent Settings Button
              if (onOpenSettings != null) ...[
                SizedBox(width: isUltraCompact ? 4 : (isCompact ? 6 : AppSpacing.xs + 2)),
                _buildCircleIconButton(
                  size: isUltraCompact ? 36 : (isCompact ? 38 : 42),
                  icon: Icon(
                    Icons.family_restroom_rounded,
                    size: isCompact ? 18 : 20,
                    color: const Color(0xFF64748B),
                  ),
                  onTap: onOpenSettings!,
                  semanticsLabel: 'Parents Area',
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
    required String semanticsLabel,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
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
      ),
    );
  }
}
