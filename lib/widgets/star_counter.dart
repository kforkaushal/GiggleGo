import 'package:flutter/material.dart';

/// Displays the current star count with a star icon and animated pop effect.
class StarCounter extends StatefulWidget {
  final int count;
  final bool isCompact;

  const StarCounter({
    super.key,
    required this.count,
    this.isCompact = false,
  });

  @override
  State<StarCounter> createState() => _StarCounterState();
}

class _StarCounterState extends State<StarCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    _prevCount = widget.count;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant StarCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != _prevCount) {
      _prevCount = widget.count;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isCompact ? 10 : 13,
          vertical: widget.isCompact ? 5 : 7,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFB300), // Amber Gold
              Color(0xFFFFA000), // Rich Gold
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB300).withValues(alpha: 0.38),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 5),
            Text(
              '${widget.count}',
              style: TextStyle(
                fontSize: widget.isCompact ? 15 : 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
