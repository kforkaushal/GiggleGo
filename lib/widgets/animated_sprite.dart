import 'package:flutter/material.dart';

/// A lightweight, 60fps frame-sequence animated sprite widget for Giggle Go!.
/// Animates through multi-frame PNG sequences (Appear, Mascot poses, Alphabet Pop/Bounce).
class AnimatedSprite extends StatefulWidget {
  final List<String> frames;
  final Duration duration;
  final bool repeat;
  final double? width;
  final double? height;
  final BoxFit fit;
  final VoidCallback? onComplete;

  const AnimatedSprite({
    super.key,
    required this.frames,
    this.duration = const Duration(milliseconds: 550),
    this.repeat = false,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.onComplete,
  });

  /// Factory to animate an object's popping "Appear" sequence (8 frames).
  factory AnimatedSprite.appear({
    Key? key,
    required String objectName,
    double? size,
    Duration duration = const Duration(milliseconds: 500),
    VoidCallback? onComplete,
  }) {
    final norm = objectName
        .toLowerCase()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('watermelone', 'watermelon');
    final frames = List.generate(8, (i) => 'assets/images/appear/${norm}_$i.png');
    return AnimatedSprite(
      key: key ?? ValueKey('appear_$norm'),
      frames: frames,
      duration: duration,
      repeat: false,
      width: size,
      height: size,
      onComplete: onComplete,
    );
  }

  /// Factory to animate the Cat mascot in action (celebrate, jump, happy, thinking, sad, idle).
  factory AnimatedSprite.mascot({
    Key? key,
    required String action,
    double? size,
    bool repeat = true,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    final act = action.toLowerCase().trim();
    final frames = List.generate(8, (i) => 'assets/images/mascot_seq/${act}_$i.png');
    return AnimatedSprite(
      key: key ?? ValueKey('mascot_$act'),
      frames: frames,
      duration: duration,
      repeat: repeat,
      width: size,
      height: size,
    );
  }

  /// Factory to animate an Alphabet letter popping in or bouncing (8 frames).
  factory AnimatedSprite.alphabet({
    Key? key,
    required String letter,
    bool bounce = false,
    double? size,
    bool repeat = false,
    Duration duration = const Duration(milliseconds: 450),
    VoidCallback? onComplete,
  }) {
    final l = letter.toLowerCase().trim();
    final mode = bounce ? 'bounce' : 'pop';
    final frames = List.generate(8, (i) => 'assets/images/alphabet_seq/${l}_${mode}_$i.png');
    return AnimatedSprite(
      key: key ?? ValueKey('alphabet_${l}_$mode'),
      frames: frames,
      duration: duration,
      repeat: repeat,
      width: size,
      height: size,
      onComplete: onComplete,
    );
  }

  @override
  State<AnimatedSprite> createState() => _AnimatedSpriteState();
}

class _AnimatedSpriteState extends State<AnimatedSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frames != widget.frames || oldWidget.repeat != widget.repeat) {
      _controller.duration = widget.duration;
      _controller.reset();
      if (widget.repeat) {
        _controller.repeat();
      } else {
        _controller.forward().then((_) {
          widget.onComplete?.call();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final frameCount = widget.frames.length;
        int frameIndex = (_controller.value * (frameCount - 1)).floor();
        if (frameIndex >= frameCount) frameIndex = frameCount - 1;
        final assetPath = widget.frames[frameIndex];

        return Image.asset(
          assetPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) {
            // Graceful fallback to the last frame or placeholder
            return Image.asset(
              widget.frames.last,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
