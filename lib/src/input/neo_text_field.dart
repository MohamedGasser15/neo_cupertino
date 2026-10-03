import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// An adaptive text field that renders platform-specific styles:
///
/// On iOS 26: Renders [CupertinoTextField] with Apple design, continuous squircle
/// curvature, subtle translucent background, and Cupertino typography.
/// On Android: Renders Material 3 [TextField] with [InputDecoration].
class NeoTextField extends StatelessWidget {
  /// Creates a Neo-Cupertino adaptive text field
  const NeoTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.autocorrect = true,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.padding,
    this.decoration,
    this.cupertinoDecoration,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool autocorrect;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? padding;
  final InputDecoration? decoration;
  final BoxDecoration? cupertinoDecoration;

  @override
  Widget build(BuildContext context) {
    return _buildCupertinoTextField(context);
  }

  Widget _buildCupertinoTextField(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    final defaultDecoration = BoxDecoration(
      color: enabled
          ? (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7))
          : (isDark ? const Color(0xFF141416) : const Color(0xFFE5E5EA)),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        width: 0.8,
      ),
    );

    return CupertinoTextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      placeholderStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93),
      ),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style ??
          TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
            color: enabled
                ? (isDark ? Colors.white : const Color(0xFF000000))
                : (isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93)),
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      obscureText: obscureText,
      autocorrect: autocorrect,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      prefix: prefix ??
          (prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: prefixIcon,
                )
              : null),
      suffix: suffix ??
          (suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12, left: 8),
                  child: suffixIcon,
                )
              : null),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      inputFormatters: inputFormatters,
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cupertinoDecoration ?? defaultDecoration,
    );
  }
}

// Backward compatibility alias
typedef AdaptiveTextField = NeoTextField;
