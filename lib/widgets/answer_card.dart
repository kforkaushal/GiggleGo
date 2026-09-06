import 'package:flutter/material.dart';

/// A tappable card for an answer choice in the game.
/// Phase 1: stub. Full implementation in Phase 2.
class AnswerCard extends StatelessWidget {
  final String emoji;
  final String name;
  final VoidCallback onTap;
  final bool? isCorrect; // null = unanswered, true = correct, false = wrong

  const AnswerCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.onTap,
    this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF37474F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
