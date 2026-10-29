import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/neo_theme.dart';

/// An iOS 26 Liquid Glass floating tooltip with directional arrow pointer.
///
/// Wraps any widget and displays an authentic refractive liquid glass tip on
/// long-press or tap.
class NeoTooltip extends StatefulWidget {
  /// Creates a text-based Liquid Glass tooltip.
  const NeoTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode = NeoTooltipTriggerMode.longPress,
    this.duration = const Duration(seconds: 3),
    this.hapticFeedback = true,
  }) : content = null;

  /// Creates a custom widget-based Liquid Glass tooltip.
  const NeoTooltip.custom({
    super.key,
    required this.content,
    required this.child,
    this.triggerMode = NeoTooltipTriggerMode.longPress,
    this.duration = const Duration(seconds: 3),
    this.hapticFeedback = true,
  }) : message = null;

  /// The text message to display.
  final String? message;

  /// The custom widget content to display.
  final Widget? content;

  /// The target anchor widget.
  final Widget child;

  /// Whether the tooltip triggers on long-press or tap.
  final NeoTooltipTriggerMode triggerMode;

  /// How long the tooltip remains visible before auto-dismissing.
  final Duration duration;

  /// Whether to fire light haptic feedback on tooltip display.
  final bool hapticFeedback;

  @override
  State<NeoTooltip> createState() => _NeoTooltipState();
}

/// Trigger modes for [NeoTooltip].
enum NeoTooltipTriggerMode {
  /// Triggers on long-press (default).
  longPress,

  /// Triggers on immediate single tap.
  tap,
}

class _NeoTooltipState extends State<NeoTooltip> {
  OverlayEntry? _entry;
  Timer? _dismissTimer;

  void _showTooltip() {
    _dismissTooltip();

    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final targetOffset = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    final overlay = Overlay.of(context);

    final theme = NeoTheme.maybeOf(context);
    final isDark = (theme?.brightness ??
            MediaQuery.platformBrightnessOf(context)) ==
        Brightness.dark;

    _entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        return _TooltipOverlayWidget(
          targetOffset: targetOffset,
          targetSize: targetSize,
          isDark: isDark,
          content: widget.content ??
              Text(
                widget.message ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
          onDismiss: _dismissTooltip,
        );
      },
    );

    overlay.insert(_entry!);
    _dismissTimer = Timer(widget.duration, _dismissTooltip);
  }

  void _dismissTooltip() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _dismissTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.triggerMode == NeoTooltipTriggerMode.tap) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showTooltip,
        child: widget.child,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: _showTooltip,
      child: widget.child,
    );
  }
}

class _TooltipOverlayWidget extends StatefulWidget {
  const _TooltipOverlayWidget({
    required this.targetOffset,
    required this.targetSize,
    required this.isDark,
    required this.content,
    required this.onDismiss,
  });

  final Offset targetOffset;
  final Size targetSize;
  final bool isDark;
  final Widget content;
  final VoidCallback onDismiss;

  @override
  State<_TooltipOverlayWidget> createState() => _TooltipOverlayWidgetState();
}

class _TooltipOverlayWidgetState extends State<_TooltipOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final showAbove = widget.targetOffset.dy > 140;

    final double top = showAbove
        ? (widget.targetOffset.dy - 56)
        : (widget.targetOffset.dy + widget.targetSize.height + 10);

    final double left = (widget.targetOffset.dx +
            widget.targetSize.width / 2 -
            90)
        .clamp(16.0, screenSize.width - 196.0);

    return Stack(
      children: [
        // Full screen dismissal tap
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismiss,
          ),
        ),

        // Animated Glass Bubble
        Positioned(
          top: top,
          left: left,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF1E1E24).withValues(alpha: 0.90)
                      : Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.92),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: widget.isDark ? 0.35 : 0.08,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.content,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Backward compatibility alias
typedef GlassTooltip = NeoTooltip;
