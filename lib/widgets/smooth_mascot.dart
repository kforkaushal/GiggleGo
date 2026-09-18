import 'dart:math';
import 'package:flutter/material.dart';

/// A 60 FPS, physics-driven animated Cat Mascot for Giggle Go!.
/// Replaces choppy raster frame-switching with silky-smooth Disney-style
/// squash-and-stretch, parabolic jumping, and organic breathing transforms.
class SmoothMascot extends StatefulWidget {
  final String action; // 'celebrate' | 'happy' | 'idle' | 'jump' | 'pointing' | 'sad' | 'thinking'
  final double size;
  final bool animate;

  const SmoothMascot({
    super.key,
    required this.action,
    this.size = 90,
    this.animate = true,
  });

  @override
  State<SmoothMascot> createState() => _SmoothMascotState();
}

class _SmoothMascotState extends State<SmoothMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _durationForAction(widget.action),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SmoothMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.action != widget.action) {
      _controller.duration = _durationForAction(widget.action);
      _controller.reset();
      if (widget.animate) {
        _controller.repeat();
      }
    }
  }

  Duration _durationForAction(String action) {
    switch (action.toLowerCase().trim()) {
      case 'celebrate':
      case 'jump':
        return const Duration(milliseconds: 750);
      case 'happy':
        return const Duration(milliseconds: 900);
      case 'pointing':
        return const Duration(milliseconds: 1100);
      case 'curious':
      case 'thinking':
        return const Duration(milliseconds: 1400);
      case 'idle':
      default:
        return const Duration(milliseconds: 2000);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _assetPath {
    final act = widget.action.toLowerCase().trim();
    if (act == 'curious') {
      return 'assets/images/mascot/thinking.png';
    }
    const valid = ['celebrate', 'happy', 'idle', 'jump', 'pointing', 'thinking'];
    final pose = valid.contains(act) ? act : 'idle';
    return 'assets/images/mascot/$pose.png';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Image.asset(
        _assetPath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final act = widget.action.toLowerCase().trim();

        double offsetY = 0;
        double scaleX = 1.0;
        double scaleY = 1.0;
        double rotation = 0;

        if (act == 'celebrate' || act == 'jump') {
          // Physics: Parabolic jump arc with squash on landing
          final jumpPhase = sin(t * pi);
          offsetY = -jumpPhase * (widget.size * 0.18);
          if (jumpPhase < 0.25) {
            // Touchdown squash
            final groundFactor = (0.25 - jumpPhase) / 0.25;
            scaleX = 1.0 + groundFactor * 0.14;
            scaleY = 1.0 - groundFactor * 0.12;
          } else {
            // Mid-air stretch
            scaleX = 0.94;
            scaleY = 1.06;
          }
          rotation = sin(t * 2 * pi) * 0.06;
        } else if (act == 'happy') {
          // Rhythmic bouncy hop
          final hop = sin(t * 2 * pi).abs();
          offsetY = -hop * (widget.size * 0.08);
          scaleX = 1.0 + sin(t * 2 * pi) * 0.04;
          scaleY = 1.0 - sin(t * 2 * pi) * 0.04;
          rotation = sin(t * 2 * pi) * 0.04;
        } else if (act == 'pointing') {
          // Cheerful waving bob
          offsetY = sin(t * 2 * pi) * (widget.size * 0.04);
          scaleX = 1.0 + sin(t * 2 * pi) * 0.03;
          scaleY = 1.0 + sin(t * 2 * pi) * 0.03;
          rotation = sin(t * pi) * 0.04;
        } else if (act == 'curious' || act == 'thinking') {
          // Curious inquisitive head-tilt with gentle encouraging movement
          final breath = sin(t * 2 * pi);
          scaleX = 1.0 + breath * 0.03;
          scaleY = 1.0 + breath * 0.03;
          rotation = -0.10 + sin(t * pi) * 0.05;
          offsetY = sin(t * 2 * pi) * (widget.size * 0.02);
        } else {
          // Idle breathing
          final breath = sin(t * 2 * pi);
          offsetY = breath * (widget.size * 0.02);
          scaleX = 1.0 + breath * 0.025;
          scaleY = 1.0 - breath * 0.025;
        }

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scaleX: scaleX,
              scaleY: scaleY,
              child: Image.asset(
                _assetPath,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}
