import 'package:flutter/material.dart';

/// Result screen — full implementation in Phase 5.
/// Phase 1: stub.
class ResultScreen extends StatelessWidget {
  final String categoryId;
  final int starsEarned;

  const ResultScreen({
    super.key,
    required this.categoryId,
    required this.starsEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              'Result Screen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stars: $starsEarned — Phase 5 coming soon!',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
