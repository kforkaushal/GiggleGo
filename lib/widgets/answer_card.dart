import 'package:flutter/material.dart';
import '../models/game_item.dart';
import '../services/sound_service.dart';
import 'game_graphic.dart';
import 'smooth_graphic.dart';

/// Card state representing choice status.
enum CardState { idle, correct, wrong }

/// A modern, tactile, child-friendly tappable choice card.
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
    final imageWidget = widget.item.imagePath != null
        ? Image.asset(
            widget.item.imagePath!,
            width: 52,
            height: 52,
            fit: BoxFit.contain,
          )
        : GameGraphic.fromItem(widget.item, size: 52);

    if (widget.state == CardState.correct) {
      return SmoothGraphic(
        key: ValueKey('card_correct_${widget.item.name}'),
        size: 52,
        popOnEntry: true,
        autoFloat: false,
        child: imageWidget,
      );
    }

    return SizedBox(
      width: 52,
      height: 52,
      child: Center(child: imageWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE2E8F0);
    Color shadowColor = Colors.black.withValues(alpha: 0.06);
    double borderWidth = 2.0;

    if (widget.state == CardState.correct) {
      bgColor = const Color(0xFFE8F8EE);
      borderColor = const Color(0xFF2E7D32);
      borderWidth = 3.0;
      shadowColor = const Color(0xFF2E7D32).withValues(alpha: 0.25);
    } else if (widget.state == CardState.wrong) {
      bgColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFE53935);
      borderWidth = 3.0;
      shadowColor = const Color(0xFFE53935).withValues(alpha: 0.22);
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 14,
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
                children: [
                  // Rich custom illustrated graphic or popping/bouncing animated sprite!
                  _buildCardGraphic(),
                  const SizedBox(height: 8),
                  // Clear high-contrast name
                  Text(
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
                    overflow: TextOverflow.ellipsis,
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
                    width: 22,
                    height: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
