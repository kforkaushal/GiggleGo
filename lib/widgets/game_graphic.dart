import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_item.dart';

/// A rich, custom-illustrated vector graphic for Giggle Go! items.
/// Replaces generic plain emojis with vibrant, preschool-appealing cartoon art.
class GameGraphic extends StatelessWidget {
  final String name;
  final String category;
  final double size;
  final bool animateBounce;

  const GameGraphic({
    super.key,
    required this.name,
    required this.category,
    this.size = 60,
    this.animateBounce = false,
  });

  factory GameGraphic.fromItem(GameItem item, {double size = 60, bool animateBounce = false}) {
    return GameGraphic(
      name: item.name,
      category: item.category,
      size: size,
      animateBounce: animateBounce,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _GameGraphicPainter(
          name: name.toLowerCase().trim(),
          category: category.toLowerCase().trim(),
        ),
      ),
    );
  }
}

class _GameGraphicPainter extends CustomPainter {
  final String name;
  final String category;

  _GameGraphicPainter({required this.name, required this.category});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 100.0;

    canvas.save();
    // Category specific drawing
    if (category == 'colors') {
      _paintColorBlob(canvas, center, scale, name);
    } else if (category == 'shapes') {
      _paintShape(canvas, center, scale, name);
    } else if (category == 'fruits') {
      _paintFruit(canvas, center, scale, name);
    } else if (category == 'animals') {
      _paintAnimal(canvas, center, scale, name);
    } else if (category == 'vehicles') {
      _paintVehicle(canvas, center, scale, name);
    } else {
      // Fallback
      _paintGenericBadge(canvas, center, scale, name);
    }
    canvas.restore();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KAWAII FACE HELPER
  // ═══════════════════════════════════════════════════════════════════════════
  void _drawFace(Canvas canvas, Offset center, double scale, {
    double eyeSpread = 14.0,
    double eyeYOffset = -2.0,
    double eyeRadius = 3.5,
    bool openMouth = true,
    Color blushColor = const Color(0xFFFF8DA1),
  }) {
    final eyePaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;
    final shinePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final blushPaint = Paint()..color = blushColor.withValues(alpha: 0.5)..style = PaintingStyle.fill;
    final mouthPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round;

    final leftEye = center + Offset(-eyeSpread * scale, eyeYOffset * scale);
    final rightEye = center + Offset(eyeSpread * scale, eyeYOffset * scale);

    // Left Eye & Shine
    canvas.drawCircle(leftEye, eyeRadius * scale, eyePaint);
    canvas.drawCircle(leftEye + Offset(-1.0 * scale, -1.0 * scale), (eyeRadius * 0.4) * scale, shinePaint);

    // Right Eye & Shine
    canvas.drawCircle(rightEye, eyeRadius * scale, eyePaint);
    canvas.drawCircle(rightEye + Offset(-1.0 * scale, -1.0 * scale), (eyeRadius * 0.4) * scale, shinePaint);

    // Rosy Cheeks
    canvas.drawOval(
      Rect.fromCenter(center: leftEye + Offset(-2 * scale, 5 * scale), width: 7 * scale, height: 4 * scale),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rightEye + Offset(2 * scale, 5 * scale), width: 7 * scale, height: 4 * scale),
      blushPaint,
    );

