import 'dart:math';
import 'package:flutter/material.dart';
import '../services/sound_service.dart';

/// A 60 FPS, physics-driven interactive graphic wrapper for letters, shapes, and objects.
/// Replaces choppy frame-flipping with fluid elastic scaling, squash-and-stretch,
/// and gentle organic breathing.
class SmoothGraphic extends StatefulWidget {
  final Widget child;
  final double? size;
  final bool autoFloat;
  final bool popOnEntry;
  final VoidCallback? onTap;

  const SmoothGraphic({
    super.key,
    required this.child,
    this.size,
    this.autoFloat = true,
    this.popOnEntry = true,
    this.onTap,
  });

  @override
  State<SmoothGraphic> createState() => _SmoothGraphicState();
}

class _SmoothGraphicState extends State<SmoothGraphic>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleAnim;

  AnimationController? _floatController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scaleAnim = Tween<double>(begin: widget.popOnEntry ? 0.3 : 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.popOnEntry) {
      _entryController.forward();
    }

    if (widget.autoFloat) {
      _floatController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2200),
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SmoothGraphic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.key != widget.key && widget.popOnEntry) {
      _entryController.reset();
      _entryController.forward();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController?.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _pressed = true);
    SoundService.playPop();
  }

  void _onTapUp(_) {
    setState(() => _pressed = false);
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    if (widget.size != null) {
      content = SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(child: content),
      );
    }

    // Interactive press response
    final isPressable = widget.onTap != null;
    if (isPressable) {
      content = GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: _pressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeInOut,
          child: content,
        ),
      );
    }

    // Elastic pop entry
    content = ScaleTransition(
      scale: _scaleAnim,
      child: content,
    );

    // Organic floating breathing loop
    if (widget.autoFloat && _floatController != null) {
      content = AnimatedBuilder(
        animation: _floatController!,
        builder: (context, child) {
          final val = sin(_floatController!.value * pi);
          final floatOffset = val * 3.0;
          final breathScale = 1.0 + val * 0.03;

          return Transform.translate(
            offset: Offset(0, -floatOffset),
            child: Transform.scale(
              scale: breathScale,
              child: child,
            ),
          );
        },
        child: content,
      );
    }

    return content;
  }
}
