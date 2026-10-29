import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/neo_theme.dart';

/// An individual action item displayed inside a [NeoActionSheet].
class NeoActionSheetAction {
  /// Creates an action sheet item.
  const NeoActionSheetAction({
    required this.child,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefaultAction = false,
    this.icon,
  });

  /// The primary widget (usually a [Text]) displayed in the action button.
  final Widget child;

  /// Called when the action is tapped.
  final VoidCallback onPressed;

  /// Whether this action represents a destructive operation (e.g. Delete).
  /// Displays the label/icon in Cupertino red.
  final bool isDestructive;

  /// Whether this action is the default primary selection (emboldened).
  final bool isDefaultAction;

  /// An optional leading icon.
  final Widget? icon;
}

/// An authentic iOS 26 Liquid Glass Action Sheet.
///
/// Implements the Apple Human Interface Guidelines two-tier modal design:
/// a primary card of contextual actions and a detached cancel pill card,
/// both rendered with translucent liquid glass surfaces.
class NeoActionSheet extends StatelessWidget {
  /// Creates a Liquid Glass action sheet.
  const NeoActionSheet({
    super.key,
    this.title,
    this.message,
    required this.actions,
    this.cancelButton,
  });

  /// Optional header title.
  final Widget? title;

  /// Optional secondary descriptive message.
  final Widget? message;

  /// The list of actions in the primary card.
  final List<NeoActionSheetAction> actions;

  /// The detached cancel button at the bottom.
  final NeoActionSheetAction? cancelButton;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.maybeOf(context);
    final isDark = (theme?.brightness ??
            MediaQuery.platformBrightnessOf(context)) ==
        Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF1E1E24).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.82);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.88);

    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Primary Actions Card
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.35 : 0.08,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (Title & Message)
                  if (title != null || message != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title != null)
                            DefaultTextStyle(
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF8E8E93)
                                    : const Color(0xFF636366),
                              ),
                              textAlign: TextAlign.center,
                              child: title!,
                            ),
                          if (title != null && message != null)
                            const SizedBox(height: 4),
                          if (message != null)
                            DefaultTextStyle(
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? const Color(0xFF636366)
                                    : const Color(0xFF8E8E93),
                              ),
                              textAlign: TextAlign.center,
                              child: message!,
                            ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 0.5, color: dividerColor),
                  ],

                  // Action Items
                  for (int i = 0; i < actions.length; i++) ...[
                    _ActionSheetItem(
                      action: actions[i],
                      isDark: isDark,
                      primaryColor: theme?.primaryColor ??
                          CupertinoColors.activeBlue,
                    ),
                    if (i < actions.length - 1)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: dividerColor,
                      ),
                  ],
                ],
              ),
            ),
          ),

          // 2. Detached Cancel Button
          if (cancelButton != null) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2E).withValues(alpha: 0.88)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.35 : 0.08,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _ActionSheetItem(
                  action: cancelButton!,
                  isDark: isDark,
                  isCancel: true,
                  primaryColor: theme?.primaryColor ??
                      CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionSheetItem extends StatefulWidget {
  const _ActionSheetItem({
    required this.action,
    required this.isDark,
    required this.primaryColor,
    this.isCancel = false,
  });

  final NeoActionSheetAction action;
  final bool isDark;
  final Color primaryColor;
  final bool isCancel;

  @override
  State<_ActionSheetItem> createState() => _ActionSheetItemState();
}

class _ActionSheetItemState extends State<_ActionSheetItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.action.isDestructive
        ? CupertinoColors.destructiveRed
        : (widget.isCancel
            ? widget.primaryColor
            : (widget.isDark ? Colors.white : Colors.black));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.action.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        height: 56,
        color: _isPressed
            ? (widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05))
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.action.icon != null) ...[
              widget.action.icon!,
              const SizedBox(width: 8),
            ],
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 18,
                fontWeight: widget.isCancel || widget.action.isDefaultAction
                    ? FontWeight.w600
                    : FontWeight.w400,
                letterSpacing: -0.3,
                color: textColor,
              ),
              child: widget.action.child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Backward compatibility alias
typedef GlassActionSheet = NeoActionSheet;

/// Shows an iOS 26 Liquid Glass action sheet modal popup.
Future<T?> showNeoActionSheet<T>({
  required BuildContext context,
  Widget? title,
  Widget? message,
  required List<NeoActionSheetAction> actions,
  NeoActionSheetAction? cancelButton,
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (BuildContext popupContext) {
      return NeoActionSheet(
        title: title,
        message: message,
        actions: actions,
        cancelButton: cancelButton ??
            NeoActionSheetAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(popupContext).pop(),
            ),
      );
    },
  );
}
