import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'neo_alert_dialog.dart';
import 'neo_glass_alert.dart';
import '../utils/platform_info.dart';

export 'neo_glass_alert.dart'
    show
        DialogAction,
        DialogActionRole,
        IOS26AlertAction,
        IOS26AlertActionStyle,
        AlertAction,
        AlertActionStyle;

/// Native iOS 26 Neo-Cupertino Alert Dialog component embedded directly inside neo_cupertino.
/// On iOS, this uses the native UIKit platform view with full control over
/// Light Mode (#ECECEF) and Dark Mode (pitch dark charcoal #1C1C1E).
class NeoNativeAlert extends StatefulWidget {
  const NeoNativeAlert({
    super.key,
    required this.title,
    this.message,
    required this.actions,
    this.iconName,
    this.iconSize,
    this.iconColor,
    this.oneTimeCode,
    this.input,
    this.isDark,
    this.isRtl,
    this.tint,
  });

  final String title;
  final String? message;
  final List<DialogAction> actions;
  final String? iconName;
  final double? iconSize;
  final Color? iconColor;
  final String? oneTimeCode;
  final NeoAlertDialogInput? input;
  final bool? isDark;
  final bool? isRtl;
  final Color? tint;

  /// Shows the iOS 26 native alert dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? message,
    required List<DialogAction> actions,
    String? iconName,
    double? iconSize,
    Color? iconColor,
    String? oneTimeCode,
    bool? isDark,
    bool? isRtl,
    Color? tint,
  }) async {
    final effectiveIsDark =
        isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final textDirection = Directionality.maybeOf(context);
    final locale = Localizations.maybeLocaleOf(context);
    final hasArabicText = RegExp(r'[\u0600-\u06FF]').hasMatch(title) ||
        (message != null && RegExp(r'[\u0600-\u06FF]').hasMatch(message));
    final effectiveIsRtl = isRtl ??
        (textDirection == TextDirection.rtl ||
            locale?.languageCode == 'ar' ||
            hasArabicText);
    final effectiveDirection =
        effectiveIsRtl ? TextDirection.rtl : TextDirection.ltr;
    final effectiveTint = tint;

    // iOS 26+ - Use native iOS 26 alert dialog
    if (PlatformInfo.isIOS26OrHigher()) {
      await showCupertinoDialog<void>(
        context: context,
        barrierColor: CupertinoColors.transparent,
        builder: (dialogContext) {
          return Directionality(
            textDirection: effectiveDirection,
            child: MediaQuery(
              data: MediaQuery.of(dialogContext).copyWith(
                platformBrightness:
                    effectiveIsDark ? Brightness.dark : Brightness.light,
              ),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: effectiveIsDark ? Brightness.dark : Brightness.light,
                  primaryColor: effectiveTint ??
                      (effectiveIsDark
                          ? CupertinoColors.white
                          : const Color(0xFF1C1C1E)),
                ),
                child: NeoNativeAlert(
                  title: title,
                  message: message,
                  actions: actions,
                  iconName: iconName,
                  iconSize: iconSize,
                  iconColor: iconColor,
                  oneTimeCode: oneTimeCode,
                  isDark: effectiveIsDark,
                  isRtl: effectiveIsRtl,
                  tint: effectiveTint,
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    // iOS 18 and below (and cross-platform):
    // Use NeoGlassAlert so users get the exact same Liquid Glass appearance,
    // translucent backdrop blur, glowing borders, and pill buttons with the accent color.
    await NeoGlassAlert.show(
      context: context,
      title: title,
      message: message,
      actions: actions,
      isDark: effectiveIsDark,
      tint: effectiveTint,
    );
  }


  /// Shows the iOS 26 native alert dialog with text input
  static Future<String?> inputShow({
    required BuildContext context,
    required String title,
    String? message,
    required List<DialogAction> actions,
    required NeoAlertDialogInput input,
    String? iconName,
    double? iconSize,
    Color? iconColor,
    bool? isDark,
    bool? isRtl,
    Color? tint,
  }) async {
    final effectiveIsDark =
        isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final textDirection = Directionality.maybeOf(context);
    final locale = Localizations.maybeLocaleOf(context);
    final hasArabicText = RegExp(r'[\u0600-\u06FF]').hasMatch(title) ||
        (message != null && RegExp(r'[\u0600-\u06FF]').hasMatch(message));
    final effectiveIsRtl = isRtl ??
        (textDirection == TextDirection.rtl ||
            locale?.languageCode == 'ar' ||
            hasArabicText);
    final effectiveDirection =
        effectiveIsRtl ? TextDirection.rtl : TextDirection.ltr;

    // iOS 26+ - Use native iOS 26 alert dialog with input
    if (PlatformInfo.isIOS26OrHigher()) {
      return showCupertinoDialog<String?>(
        context: context,
        barrierColor: CupertinoColors.transparent,
        builder: (dialogContext) {
          return Directionality(
            textDirection: effectiveDirection,
            child: MediaQuery(
              data: MediaQuery.of(dialogContext).copyWith(
                platformBrightness:
                    effectiveIsDark ? Brightness.dark : Brightness.light,
              ),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: effectiveIsDark ? Brightness.dark : Brightness.light,
                ),
                child: NeoNativeAlert(
                  title: title,
                  message: message,
                  actions: actions,
                  iconName: iconName,
                  iconSize: iconSize,
                  iconColor: iconColor,
                  input: input,
                  isDark: effectiveIsDark,
                  isRtl: effectiveIsRtl,
                  tint: tint,
                ),
              ),
            ),
          );
        },
      );
    }

    final textController = TextEditingController(text: input.initialValue);
    return showCupertinoDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: effectiveDirection,
          child: CupertinoAlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
              textDirection: effectiveDirection,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message != null)
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    textDirection: effectiveDirection,
                  ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: textController,
                  placeholder: input.placeholder,
                  textAlign: effectiveIsRtl ? TextAlign.right : TextAlign.left,
                  textDirection: textDirection,
                  obscureText: input.obscureText,
                  keyboardType: input.keyboardType,
                  maxLength: input.maxLength,
                  autofocus: true,
                ),
              ],
            ),
            actions: actions.map((a) {
              return CupertinoDialogAction(
                isDestructiveAction:
                    a.role == DialogActionRole.destructive,
                isDefaultAction: a.role == DialogActionRole.primary,
                onPressed: () {
                  if (a.role == DialogActionRole.cancel) {
                    Navigator.of(dialogContext).pop<String?>(null);
                  } else {
                    final text = textController.text.trim();
                    Navigator.of(dialogContext).pop<String?>(text.isNotEmpty ? text : null);
                  }
                  a.onPressed();
                },
                child: Text(a.title, textDirection: textDirection),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  State<NeoNativeAlert> createState() => _NeoNativeAlertState();
}

// Backward compatibility alias
typedef IOS26NativeAlert = NeoNativeAlert;

class _NeoNativeAlertState extends State<NeoNativeAlert> {
  MethodChannel? _channel;

  bool get _isDark {
    if (widget.isDark != null) return widget.isDark!;
    return Theme.of(context).brightness == Brightness.dark;
  }

  bool get _isRtl {
    if (widget.isRtl != null) return widget.isRtl!;
    final textDirection = Directionality.maybeOf(context);
    final locale = Localizations.maybeLocaleOf(context);
    final hasArabicText = RegExp(r'[\u0600-\u06FF]').hasMatch(widget.title) ||
        (widget.message != null &&
            RegExp(r'[\u0600-\u06FF]').hasMatch(widget.message!));
    return textDirection == TextDirection.rtl ||
        locale?.languageCode == 'ar' ||
        hasArabicText;
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  int _colorToARGB(Color color) {
    return ((color.a * 255.0).round() & 0xff) << 24 |
        ((color.r * 255.0).round() & 0xff) << 16 |
        ((color.g * 255.0).round() & 0xff) << 8 |
        ((color.b * 255.0).round() & 0xff);
  }

  String _mapKeyboardType(TextInputType? type) {
    if (type == TextInputType.emailAddress) return 'emailAddress';
    if (type == TextInputType.number) return 'number';
    if (type == TextInputType.phone) return 'phone';
    if (type == TextInputType.url) return 'url';
    return 'default';
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      final isDark = _isDark;
      final effectiveTint = widget.tint ??
          (isDark
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF1C1C1E));
      final creationParams = <String, dynamic>{
        'title': widget.title,
        if (widget.message != null) 'message': widget.message,
        'actionTitles': widget.actions.map((a) => a.title).toList(),
        'actionStyles': widget.actions.map((a) => a.style.name).toList(),
        'actionEnabled': widget.actions.map((a) => a.enabled).toList(),
        if (widget.iconName != null) 'iconName': widget.iconName,
        if (widget.iconSize != null) 'iconSize': widget.iconSize,
        if (widget.iconColor != null)
          'iconColor': _colorToARGB(widget.iconColor!),
        if (widget.oneTimeCode != null) 'oneTimeCode': widget.oneTimeCode,
        if (widget.input != null) ...{
          'textFieldPlaceholder': widget.input!.placeholder,
          if (widget.input!.initialValue != null)
            'textFieldInitialValue': widget.input!.initialValue,
          'textFieldObscureText': widget.input!.obscureText,
          if (widget.input!.maxLength != null)
            'textFieldMaxLength': widget.input!.maxLength,
          'textFieldKeyboardType': _mapKeyboardType(widget.input!.keyboardType),
        },
        'isDark': isDark,
        'isRtl': _isRtl,
        'tint': _colorToARGB(effectiveTint),
      };

      final platformView = UiKitView(
        viewType: 'neo_cupertino/neo_native_alert',
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
        },
      );

      return Center(
        child: SizedBox(
          width: 300,
          height: 240,
          child: platformView,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _onCreated(int id) {
    final ch = MethodChannel('neo_cupertino/neo_native_alert_$id');
    _channel = ch;

    ch.setMethodCallHandler((call) async {
      if (call.method == 'actionPressed' || call.method == 'onActionPressed') {
        final args = call.arguments as Map?;
        final index = (args?['index'] as num?)?.toInt() ?? 0;
        final textFieldValue = args?['textFieldValue'] as String?;

        if (index < widget.actions.length) {
          final action = widget.actions[index];
          if (mounted) {
            if (widget.input != null) {
              if (action.role == DialogActionRole.cancel) {
                Navigator.of(context).pop<String?>(null);
              } else {
                Navigator.of(context).pop<String?>(textFieldValue);
              }
            } else {
              Navigator.of(context).pop();
            }
          }
          action.onPressed();
        }
      }
      return null;
    });
  }
}
