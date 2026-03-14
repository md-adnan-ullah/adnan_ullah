import 'package:flutter/material.dart';

import '../utils/portfolio_theme.dart';

/// Solid card matching reference design: white/light background,
/// subtle soft shadow, no glass or blur. Optional hover lift.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 4,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: PortfolioTheme.card,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: PortfolioTheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.05),
            blurRadius: _hovered ? 24 : 16,
            offset: Offset(0, _hovered ? 8 : 4),
          ),
        ],
      ),
      child: widget.child,
    );

    final content = widget.onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              onTap: widget.onTap,
              child: card,
            ),
          );

    return Padding(
      padding: widget.margin,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: content,
      ),
    );
  }
}
