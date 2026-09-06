import 'dart:math';
import 'package:flutter/material.dart';

/// A particle in the confetti explosion
class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double vRotation;
  double size;
  Color color;
  int shapeType; // 0 = circle, 1 = star, 2 = ribbon

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.vRotation,
    required this.size,
    required this.color,
    required this.shapeType,
  });
}

/// A lightweight, flutter-native celebration confetti burst.
class ConfettiBurst extends StatefulWidget {
  final bool isPlaying;
  final Widget child;

  const ConfettiBurst({
    super.key,
    required this.isPlaying,
    required this.child,
  });

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _rnd = Random();

  static const List<Color> _palette = [
    Color(0xFFFF5277),
    Color(0xFFFFB300),
    Color(0xFF00B074),
    Color(0xFF0088FF),
    Color(0xFFAA00FF),
    Color(0xFFFF3D00),
    Color(0xFF00E5FF),
    Color(0xFFFF4081),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(_tick);
  }

  @override
  void didUpdateWidget(covariant ConfettiBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _spawnBurst();
    }
  }

  void _spawnBurst() {
    _particles.clear();
    const count = 45;
    for (int i = 0; i < count; i++) {
      final angle = _rnd.nextDouble() * pi * 2;
      final speed = 120.0 + _rnd.nextDouble() * 320.0;
      _particles.add(_ConfettiParticle(
        x: 0,
        y: 0,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 150.0, // slight upward bias
        rotation: _rnd.nextDouble() * pi * 2,
        vRotation: (_rnd.nextDouble() - 0.5) * 8.0,
        size: 7.0 + _rnd.nextDouble() * 8.0,
        color: _palette[_rnd.nextInt(_palette.length)],
        shapeType: _rnd.nextInt(3),
      ));
    }
    _controller.forward(from: 0.0);
  }

  void _tick() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        if (_controller.isAnimating)
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _controller.value,
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final dt = progress;
    final alpha = (1.0 - progress * 0.9).clamp(0.0, 1.0);

    for (final p in particles) {
      final x = center.dx + p.vx * dt;
      // Physics: y position with downward gravity
      final y = center.dy + p.vy * dt + 0.5 * 500.0 * dt * dt;
      final rot = p.rotation + p.vRotation * dt;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      if (p.shapeType == 0) {
        // Circle
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      } else if (p.shapeType == 1) {
        // Star
        _drawStar(canvas, p.size, paint);
      } else {
        // Ribbon / rectangle
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size * 1.4, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    const points = 5;
    final outerR = size * 0.7;
    final innerR = outerR * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * pi / points) - (pi / 2);
      final x = r * cos(angle);
      final y = r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