    // Mouth
    final mouthCenter = center + Offset(0, (eyeYOffset + 6.0) * scale);
    if (openMouth) {
      final mouthPath = Path();
      mouthPath.moveTo(mouthCenter.dx - 4.5 * scale, mouthCenter.dy);
      mouthPath.quadraticBezierTo(mouthCenter.dx, mouthCenter.dy + 5.5 * scale, mouthCenter.dx + 4.5 * scale, mouthCenter.dy);
      mouthPath.close();
      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFE11D48)..style = PaintingStyle.fill);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      final mouthPath = Path();
      mouthPath.moveTo(mouthCenter.dx - 4 * scale, mouthCenter.dy);
      mouthPath.quadraticBezierTo(mouthCenter.dx, mouthCenter.dy + 4 * scale, mouthCenter.dx + 4 * scale, mouthCenter.dy);
      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  void _paintColorBlob(Canvas canvas, Offset center, double scale, String colorName) {
    Color base;
    Color dark;
    switch (colorName) {
      case 'red': base = const Color(0xFFFF3B30); dark = const Color(0xFFC70000); break;
      case 'orange': base = const Color(0xFFFF9500); dark = const Color(0xFFD65A00); break;
      case 'yellow': base = const Color(0xFFFFD600); dark = const Color(0xFFFFA000); break;
      case 'green': base = const Color(0xFF34C759); dark = const Color(0xFF1E8E3E); break;
      case 'blue': base = const Color(0xFF007AFF); dark = const Color(0xFF0044BB); break;
      case 'purple': base = const Color(0xFFAF52DE); dark = const Color(0xFF751CA8); break;
      case 'black': base = const Color(0xFF374151); dark = const Color(0xFF111827); break;
      case 'white': base = const Color(0xFFF8FAFC); dark = const Color(0xFFCBD5E1); break;
      case 'brown': base = const Color(0xFF8D6E63); dark = const Color(0xFF5D4037); break;
      case 'pink': base = const Color(0xFFFF69B4); dark = const Color(0xFFD81B60); break;
      default: base = const Color(0xFF00B074); dark = const Color(0xFF007040); break;
    }

    final radius = 38.0 * scale;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 3D Jelly gradient sphere
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 0.9,
        colors: [base, dark],
      ).createShader(rect);
    canvas.drawCircle(center, radius, bodyPaint);

    // Drop shadow glow inside
    if (colorName == 'white') {
      canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2 * scale);
    }

    // Specular highlight bubble
    final specPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(-12 * scale, -15 * scale), width: 22 * scale, height: 12 * scale),
      specPaint,
    );

    // Kawaii face
    _drawFace(canvas, center + Offset(0, 4 * scale), scale, eyeRadius: 3.8);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. SHAPES
  // ═══════════════════════════════════════════════════════════════════════════
  void _paintShape(Canvas canvas, Offset center, double scale, String shape) {
    switch (shape) {
      case 'circle':
        _drawCircleShape(canvas, center, scale);
        break;
      case 'triangle':
        _drawTriangleShape(canvas, center, scale);
        break;
      case 'square':
        _drawSquareShape(canvas, center, scale);
        break;
      case 'diamond':
        _drawDiamondShape(canvas, center, scale);
        break;
      case 'star':
        _drawStarShape(canvas, center, scale);
        break;
      case 'heart':
        _drawHeartShape(canvas, center, scale);
        break;
      case 'rectangle':
        _drawRectangleShape(canvas, center, scale);
        break;
      case 'hexagon':
        _drawHexagonShape(canvas, center, scale);
        break;
      case 'crescent':
        _drawCrescentShape(canvas, center, scale);
        break;
      case 'cross':
        _drawCrossShape(canvas, center, scale);
        break;
      default:
        _drawCircleShape(canvas, center, scale);
    }
  }

  void _drawCircleShape(Canvas canvas, Offset center, double scale) {
    final r = 38.0 * scale;
    final rect = Rect.fromCircle(center: center, radius: r);
    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawCircle(center, r, p);
    _drawFace(canvas, center, scale);
  }

  void _drawTriangleShape(Canvas canvas, Offset center, double scale) {
    final path = Path();
    path.moveTo(center.dx, center.dy - 38 * scale);
    path.lineTo(center.dx + 40 * scale, center.dy + 32 * scale);
    path.lineTo(center.dx - 40 * scale, center.dy + 32 * scale);
    path.close();

    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: 40 * scale));
    canvas.drawPath(path, p);
    _drawFace(canvas, center + Offset(0, 8 * scale), scale * 0.9);
  }

  void _drawSquareShape(Canvas canvas, Offset center, double scale) {
    final rect = Rect.fromCenter(center: center, width: 70 * scale, height: 70 * scale);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(16 * scale));
    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF87171), Color(0xFFDC2626)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(rrect, p);
    _drawFace(canvas, center, scale);
  }

  void _drawDiamondShape(Canvas canvas, Offset center, double scale) {
    final path = Path();
    path.moveTo(center.dx, center.dy - 40 * scale);
    path.lineTo(center.dx + 38 * scale, center.dy);
    path.lineTo(center.dx, center.dy + 40 * scale);
    path.lineTo(center.dx - 38 * scale, center.dy);
    path.close();

    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: 40 * scale));
    canvas.drawPath(path, p);
    _drawFace(canvas, center, scale * 0.9);
  }

  void _drawStarShape(Canvas canvas, Offset center, double scale) {
    final path = Path();
    const points = 5;
    final outerR = 40.0 * scale;
    final innerR = 18.0 * scale;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * pi / points) - (pi / 2);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE047), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: outerR));
    canvas.drawPath(path, p);
    _drawFace(canvas, center + Offset(0, 3 * scale), scale * 0.85);
  }

  void _drawHeartShape(Canvas canvas, Offset center, double scale) {
    final path = Path();
    final w = 72 * scale;
    final h = 68 * scale;
    final top = center.dy - h * 0.45;
    final left = center.dx - w * 0.5;

    path.moveTo(center.dx, top + h * 0.35);
    path.cubicTo(left, top, left, top + h * 0.6, center.dx, top + h);
    path.cubicTo(left + w, top + h * 0.6, left + w, top, center.dx, top + h * 0.35);
    path.close();

    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: 40 * scale));
    canvas.drawPath(path, p);
    _drawFace(canvas, center + Offset(0, -2 * scale), scale * 0.9);
  }

  void _drawRectangleShape(Canvas canvas, Offset center, double scale) {
    final rect = Rect.fromCenter(center: center, width: 78 * scale, height: 52 * scale);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(14 * scale));
    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(rrect, p);
    _drawFace(canvas, center, scale);
  }

  void _drawHexagonShape(Canvas canvas, Offset center, double scale) {
    final path = Path();
    final r = 38 * scale;
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawPath(path, p);
    _drawFace(canvas, center, scale);
  }

  void _drawCrescentShape(Canvas canvas, Offset center, double scale) {
    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: 36 * scale));
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: center + Offset(16 * scale, -10 * scale), radius: 30 * scale));
    final crescent = Path.combine(PathOperation.difference, outerPath, innerPath);

    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: 36 * scale));
    canvas.drawPath(crescent, p);

    // Eyes on crescent
    final eyePaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;
    canvas.drawCircle(center + Offset(-12 * scale, 0), 3 * scale, eyePaint);
    canvas.drawCircle(center + Offset(-4 * scale, 12 * scale), 3 * scale, eyePaint);
  }

  void _drawCrossShape(Canvas canvas, Offset center, double scale) {
    final path = Path();
    final arm = 14 * scale;
    final len = 38 * scale;

    path.moveTo(center.dx - arm, center.dy - len);
    path.lineTo(center.dx + arm, center.dy - len);
    path.lineTo(center.dx + arm, center.dy - arm);
    path.lineTo(center.dx + len, center.dy - arm);
    path.lineTo(center.dx + len, center.dy + arm);
    path.lineTo(center.dx + arm, center.dy + arm);
    path.lineTo(center.dx + arm, center.dy + len);
    path.lineTo(center.dx - arm, center.dy + len);
    path.lineTo(center.dx - arm, center.dy + arm);
    path.lineTo(center.dx - len, center.dy + arm);
    path.lineTo(center.dx - len, center.dy - arm);
    path.lineTo(center.dx - arm, center.dy - arm);
    path.close();

    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: len));
    canvas.drawPath(path, p);
    _drawFace(canvas, center, scale * 0.85);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. FRUITS
  // ═══════════════════════════════════════════════════════════════════════════
  void _paintFruit(Canvas canvas, Offset center, double scale, String fruit) {
    switch (fruit) {
      case 'apple':
        _drawApple(canvas, center, scale);
        break;
      case 'banana':
        _drawBanana(canvas, center, scale);
        break;
      case 'orange':
        _drawOrange(canvas, center, scale);
        break;
      case 'grapes':
        _drawGrapes(canvas, center, scale);
        break;
      case 'strawberry':
        _drawStrawberry(canvas, center, scale);
        break;
      case 'watermelon':
        _drawWatermelon(canvas, center, scale);
        break;
      case 'pineapple':
        _drawPineapple(canvas, center, scale);
        break;
      case 'mango':
        _drawMango(canvas, center, scale);
        break;
      case 'cherry':
        _drawCherry(canvas, center, scale);
        break;
      case 'lemon':
        _drawLemon(canvas, center, scale);
        break;
      case 'blueberry':
        _drawBlueberry(canvas, center, scale);
        break;
      case 'peach':
        _drawPeach(canvas, center, scale);
        break;
      default:
        _drawApple(canvas, center, scale);
    }
  }

  void _drawApple(Canvas canvas, Offset center, double scale) {
    // Body
    final path = Path();
    path.moveTo(center.dx, center.dy - 20 * scale);
    path.cubicTo(center.dx + 42 * scale, center.dy - 35 * scale, center.dx + 42 * scale, center.dy + 35 * scale, center.dx, center.dy + 35 * scale);
    path.cubicTo(center.dx - 42 * scale, center.dy + 35 * scale, center.dx - 42 * scale, center.dy - 35 * scale, center.dx, center.dy - 20 * scale);
    path.close();

    final p = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFFFF3B30), Color(0xFFB71C1C)],
      ).createShader(Rect.fromCircle(center: center, radius: 40 * scale));
    canvas.drawPath(path, p);

    // Leaf & Stem
    final stemPaint = Paint()..color = const Color(0xFF5D4037)..strokeWidth = 3 * scale..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(center + Offset(0, -20 * scale), center + Offset(3 * scale, -34 * scale), stemPaint);

    final leafPath = Path();
    leafPath.moveTo(center.dx + 3 * scale, center.dy - 26 * scale);
    leafPath.quadraticBezierTo(center.dx + 18 * scale, center.dy - 36 * scale, center.dx + 22 * scale, center.dy - 24 * scale);
    leafPath.quadraticBezierTo(center.dx + 12 * scale, center.dy - 20 * scale, center.dx + 3 * scale, center.dy - 26 * scale);
    canvas.drawPath(leafPath, Paint()..color = const Color(0xFF4CAF50));

    _drawFace(canvas, center + Offset(0, 4 * scale), scale);
  }

  void _drawBanana(Canvas canvas, Offset center, double scale) {
    final path = Path();
    path.moveTo(center.dx - 30 * scale, center.dy - 26 * scale);
    path.quadraticBezierTo(center.dx + 25 * scale, center.dy - 28 * scale, center.dx + 32 * scale, center.dy + 26 * scale);
    path.quadraticBezierTo(center.dx + 10 * scale, center.dy + 12 * scale, center.dx - 30 * scale, center.dy - 26 * scale);
    path.close();

    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE047), Color(0xFFEAB308)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: 40 * scale));
    canvas.drawPath(path, p);

    // Banana stem
    canvas.drawCircle(center + Offset(-30 * scale, -26 * scale), 4 * scale, Paint()..color = const Color(0xFF65A30D));
    _drawFace(canvas, center + Offset(2 * scale, -2 * scale), scale * 0.85);
  }

  void _drawOrange(Canvas canvas, Offset center, double scale) {
    final r = 36 * scale;
    final p = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFFFFA000), Color(0xFFE65100)],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, p);

    // Green leaf on top
    final leaf = Path()
      ..moveTo(center.dx, center.dy - r + 2 * scale)
      ..quadraticBezierTo(center.dx + 14 * scale, center.dy - r - 12 * scale, center.dx + 18 * scale, center.dy - r + 2 * scale)
      ..close();
    canvas.drawPath(leaf, Paint()..color = const Color(0xFF43A047));

    _drawFace(canvas, center + Offset(0, 2 * scale), scale);
  }

  void _drawGrapes(Canvas canvas, Offset center, double scale) {
    final p = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFA855F7), Color(0xFF6B21A8)],
      ).createShader(Rect.fromCircle(center: center, radius: 36 * scale));

    final berryR = 12.0 * scale;
    final offsets = [
      Offset(-14 * scale, -14 * scale), Offset(0, -16 * scale), Offset(14 * scale, -14 * scale),
      Offset(-8 * scale, 0), Offset(8 * scale, 0),
      Offset(0, 16 * scale),
    ];
    for (final o in offsets) {
      canvas.drawCircle(center + o, berryR, p);
    }
    _drawFace(canvas, center + Offset(0, -2 * scale), scale * 0.85);
  }

  void _drawStrawberry(Canvas canvas, Offset center, double scale) {
    final path = Path();
    path.moveTo(center.dx, center.dy + 38 * scale);
    path.cubicTo(center.dx + 38 * scale, center.dy + 10 * scale, center.dx + 30 * scale, center.dy - 24 * scale, center.dx, center.dy - 18 * scale);
    path.cubicTo(center.dx - 30 * scale, center.dy - 24 * scale, center.dx - 38 * scale, center.dy + 10 * scale, center.dx, center.dy + 38 * scale);
    path.close();

    final p = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFF2A4B), Color(0xFFBE123C)],
      ).createShader(Rect.fromCircle(center: center, radius: 40 * scale));
    canvas.drawPath(path, p);

    // Calyx green leaves
    final leafP = Paint()..color = const Color(0xFF22C55E);
    for (int i = -2; i <= 2; i++) {
      canvas.drawCircle(center + Offset(i * 9 * scale, -20 * scale), 6 * scale, leafP);
    }

    _drawFace(canvas, center + Offset(0, 6 * scale), scale * 0.9);
  }

  void _drawWatermelon(Canvas canvas, Offset center, double scale) {
    final rect = Rect.fromCircle(center: center, radius: 38 * scale);
    // Rind
    final rind = Paint()..color = const Color(0xFF16A34A)..style = PaintingStyle.fill;
    canvas.drawArc(rect, 0, pi, true, rind);

    // Inner pink flesh
    final fleshRect = Rect.fromCircle(center: center, radius: 32 * scale);
    final flesh = Paint()..color = const Color(0xFFF43F5E)..style = PaintingStyle.fill;
    canvas.drawArc(fleshRect, 0, pi, true, flesh);

    // Seeds
    final seedP = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(center + Offset(-16 * scale, 12 * scale), 2.2 * scale, seedP);
    canvas.drawCircle(center + Offset(16 * scale, 12 * scale), 2.2 * scale, seedP);

    _drawFace(canvas, center + Offset(0, 14 * scale), scale * 0.75);
  }

  void _drawPineapple(Canvas canvas, Offset center, double scale) {
    // Body
    final rect = Rect.fromCenter(center: center + Offset(0, 6 * scale), width: 50 * scale, height: 58 * scale);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(24 * scale));
    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRRect(rrect, p);

    // Crown leaves
    final leafP = Paint()..color = const Color(0xFF16A34A);
    for (int i = -1; i <= 1; i++) {
      final lPath = Path();
      lPath.moveTo(center.dx + (i * 12 * scale), center.dy - 20 * scale);
      lPath.lineTo(center.dx + (i * 18 * scale), center.dy - 38 * scale);
      lPath.lineTo(center.dx + (i * 6 * scale), center.dy - 20 * scale);
      lPath.close();
      canvas.drawPath(lPath, leafP);
    }
    _drawFace(canvas, center + Offset(0, 8 * scale), scale * 0.85);
  }

  void _drawMango(Canvas canvas, Offset center, double scale) {
    final rect = Rect.fromCenter(center: center, width: 66 * scale, height: 72 * scale);
    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFCD34D), Color(0xFFEA580C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawOval(rect, p);
    _drawFace(canvas, center, scale);
  }

  void _drawCherry(Canvas canvas, Offset center, double scale) {
    final r = 16 * scale;
    final cherryP = Paint()..color = const Color(0xFFDC2626);
    final leftCenter = center + Offset(-15 * scale, 12 * scale);
    final rightCenter = center + Offset(15 * scale, 12 * scale);
    canvas.drawCircle(leftCenter, r, cherryP);
    canvas.drawCircle(rightCenter, r, cherryP);

    // Green stems joining
    final stemP = Paint()..color = const Color(0xFF65A30D)..strokeWidth = 2.5 * scale..style = PaintingStyle.stroke;
    canvas.drawLine(leftCenter, center + Offset(0, -22 * scale), stemP);
    canvas.drawLine(rightCenter, center + Offset(0, -22 * scale), stemP);

    _drawFace(canvas, leftCenter, scale * 0.6);
    _drawFace(canvas, rightCenter, scale * 0.6);
  }

  void _drawLemon(Canvas canvas, Offset center, double scale) {
    final rect = Rect.fromCenter(center: center, width: 74 * scale, height: 52 * scale);
    final p = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFEF08A), Color(0xFFEAB308)],
      ).createShader(rect);
    canvas.drawOval(rect, p);
    _drawFace(canvas, center, scale * 0.9);
  }

  void _drawBlueberry(Canvas canvas, Offset center, double scale) {
    final r = 34 * scale;
    final p = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF60A5FA), Color(0xFF1D4ED8)],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, p);
    _drawFace(canvas, center, scale);
  }

  void _drawPeach(Canvas canvas, Offset center, double scale) {
    final r = 36 * scale;
    final p = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFDBA74), Color(0xFFFB7185)],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, p);
    _drawFace(canvas, center, scale);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. ANIMALS
  // ═══════════════════════════════════════════════════════════════════════════
  void _paintAnimal(Canvas canvas, Offset center, double scale, String animal) {
    switch (animal) {
      case 'dog': _drawDog(canvas, center, scale); break;
      case 'cat': _drawCat(canvas, center, scale); break;
      case 'cow': _drawCow(canvas, center, scale); break;
      case 'pig': _drawPig(canvas, center, scale); break;
      case 'frog': _drawFrog(canvas, center, scale); break;
      case 'lion': _drawLion(canvas, center, scale); break;
      case 'elephant': _drawElephant(canvas, center, scale); break;
      case 'penguin': _drawPenguin(canvas, center, scale); break;
      case 'fox': _drawFox(canvas, center, scale); break;
      case 'bear': _drawBear(canvas, center, scale); break;
      case 'panda': _drawPanda(canvas, center, scale); break;
      case 'butterfly': _drawButterfly(canvas, center, scale); break;
      default: _drawCat(canvas, center, scale);
    }
  }

  void _drawDog(Canvas canvas, Offset center, double scale) {
    // Face
    final faceR = 34 * scale;
    final p = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(center, faceR, p);

    // Floppy ears
    final earP = Paint()..color = const Color(0xFFB45309);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-32 * scale, -4 * scale), width: 18 * scale, height: 38 * scale), earP);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(32 * scale, -4 * scale), width: 18 * scale, height: 38 * scale), earP);

    // Snout
    canvas.drawOval(Rect.fromCenter(center: center + Offset(0, 10 * scale), width: 28 * scale, height: 20 * scale), Paint()..color = Colors.white);
    // Nose
    canvas.drawCircle(center + Offset(0, 4 * scale), 4 * scale, Paint()..color = const Color(0xFF1E293B));

    _drawFace(canvas, center + Offset(0, -2 * scale), scale * 0.95);
  }

  void _drawCat(Canvas canvas, Offset center, double scale) {
    final faceR = 34 * scale;
    canvas.drawCircle(center, faceR, Paint()..color = const Color(0xFFFB923C));

    // Pointed ears
    final earPath = Path();
    earPath.moveTo(center.dx - 28 * scale, center.dy - 18 * scale);
    earPath.lineTo(center.dx - 28 * scale, center.dy - 40 * scale);
    earPath.lineTo(center.dx - 8 * scale, center.dy - 28 * scale);
    earPath.close();
    canvas.drawPath(earPath, Paint()..color = const Color(0xFFEA580C));

    final earPathR = Path();
    earPathR.moveTo(center.dx + 28 * scale, center.dy - 18 * scale);
    earPathR.lineTo(center.dx + 28 * scale, center.dy - 40 * scale);
    earPathR.lineTo(center.dx + 8 * scale, center.dy - 28 * scale);
    earPathR.close();
    canvas.drawPath(earPathR, Paint()..color = const Color(0xFFEA580C));

    // Tiny pink nose
    canvas.drawCircle(center + Offset(0, 4 * scale), 2.5 * scale, Paint()..color = const Color(0xFFEC4899));
    _drawFace(canvas, center, scale);
  }

  void _drawCow(Canvas canvas, Offset center, double scale) {
    canvas.drawCircle(center, 34 * scale, Paint()..color = const Color(0xFFF8FAFC));
    // Spot
    canvas.drawCircle(center + Offset(-18 * scale, -14 * scale), 14 * scale, Paint()..color = const Color(0xFF1E293B));
    // Pink Muzzle
    canvas.drawOval(Rect.fromCenter(center: center + Offset(0, 14 * scale), width: 38 * scale, height: 22 * scale), Paint()..color = const Color(0xFFFBCFE8));
    _drawFace(canvas, center + Offset(0, -2 * scale), scale * 0.9);
  }

  void _drawPig(Canvas canvas, Offset center, double scale) {
    canvas.drawCircle(center, 36 * scale, Paint()..color = const Color(0xFFF472B6));
    // Ears
    canvas.drawCircle(center + Offset(-24 * scale, -28 * scale), 10 * scale, Paint()..color = const Color(0xFFDB2777));
    canvas.drawCircle(center + Offset(24 * scale, -28 * scale), 10 * scale, Paint()..color = const Color(0xFFDB2777));
    // Snout
    canvas.drawOval(Rect.fromCenter(center: center + Offset(0, 10 * scale), width: 28 * scale, height: 18 * scale), Paint()..color = const Color(0xFFFBCFE8));
    canvas.drawCircle(center + Offset(-5 * scale, 10 * scale), 2 * scale, Paint()..color = const Color(0xFF9D174D));
    canvas.drawCircle(center + Offset(5 * scale, 10 * scale), 2 * scale, Paint()..color = const Color(0xFF9D174D));
    _drawFace(canvas, center + Offset(0, -4 * scale), scale * 0.9);
  }

  void _drawFrog(Canvas canvas, Offset center, double scale) {
    // Green face
    canvas.drawOval(Rect.fromCenter(center: center + Offset(0, 4 * scale), width: 72 * scale, height: 56 * scale), Paint()..color = const Color(0xFF4ADE80));
    // Top eye bumps
    canvas.drawCircle(center + Offset(-18 * scale, -18 * scale), 14 * scale, Paint()..color = const Color(0xFF22C55E));
    canvas.drawCircle(center + Offset(18 * scale, -18 * scale), 14 * scale, Paint()..color = const Color(0xFF22C55E));
    _drawFace(canvas, center + Offset(0, 2 * scale), scale * 1.1);
  }

  void _drawLion(Canvas canvas, Offset center, double scale) {
    // Mane
    canvas.drawCircle(center, 40 * scale, Paint()..color = const Color(0xFFEA580C));
    // Face
    canvas.drawCircle(center, 28 * scale, Paint()..color = const Color(0xFFFDE047));
    _drawFace(canvas, center, scale * 0.85);
  }

  void _drawElephant(Canvas canvas, Offset center, double scale) {
    // Ears
    canvas.drawCircle(center + Offset(-28 * scale, 0), 20 * scale, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(center + Offset(28 * scale, 0), 20 * scale, Paint()..color = const Color(0xFF94A3B8));
    // Face
    canvas.drawCircle(center, 30 * scale, Paint()..color = const Color(0xFFCBD5E1));
    // Trunk
    final trunk = Path();
    trunk.moveTo(center.dx - 6 * scale, center.dy + 8 * scale);
    trunk.quadraticBezierTo(center.dx + 4 * scale, center.dy + 30 * scale, center.dx + 16 * scale, center.dy + 24 * scale);
    canvas.drawPath(trunk, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 7 * scale..strokeCap = StrokeCap.round);
    _drawFace(canvas, center + Offset(0, -6 * scale), scale * 0.85);
  }

  void _drawPenguin(Canvas canvas, Offset center, double scale) {
    // Body black
    canvas.drawOval(Rect.fromCenter(center: center, width: 64 * scale, height: 74 * scale), Paint()..color = const Color(0xFF1E293B));
    // White tummy
    canvas.drawOval(Rect.fromCenter(center: center + Offset(0, 6 * scale), width: 44 * scale, height: 54 * scale), Paint()..color = Colors.white);
    // Orange beak
    final beak = Path()
      ..moveTo(center.dx - 8 * scale, center.dy + 2 * scale)
      ..lineTo(center.dx + 8 * scale, center.dy + 2 * scale)
      ..lineTo(center.dx, center.dy + 12 * scale)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFF97316));
    _drawFace(canvas, center + Offset(0, -8 * scale), scale * 0.85, openMouth: false);
  }

  void _drawFox(Canvas canvas, Offset center, double scale) {
    canvas.drawCircle(center, 34 * scale, Paint()..color = const Color(0xFFEA580C));
    // White cheeks
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-14 * scale, 10 * scale), width: 20 * scale, height: 16 * scale), Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(14 * scale, 10 * scale), width: 20 * scale, height: 16 * scale), Paint()..color = Colors.white);
    // Black nose
    canvas.drawCircle(center + Offset(0, 8 * scale), 3 * scale, Paint()..color = const Color(0xFF1E293B));
    _drawFace(canvas, center, scale);
  }

  void _drawBear(Canvas canvas, Offset center, double scale) {
    canvas.drawCircle(center + Offset(-24 * scale, -24 * scale), 12 * scale, Paint()..color = const Color(0xFF78350F));
    canvas.drawCircle(center + Offset(24 * scale, -24 * scale), 12 * scale, Paint()..color = const Color(0xFF78350F));
    canvas.drawCircle(center, 34 * scale, Paint()..color = const Color(0xFF92400E));
    canvas.drawOval(Rect.fromCenter(center: center + Offset(0, 10 * scale), width: 28 * scale, height: 20 * scale), Paint()..color = const Color(0xFFFDE68A));
    canvas.drawCircle(center + Offset(0, 4 * scale), 4 * scale, Paint()..color = const Color(0xFF1E293B));
    _drawFace(canvas, center + Offset(0, -4 * scale), scale * 0.9);
  }

  void _drawPanda(Canvas canvas, Offset center, double scale) {
    // Black ears
    canvas.drawCircle(center + Offset(-24 * scale, -24 * scale), 12 * scale, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(center + Offset(24 * scale, -24 * scale), 12 * scale, Paint()..color = const Color(0xFF1E293B));
    // White face
    canvas.drawCircle(center, 34 * scale, Paint()..color = Colors.white);
    // Eye patches
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-12 * scale, -4 * scale), width: 14 * scale, height: 18 * scale), Paint()..color = const Color(0xFF1E293B));
    canvas.drawOval(Rect.fromCenter(center: center + Offset(12 * scale, -4 * scale), width: 14 * scale, height: 18 * scale), Paint()..color = const Color(0xFF1E293B));
    _drawFace(canvas, center, scale * 0.85);
  }

  void _drawButterfly(Canvas canvas, Offset center, double scale) {
    // Wings
    final wingP = Paint()..color = const Color(0xFFA855F7);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-22 * scale, -10 * scale), width: 28 * scale, height: 38 * scale), wingP);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(22 * scale, -10 * scale), width: 28 * scale, height: 38 * scale), wingP);
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-18 * scale, 18 * scale), width: 22 * scale, height: 26 * scale), Paint()..color = const Color(0xFFEC4899));
    canvas.drawOval(Rect.fromCenter(center: center + Offset(18 * scale, 18 * scale), width: 22 * scale, height: 26 * scale), Paint()..color = const Color(0xFFEC4899));
    // Center body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 14 * scale, height: 50 * scale), Radius.circular(8 * scale)), Paint()..color = const Color(0xFF38BDF8));
    _drawFace(canvas, center + Offset(0, -8 * scale), scale * 0.7);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. VEHICLES
  // ═══════════════════════════════════════════════════════════════════════════
  void _paintVehicle(Canvas canvas, Offset center, double scale, String vehicle) {
    switch (vehicle) {
      case 'car': _drawCar(canvas, center, scale, const Color(0xFFEF4444)); break;
      case 'taxi': _drawCar(canvas, center, scale, const Color(0xFFFBBF24)); break;
      case 'bus': _drawBus(canvas, center, scale); break;
      case 'train': _drawTrain(canvas, center, scale); break;
      case 'airplane': _drawAirplane(canvas, center, scale); break;
      case 'rocket': _drawRocket(canvas, center, scale); break;
      case 'ship': _drawShip(canvas, center, scale); break;
      case 'helicopter': _drawHelicopter(canvas, center, scale); break;
      case 'scooter': _drawScooter(canvas, center, scale); break;
      case 'fire truck': _drawFireTruck(canvas, center, scale); break;
      case 'ambulance': _drawAmbulance(canvas, center, scale); break;
      case 'tractor': _drawTractor(canvas, center, scale); break;
      default: _drawCar(canvas, center, scale, const Color(0xFF3B82F6));
    }
  }

  void _drawCar(Canvas canvas, Offset center, double scale, Color color) {
    final body = Rect.fromCenter(center: center + Offset(0, 4 * scale), width: 72 * scale, height: 36 * scale);
    canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(12 * scale)), Paint()..color = color);

    // Windshield
    final cabin = Rect.fromCenter(center: center + Offset(0, -10 * scale), width: 44 * scale, height: 26 * scale);
    canvas.drawRRect(RRect.fromRectAndRadius(cabin, Radius.circular(8 * scale)), Paint()..color = const Color(0xFFBAE6FD));

    // Wheels
    canvas.drawCircle(center + Offset(-22 * scale, 22 * scale), 10 * scale, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(center + Offset(22 * scale, 22 * scale), 10 * scale, Paint()..color = const Color(0xFF1E293B));

    _drawFace(canvas, center + Offset(0, 6 * scale), scale * 0.85);
  }

  void _drawBus(Canvas canvas, Offset center, double scale) {
    final body = Rect.fromCenter(center: center + Offset(0, -2 * scale), width: 78 * scale, height: 48 * scale);
    canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(12 * scale)), Paint()..color = const Color(0xFFFBBF24));

    // Windows
    final winP = Paint()..color = const Color(0xFFE0F2FE);
    for (int i = -1; i <= 1; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center + Offset(i * 22 * scale, -12 * scale), width: 16 * scale, height: 16 * scale), Radius.circular(4 * scale)), winP);
    }
    // Wheels
    canvas.drawCircle(center + Offset(-24 * scale, 24 * scale), 10 * scale, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(center + Offset(24 * scale, 24 * scale), 10 * scale, Paint()..color = const Color(0xFF1E293B));

    _drawFace(canvas, center + Offset(0, 10 * scale), scale * 0.85);
  }

  void _drawTrain(Canvas canvas, Offset center, double scale) {
    final body = Rect.fromCenter(center: center + Offset(0, 4 * scale), width: 70 * scale, height: 40 * scale);
    canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(10 * scale)), Paint()..color = const Color(0xFF3B82F6));

    // Smokestack
    canvas.drawRect(Rect.fromLTWH(center.dx - 26 * scale, center.dy - 30 * scale, 12 * scale, 18 * scale), Paint()..color = const Color(0xFFEF4444));
    // Wheels
    for (int i = -1; i <= 1; i++) {
      canvas.drawCircle(center + Offset(i * 22 * scale, 24 * scale), 9 * scale, Paint()..color = const Color(0xFF1E293B));
    }
    _drawFace(canvas, center + Offset(4 * scale, 6 * scale), scale * 0.8);
  }

  void _drawAirplane(Canvas canvas, Offset center, double scale) {
    // Fuselage
    final body = Rect.fromCenter(center: center, width: 78 * scale, height: 26 * scale);
    canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(14 * scale)), Paint()..color = const Color(0xFF38BDF8));

    // Wings
    final wing = Path();
    wing.moveTo(center.dx - 8 * scale, center.dy - 28 * scale);
    wing.lineTo(center.dx + 8 * scale, center.dy);
    wing.lineTo(center.dx - 8 * scale, center.dy + 28 * scale);
    wing.close();
    canvas.drawPath(wing, Paint()..color = const Color(0xFF0284C7));

    _drawFace(canvas, center + Offset(16 * scale, 0), scale * 0.7);
  }

  void _drawRocket(Canvas canvas, Offset center, double scale) {
    // Body
    final path = Path();
    path.moveTo(center.dx, center.dy - 38 * scale);
    path.cubicTo(center.dx + 24 * scale, center.dy - 10 * scale, center.dx + 22 * scale, center.dy + 22 * scale, center.dx + 18 * scale, center.dy + 28 * scale);
    path.lineTo(center.dx - 18 * scale, center.dy + 28 * scale);
    path.cubicTo(center.dx - 22 * scale, center.dy + 22 * scale, center.dx - 24 * scale, center.dy - 10 * scale, center.dx, center.dy - 38 * scale);
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFF43F5E));

    // Window Porthole
    canvas.drawCircle(center + Offset(0, -6 * scale), 10 * scale, Paint()..color = const Color(0xFFE0F2FE));

    // Flame
    final flame = Path()
      ..moveTo(center.dx - 12 * scale, center.dy + 28 * scale)
      ..lineTo(center.dx, center.dy + 42 * scale)
      ..lineTo(center.dx + 12 * scale, center.dy + 28 * scale)
      ..close();
    canvas.drawPath(flame, Paint()..color = const Color(0xFFFBBF24));

    _drawFace(canvas, center + Offset(0, 12 * scale), scale * 0.75);
  }

  void _drawShip(Canvas canvas, Offset center, double scale) {
    final hull = Path();
    hull.moveTo(center.dx - 36 * scale, center.dy);
    hull.lineTo(center.dx + 36 * scale, center.dy);
    hull.lineTo(center.dx + 26 * scale, center.dy + 24 * scale);
    hull.lineTo(center.dx - 26 * scale, center.dy + 24 * scale);
    hull.close();
    canvas.drawPath(hull, Paint()..color = const Color(0xFF0284C7));

    // Cabin
    canvas.drawRect(Rect.fromCenter(center: center + Offset(0, -10 * scale), width: 32 * scale, height: 20 * scale), Paint()..color = Colors.white);
    // Smokestack
    canvas.drawRect(Rect.fromCenter(center: center + Offset(-4 * scale, -24 * scale), width: 10 * scale, height: 14 * scale), Paint()..color = const Color(0xFFEF4444));

    _drawFace(canvas, center + Offset(0, 10 * scale), scale * 0.75);
  }

  void _drawHelicopter(Canvas canvas, Offset center, double scale) {
    // Body
    canvas.drawOval(Rect.fromCenter(center: center + Offset(-6 * scale, 4 * scale), width: 52 * scale, height: 36 * scale), Paint()..color = const Color(0xFF10B981));
    // Tail
    canvas.drawLine(center + Offset(16 * scale, 4 * scale), center + Offset(36 * scale, -4 * scale), Paint()..color = const Color(0xFF059669)..strokeWidth = 6 * scale);
    // Rotor
    canvas.drawLine(center + Offset(-30 * scale, -18 * scale), center + Offset(18 * scale, -18 * scale), Paint()..color = const Color(0xFF1E293B)..strokeWidth = 3 * scale);
    _drawFace(canvas, center + Offset(-10 * scale, 6 * scale), scale * 0.75);
  }

  void _drawScooter(Canvas canvas, Offset center, double scale) {
    canvas.drawCircle(center + Offset(-24 * scale, 18 * scale), 11 * scale, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(center + Offset(24 * scale, 18 * scale), 11 * scale, Paint()..color = const Color(0xFF1E293B));
    // Body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 44 * scale, height: 20 * scale), Radius.circular(8 * scale)), Paint()..color = const Color(0xFF06B6D4));
    _drawFace(canvas, center + Offset(0, 2 * scale), scale * 0.8);
  }

  void _drawFireTruck(Canvas canvas, Offset center, double scale) {
    _drawBus(canvas, center, scale);
    // Ladder
    canvas.drawLine(center + Offset(-24 * scale, -28 * scale), center + Offset(24 * scale, -28 * scale), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 4 * scale);
  }

  void _drawAmbulance(Canvas canvas, Offset center, double scale) {
    final body = Rect.fromCenter(center: center + Offset(0, -2 * scale), width: 78 * scale, height: 48 * scale);
    canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(12 * scale)), Paint()..color = Colors.white);
    // Red Cross
    final crossP = Paint()..color = const Color(0xFFEF4444)..strokeWidth = 4 * scale;
    canvas.drawLine(center + Offset(0, -6 * scale), center + Offset(0, 10 * scale), crossP);
    canvas.drawLine(center + Offset(-8 * scale, 2 * scale), center + Offset(8 * scale, 2 * scale), crossP);
    // Wheels
    canvas.drawCircle(center + Offset(-24 * scale, 24 * scale), 10 * scale, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(center + Offset(24 * scale, 24 * scale), 10 * scale, Paint()..color = const Color(0xFF1E293B));
  }

  void _drawTractor(Canvas canvas, Offset center, double scale) {
    // Big rear wheel
    canvas.drawCircle(center + Offset(-18 * scale, 14 * scale), 16 * scale, Paint()..color = const Color(0xFF1E293B));
    // Small front wheel
    canvas.drawCircle(center + Offset(24 * scale, 20 * scale), 10 * scale, Paint()..color = const Color(0xFF1E293B));
    // Body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center + Offset(4 * scale, 2 * scale), width: 50 * scale, height: 26 * scale), Radius.circular(6 * scale)), Paint()..color = const Color(0xFF16A34A));
    _drawFace(canvas, center + Offset(0, 2 * scale), scale * 0.75);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. GENERIC FALLBACK
  // ═══════════════════════════════════════════════════════════════════════════
  void _paintGenericBadge(Canvas canvas, Offset center, double scale, String label) {
    final r = 38 * scale;
    final p = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, p);
    _drawFace(canvas, center, scale);
  }

  @override
  bool shouldRepaint(covariant _GameGraphicPainter oldDelegate) {
    return oldDelegate.name != name || oldDelegate.category != category;
  }
}
