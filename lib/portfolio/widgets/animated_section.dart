import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Fades and slides a section into view when it becomes visible.
class AnimatedSection extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const AnimatedSection({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('animated-section-${widget.hashCode}'),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.15) {
          setState(() {
            _visible = true;
          });
        }
      },
      child: Animate(
        effects: [
          FadeEffect(
            duration: widget.duration,
            delay: widget.delay,
            begin: 0,
            end: 1,
          ),
          MoveEffect(
            duration: widget.duration,
            delay: widget.delay,
            begin: const Offset(0, 24),
            end: Offset.zero,
            curve: Curves.easeOutCubic,
          ),
        ],
        target: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}

