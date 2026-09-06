import 'package:flutter/material.dart';
import '../models/game_item.dart';

/// Card state representing choice status.
enum CardState { idle, correct, wrong }

/// A tappable card for an answer choice in the game.
class AnswerCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade200;
    Color shadowColor = Colors.black.withValues(alpha: 0.07);

    if (state == CardState.correct) {
      bgColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF4CAF50);
      shadowColor = const Color(0xFF4CAF50).withValues(alpha: 0.2);
    } else if (state == CardState.wrong) {
      bgColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFEF5350);
      shadowColor = const Color(0xFFEF5350).withValues(alpha: 0.2);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 6),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF37474F),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
