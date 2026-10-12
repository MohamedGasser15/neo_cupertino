import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/// Snackbar type for different visual styles
enum NeoSnackBarType {
  /// Default/neutral snackbar
  info,

  /// Success message (green)
  success,

  /// Warning message (orange/yellow)
  warning,

  /// Error message (red)
  error,
}

/// An adaptive snackbar that shows platform-appropriate notifications (Dynamic Island banner on iOS)
class NeoSnackBar {
  /// Shows a Neo-Cupertino iOS Dynamic Island floating banner
  static void show(
    BuildContext context, {
    required String message,
    NeoSnackBarType type = NeoSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? action,
    VoidCallback? onActionPressed,
  }) {
    _showIOSSnackBar(
      context,
      message: message,
      type: type,
      duration: duration,
      action: action,
      onActionPressed: onActionPressed,
    );
  }

  static void _showIOSSnackBar(
    BuildContext context, {
    required String message,
    required NeoSnackBarType type,
    required Duration duration,
    String? action,
    VoidCallback? onActionPressed,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _IOSSnackBar(
        message: message,
        type: type,
        duration: duration,
        action: action,
        onActionPressed: onActionPressed,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _IOSSnackBar extends StatefulWidget {
  const _IOSSnackBar({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.action,
    this.onActionPressed,
  });

  final String message;
  final NeoSnackBarType type;
  final Duration duration;
  final String? action;
  final VoidCallback? onActionPressed;
  final VoidCallback onDismiss;

  @override
  State<_IOSSnackBar> createState() => _IOSSnackBarState();
}

class _IOSSnackBarState extends State<_IOSSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    switch (widget.type) {
      case NeoSnackBarType.success:
        return isDark ? Colors.green.shade800 : Colors.green.shade600;
      case NeoSnackBarType.warning:
        return isDark ? Colors.orange.shade800 : Colors.orange.shade600;
      case NeoSnackBarType.error:
        return isDark ? Colors.red.shade800 : Colors.red.shade600;
      case NeoSnackBarType.info:
        return isDark
            ? CupertinoColors.systemGrey.darkColor
            : CupertinoColors.systemGrey.color;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NeoSnackBarType.success:
        return CupertinoIcons.check_mark_circled_solid;
      case NeoSnackBarType.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case NeoSnackBarType.error:
        return CupertinoIcons.xmark_circle_fill;
      case NeoSnackBarType.info:
        return CupertinoIcons.info_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(_getIcon(), color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.action != null) ...[
                        const SizedBox(width: 12),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          onPressed: () {
                            widget.onActionPressed?.call();
                            _dismiss();
                          },
                          child: Text(
                            widget.action!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Backward compatibility aliases
typedef AdaptiveSnackBar = NeoSnackBar;
typedef AdaptiveSnackBarType = NeoSnackBarType;
