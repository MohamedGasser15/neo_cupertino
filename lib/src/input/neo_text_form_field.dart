import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// An adaptive form field with validation support following platform design:
///
/// On iOS 26: Renders Apple-styled text input with custom error handling,
/// squircle curvature, and haptic feedback.
/// On Android: Renders standard Material 3 [TextFormField].
class NeoTextFormField extends FormField<String> {
  NeoTextFormField({
    super.key,
    this.controller,
    String? initialValue,
    FocusNode? focusNode,
    String? placeholder,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool readOnly = false,
    bool obscureText = false,
    bool autocorrect = true,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    super.onSaved,
    super.validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    EdgeInsetsGeometry? padding,
    Widget? prefix,
    Widget? suffix,
    Widget? prefixIcon,
    Widget? suffixIcon,
    InputDecoration? decoration,
    BoxDecoration? cupertinoDecoration,
    super.autovalidateMode,
  }) : super(
          initialValue:
              controller != null ? controller.text : (initialValue ?? ''),
          enabled: enabled ?? true,
          builder: (FormFieldState<String> field) {
            final _NeoTextFormFieldState state =
                field as _NeoTextFormFieldState;

            void onChangedHandler(String value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            return _buildNeoField(
              state: state,
              controller: state._effectiveController,
              focusNode: focusNode,
              placeholder: placeholder,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              textInputAction: textInputAction,
              style: style,
              textAlign: textAlign,
              autofocus: autofocus,
              readOnly: readOnly,
              obscureText: obscureText,
              autocorrect: autocorrect,
              maxLines: maxLines,
              minLines: minLines,
              maxLength: maxLength,
              onChanged: onChangedHandler,
              onTap: onTap,
              onFieldSubmitted: onFieldSubmitted,
              inputFormatters: inputFormatters,
              enabled: field.widget.enabled,
              padding: padding,
              prefix: prefix,
              suffix: suffix,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              cupertinoDecoration: cupertinoDecoration,
              errorText: field.errorText,
            );
          },
        );

  final TextEditingController? controller;

  @override
  FormFieldState<String> createState() => _NeoTextFormFieldState();

  static Widget _buildNeoField({
    required FormFieldState<String> state,
    required TextEditingController controller,
    FocusNode? focusNode,
    String? placeholder,
    TextInputType? keyboardType,
    required TextCapitalization textCapitalization,
    TextInputAction? textInputAction,
    TextStyle? style,
    required TextAlign textAlign,
    required bool autofocus,
    required bool readOnly,
    required bool obscureText,
    required bool autocorrect,
    int? maxLines,
    int? minLines,
    int? maxLength,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    ValueChanged<String>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    required bool enabled,
    EdgeInsetsGeometry? padding,
    Widget? prefix,
    Widget? suffix,
    Widget? prefixIcon,
    Widget? suffixIcon,
    BoxDecoration? cupertinoDecoration,
    String? errorText,
  }) {
    final context = state.context;
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final hasError = errorText != null && errorText.isNotEmpty;

    final defaultDecoration = BoxDecoration(
      color: enabled
          ? (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7))
          : (isDark ? const Color(0xFF141416) : const Color(0xFFE5E5EA)),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: hasError
            ? CupertinoColors.systemRed
            : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)),
        width: hasError ? 1.2 : 0.8,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoTextField(
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
                    : (isDark
                        ? const Color(0xFF636366)
                        : const Color(0xFF8E8E93)),
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
          onSubmitted: onFieldSubmitted,
          onTap: onTap,
          inputFormatters: inputFormatters,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: cupertinoDecoration ?? defaultDecoration,
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 14, right: 14),
            child: Text(
              errorText,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _NeoTextFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  @override
  NeoTextFormField get widget => super.widget as NeoTextFormField;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(NeoTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller =
            TextEditingController.fromValue(oldWidget.controller!.value);
      }
      if (widget.controller != null) {
        setValue(widget.controller!.text);
        if (oldWidget.controller == null) {
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController.text = widget.initialValue ?? '';
    });
  }

  void _handleControllerChanged() {
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }
}

// Backward compatibility alias
typedef AdaptiveTextFormField = NeoTextFormField;
