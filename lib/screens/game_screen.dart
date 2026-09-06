import 'package:flutter/material.dart';

/// Game screen — full implementation in Phase 2.
/// Phase 1: stub that displays the category name and a back button.
class GameScreen extends StatelessWidget {
  final String categoryId;

  const GameScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFAB40),
        foregroundColor: Colors.white,
        title: Text(
          categoryId.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚧', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Game coming in Phase 2!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: $categoryId',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAB40),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Back to Home',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
