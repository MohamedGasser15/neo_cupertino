import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/platform_info.dart';


/// An adaptive list tile that renders platform-specific styles:
///
/// - On iOS / iOS 26: Renders native Apple-styled grouped row with SF typography,
///   indented separators, interactive press opacity/haptic feedback, and chevron indicator.
/// - On Android: Renders standard Material 3 [ListTile] with ripple effect.
class NeoListTile extends StatefulWidget {
  /// Creates a Neo-Cupertino adaptive list tile
  const NeoListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.hideBottomDivider = false,
    this.backgroundColor,
    this.separatorColor,
    this.padding,
  });

  /// A widget to display before the title.
  final Widget? leading;

  /// The primary content of the list tile.
  final Widget? title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// A widget to display after the title.
  final Widget? trailing;

  /// Called when the user taps this list tile.
  final VoidCallback? onTap;

  /// Called when the user long-presses on this list tile.
  final VoidCallback? onLongPress;

  /// Whether this list tile is interactive.
  final bool enabled;

  /// Whether this list tile is selected.
  final bool selected;

  /// Whether to hide the bottom divider (iOS only).
  final bool hideBottomDivider;

  /// The background color of the tile.
  final Color? backgroundColor;

  /// The color of the iOS bottom separator.
  final Color? separatorColor;

  /// The tile's internal padding.
  final EdgeInsetsGeometry? padding;

  @override
  State<NeoListTile> createState() => _NeoListTileState();
}

// Backward compatibility alias
typedef AdaptiveListTile = NeoListTile;

class _NeoListTileState extends State<NeoListTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS26OrHigher()) {
      return _buildNeoListTile(context);
    }
    // iOS 18 and below - Exact CupertinoListTile from adaptive_platform_ui
    return _buildCupertinoListTile(context);
  }

  Widget _buildCupertinoListTile(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    Widget child = Container(
      padding:
          widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            (widget.selected
                ? (isDark
                      ? CupertinoColors.systemGrey5.darkColor
                      : CupertinoColors.systemGrey6.color)
                : (isDark
                      ? CupertinoColors.darkBackgroundGray
                      : CupertinoColors.white)),
        border: widget.hideBottomDivider
            ? null
            : Border(
                bottom: BorderSide(
                  color:
                      widget.separatorColor ??
                      (isDark
                          ? CupertinoColors.systemGrey4
                          : CupertinoColors.separator),
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null)
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: widget.enabled
                          ? (isDark
                                ? CupertinoColors.white
                                : CupertinoColors.black)
                          : (isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey2),
                    ),
                    child: widget.title!,
                  ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
                    ),
                    child: widget.subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[const SizedBox(width: 12), widget.trailing!],
        ],
      ),
    );

    if (widget.enabled && (widget.onTap != null || widget.onLongPress != null)) {
      return GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    }

    return child;
  }

  Widget _buildNeoListTile(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isInteractive = widget.enabled && (widget.onTap != null || widget.onLongPress != null);

    final defaultBgColor = widget.selected
        ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA))
        : (isDark ? const Color(0xFF1C1C1E) : Colors.white);

    final effectiveBgColor = widget.backgroundColor ?? defaultBgColor;

    // iOS chevron if interactive and no custom trailing
    final effectiveTrailing = widget.trailing ??
        (isInteractive
            ? Icon(
                CupertinoIcons.chevron_forward,
                size: 18,
                color: isDark ? const Color(0xFF636366) : const Color(0xFFC7C7CC),
              )
            : null);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      color: _isPressed && isInteractive
          ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA))
          : effectiveBgColor,
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null)
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                      color: widget.enabled
                          ? (isDark ? Colors.white : const Color(0xFF000000))
                          : (isDark
                              ? const Color(0xFF636366)
                              : const Color(0xFF8E8E93)),
                    ),
                    child: widget.title!,
                  ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 3),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFF8E8E93)
                          : const Color(0xFF6C6C70),
                    ),
                    child: widget.subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (effectiveTrailing != null) ...[
            const SizedBox(width: 10),
            effectiveTrailing,
          ],
        ],
      ),
    );

    // Separator with iOS indented style
    if (!widget.hideBottomDivider) {
      final sepColor = widget.separatorColor ??
          (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA));

      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Padding(
            padding: EdgeInsets.only(
              left: widget.leading != null ? 54.0 : 16.0,
            ),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: sepColor,
            ),
          ),
        ],
      );
    }

    if (isInteractive) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap?.call();
        },
        onLongPress: widget.onLongPress,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
