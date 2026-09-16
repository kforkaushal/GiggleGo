import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../services/sound_service.dart';
import 'game_graphic.dart';
import 'smooth_graphic.dart';

/// Card state representing choice status.
enum CardState { idle, correct, wrong }

/// A modern, tactile, child-friendly tappable choice card.
/// Keeps image backing pure white so images with cut-out eyes render with crisp white sclera.
class AnswerCard extends StatefulWidget {
  final GameItem item;
  final CardState state;
  final VoidCallback onTap;

  const AnswerCard({
    super.key,
    required this.item,
    required this.state,
    required this.onTap,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.92,
      upperBound: 1.0,
    )..value = 1.0;
    _pressScale = _pressController;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.reverse();
    SoundService.playPop();
  }
  void _onTapUp(TapUpDetails _) {
    _pressController.forward();
    widget.onTap();
  }
  void _onTapCancel() => _pressController.forward();

  Widget _buildCardGraphic() {
    // Pure solid white circular backing prevents any background bleed through transparent eyes
    final imageWidget = Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: widget.item.imagePath != null
            ? Image.asset(
                widget.item.imagePath!,
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              )
            : GameGraphic.fromItem(widget.item, size: 72),
      ),
    );

    if (widget.state == CardState.correct) {
      return SmoothGraphic(
        key: ValueKey('card_correct_${widget.item.name}'),
        size: 72,
        popOnEntry: true,
        autoFloat: false,
        child: imageWidget,
      );
    }

    return SizedBox(
      width: 72,
      height: 72,
      child: Center(child: imageWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pure white card background ensures character eyes are never tinted
    const Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE2E8F0);
    Color shadowColor = Colors.black.withValues(alpha: 0.07);
    double borderWidth = 2.0;

    if (widget.state == CardState.correct) {
      borderColor = const Color(0xFF2E7D32);
      borderWidth = 3.5;
      shadowColor = const Color(0xFF2E7D32).withValues(alpha: 0.32);
    } else if (widget.state == CardState.wrong) {
      borderColor = const Color(0xFFE53935);
      borderWidth = 3.5;
      shadowColor = const Color(0xFFE53935).withValues(alpha: 0.28);
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: widget.state != CardState.idle ? 18 : 12,
                spreadRadius: widget.state != CardState.idle ? 2 : 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rich custom illustrated graphic with guaranteed white backing
                  _buildCardGraphic(),
                  const SizedBox(height: 8),
                  // Clear high-contrast name scaled gracefully to prevent truncation
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.item.name,
                      style: TextStyle(
                        fontFamily: 'AnjaEliane',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: widget.state == CardState.correct
                            ? const Color(0xFF1B5E20)
                            : widget.state == CardState.wrong
                                ? const Color(0xFFB71C1C)
                                : const Color(0xFF334155),
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              // Golden star badge on correct selection
              if (widget.state == CardState.correct)
                Positioned(
                  top: -8,
                  right: -4,
                  child: Image.asset(
                    'assets/images/ui/star_gold.png',
                    width: 24,
                    height: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
