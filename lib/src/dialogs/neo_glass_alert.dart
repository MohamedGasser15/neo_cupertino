import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Role of action buttons in iOS 26 alerts and dialogs (matching Apple SwiftUI/HIG design)
enum DialogActionRole {
  /// Standard neutral action button
  standard,

  /// Cancel action button for dismissing dialogs
  cancel,

  /// Destructive action button for dangerous operations (red highlight)
  destructive,

  /// Primary emphasized action button
  primary,

  /// Secondary action button
  secondary,

  /// Positive confirmation action button (green highlight)
  success,

  /// Warning action button (orange highlight)
  warning,

  /// Informational action button (blue highlight)
  info,

  /// Disabled non-interactive action button
  disabled;

  /// Backward-compatibility alias for defaultAction
  static const DialogActionRole defaultAction = DialogActionRole.standard;
}

/// Represents an individual button action in iOS 26 alerts and dialogs
class DialogAction {
  const DialogAction({
    required this.title,
    required this.onPressed,
    DialogActionRole? role,
    DialogActionRole? style,
    this.enabled = true,
  }) : role = role ?? style ?? DialogActionRole.primary;

  final String title;
  final VoidCallback onPressed;
  final DialogActionRole role;
  DialogActionRole get style => role;
  final bool enabled;
}

// ─── Aliases ───
typedef NeoDialogAction = DialogAction;
typedef NeoDialogActionRole = DialogActionRole;
typedef IOS26AlertAction = DialogAction;
typedef IOS26AlertActionStyle = DialogActionRole;
typedef AlertAction = DialogAction;
typedef AlertActionStyle = DialogActionRole;
typedef IOS26GlassAlert = NeoGlassAlert;

/// Official iOS 26 Neo-Cupertino Alert Dialog matching Apple's native design:
/// - Wide rounded squircle card (radius ~32px)
/// - Left-aligned bold title & subtle body text
/// - Rounded pill button container at the bottom with solid neutral tint
/// - Perfect Light Mode (light grey / frosted white) & Dark Mode (dark charcoal / frosted)
class NeoGlassAlert extends StatelessWidget {
  const NeoGlassAlert({
    super.key,
    required this.title,
    this.message,
    this.icon,
    required this.actions,
    this.maxWidth = 320,
    this.isDark,
  });

  final String title;
  final String? message;
  final Widget? icon;
  final List<DialogAction> actions;
  final double maxWidth;
  final bool? isDark;

  /// Shows the Neo-Cupertino iOS 26 glass alert dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? icon,
    required List<DialogAction> actions,
    bool barrierDismissible = false,
    double maxWidth = 320,
    bool? isDark,
  }) {
    HapticFeedback.lightImpact();

    final isDarkMode = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'NeoGlassAlert',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, anim1, anim2) {
        return Center(
          child: NeoGlassAlert(
            title: title,
            message: message,
            icon: icon,
            actions: actions,
            maxWidth: maxWidth,
            isDark: isDarkMode,
          ),
        );
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInQuad,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIsDark = isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Dimensions matching the reference screenshot
    const double cardRadius = 32.0;

    // Colors matching the video/screenshot exactly:
    // Light Mode:
    // - Card Background: #EAEAEF with slight translucency / blur
    // - Title: #1C1C1E (Dark grey / black, w600)
    // - Message: #71717A (Neutral grey)
    // - Button Pill: #D5D5DC
    // - Button Text: #1C1C1E
    //
    // Dark Mode (matching exact reference screenshot):
    // - Card Background: #1C1C1E (Solid deep charcoal/black squircle)
    // - Title: #FFFFFF (Pure white, w600)
    // - Message: #8E8E93 (Subtle muted grey)
    // - Button Pill: #38383B (Dark grey capsule pill)
    // - Button Text: #FFFFFF (White)

    final Color cardBackground = effectiveIsDark
        ? const Color(0xFF242426).withValues(alpha: 0.72)
        : const Color(0xFFECECEF).withValues(alpha: 0.68);

    final Color titleColor = effectiveIsDark
        ? Colors.white
        : const Color(0xFF111111);

    final Color messageColor = effectiveIsDark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

    final Color borderOutline = effectiveIsDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.55);

    return Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: effectiveIsDark ? 0.35 : 0.12),
                blurRadius: 36,
                offset: const Offset(0, 14),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(
                    color: borderOutline,
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icon != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: icon!,
                      ),
                    ],

                    // Title: Left aligned (or start-aligned for Arabic)
                    Text(
                      title,
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                        color: titleColor,
                      ),
                    ),

                    // Message: Left aligned, slightly spaced
                    if (message != null && message!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        message!,
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          height: 1.38,
                          letterSpacing: -0.2,
                          color: messageColor,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Actions: Pill button at bottom
                    _buildActions(context, effectiveIsDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    if (actions.isEmpty) return const SizedBox.shrink();

    // 2 actions: Horizontal layout side-by-side
    if (actions.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _buildPillButton(context, actions[0], isDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildPillButton(context, actions[1], isDark),
          ),
        ],
      );
    }

    // 1 or 3+ actions: Vertical stacked layout
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildPillButton(context, actions[i], isDark),
        ],
      ],
    );
  }

  Widget _buildPillButton(
    BuildContext context,
    DialogAction action,
    bool isDark,
  ) {
    // Colors matching the exact pill button in the screenshot
    final Color buttonBgColor;
    final Color textColor;

    if (action.role == DialogActionRole.destructive) {
      buttonBgColor = isDark
          ? const Color(0xFF422123)
          : const Color(0xFFFDE8E8);
      textColor = const Color(0xFFFF453A);
    } else if (action.role == DialogActionRole.cancel) {
      buttonBgColor = isDark
          ? const Color(0xFF2C2C2E).withValues(alpha: 0.90)
          : const Color(0xFFE5E5EA).withValues(alpha: 0.85);
      textColor = isDark
          ? const Color(0xFFE5E5EA)
          : const Color(0xFF1C1C1E);
    } else {
      // Standard neutral pill as in the screenshot:
      // Light Mode: #D4D4DC
      // Dark Mode: #38383B / #3A3A3C
      buttonBgColor = isDark
          ? const Color(0xFF38383B).withValues(alpha: 0.92)
          : const Color(0xFFD4D4DC).withValues(alpha: 0.88);

      textColor = isDark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF111111);
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 48,
      onPressed: action.enabled
          ? () {
              HapticFeedback.lightImpact();
              Navigator.of(context, rootNavigator: true).pop();
              action.onPressed();
            }
          : null,
      child: Container(
        height: 48,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: buttonBgColor,
          borderRadius: BorderRadius.circular(24), // Full capsule pill shape
        ),
        child: Text(
          action.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: action.enabled
                ? textColor
                : textColor.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
