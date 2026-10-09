import 'package:flutter/material.dart';

import '../utils/platform_info.dart';
import 'neo_glass_alert.dart';
import 'neo_native_alert.dart';

// DialogAction and DialogActionRole are exported from neo_native_alert.dart

/// Configuration for text input in alert dialog
class NeoAlertDialogInput {
  const NeoAlertDialogInput({
    required this.placeholder,
    this.initialValue,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
  });

  final String placeholder;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
}

typedef AdaptiveAlertDialogInput = NeoAlertDialogInput;

/// A Neo-Cupertino adaptive alert dialog that renders platform-specific styles:
/// - On iOS: Native iOS 26 liquid frosted squircle alert
/// - On Android / Other: Material Design AlertDialog
class NeoAlertDialog {
  NeoAlertDialog._();

  /// Shows a standard Neo-Cupertino alert dialog (iOS 26 Liquid Frosted design)
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? message,
    required List<DialogAction> actions,
    dynamic icon,
    double? iconSize,
    Color? iconColor,
    String? oneTimeCode,
    bool? isDark,
  }) {
    String? sfSymbolName;
    if (icon is String) {
      sfSymbolName = icon;
    }

    if (PlatformInfo.isIOS) {
      return NeoNativeAlert.show(
        context: context,
        title: title,
        message: message,
        actions: actions,
        iconName: sfSymbolName,
        iconSize: iconSize,
        iconColor: iconColor,
        oneTimeCode: oneTimeCode,
        isDark: isDark,
      );
    }

    // Pure iOS 26 Liquid Frosted Glass Alert for non-iOS platforms
    return NeoGlassAlert.show(
      context: context,
      title: title,
      message: message,
      actions: actions,
      icon: icon is Widget ? icon : null,
      isDark: isDark,
    );
  }

  /// Shows an iOS alert dialog with text input
  static Future<String?> inputShow({
    required BuildContext context,
    required String title,
    String? message,
    required List<DialogAction> actions,
    required NeoAlertDialogInput input,
    dynamic icon,
    double? iconSize,
    Color? iconColor,
    bool? isDark,
  }) {
    String? sfSymbolName;
    if (icon is String) {
      sfSymbolName = icon;
    }

    if (PlatformInfo.isIOS) {
      return NeoNativeAlert.inputShow(
        context: context,
        title: title,
        message: message,
        actions: actions,
        input: input,
        iconName: sfSymbolName,
        iconSize: iconSize,
        iconColor: iconColor,
        isDark: isDark,
      );
    }

    // Non-iOS fallback to NeoNativeAlert which handles Flutter dialogs
    return NeoNativeAlert.inputShow(
      context: context,
      title: title,
      message: message,
      actions: actions,
      input: input,
      iconName: sfSymbolName,
      iconSize: iconSize,
      iconColor: iconColor,
      isDark: isDark,
    );
  }
}

// Backward compatibility alias
typedef AdaptiveAlertDialog = NeoAlertDialog;
