import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../navigation/neo_navigation.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../src/utils/glass_localizations.dart';
import '../../theme/glass_theme.dart';
import '../../types/glass_quality.dart';

/// An authentic Apple Liquid Glass search bar following iOS 26+ design patterns.
///
/// [GlassSearchBar] hosts Apple's real glass material ([UIGlassEffect] via
/// [LiquidGlassContainer]) on iOS 26+, giving genuine optical refraction,
/// specular rim lighting, and adaptive appearance. On older systems or non-iOS
/// platforms, it renders the package's frosted glass fallback.
///
/// ## Key Features
///
/// - **Interactive Expansion Animation**: Renders as a compact, centered pill
///   when idle. When focused, it smoothly animates and glides to the left, while
///   the circular glass [×] button pops in on the right.
/// - **Authentic Liquid Glass**: Capsule surface built with [LiquidGlassContainer].
/// - **Single-Line Optical Alignment**: Prefix search icon, placeholder text, and
///   suffix clear button are vertically centered on the exact same axis.
/// - **Adaptive Styling**: Solid black/white search and cancel icons according
///   to active brightness.
/// - **Interactive Clear & Cancel**: Haptic feedback on cancel, with dedicated
///   callbacks.
///
/// The visual presentation of the cancel button in a [GlassSearchBar].
enum GlassCancelButtonType {
  /// A circular Liquid Glass capsule button hosting an icon (defaults to [CupertinoIcons.xmark]).
  icon,

  /// A Liquid Glass capsule button hosting text (e.g. 'Cancel' or localized 'إلغاء').
  text,

  /// A completely custom cancel button supplied via [GlassSearchBar.cancelButtonBuilder].
  custom,

  /// No cancel button is displayed.
  none,
}

/// ## Usage
///
/// ```dart
/// GlassSearchBar(
///   placeholder: 'Search categories...',
///   onChanged: (val) => setState(() => query = val),
/// )
/// ```
class GlassSearchBar extends StatefulWidget {
  /// Creates a Liquid Glass search bar.
  const GlassSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onCancel,
    this.showsCancelButton = true,
    this.cancelButtonType = GlassCancelButtonType.icon,
    this.cancelButtonText,
    this.cancelTextStyle,
    this.cancelButtonWidth,
    this.cancelButtonBuilder,
    this.leading,
    this.trailing,
    this.actions,
    this.autofocus = false,
    this.enabled = true,
    this.searchIconColor,
    this.clearIconColor,
    this.cancelButtonColor,
    this.cancelIcon,
    this.cancelIconSize = 18.0,
    this.textStyle,
    this.placeholderStyle,
    this.height = 46.0,
    this.collapsedWidth = 340.0,
    this.expandedStartOffset = 8.0,
    this.animationDuration = const Duration(milliseconds: 320),
    this.animationCurve = Curves.easeOutCubic,
    this.style = LiquidGlassStyle.regular,
    this.shape = const LiquidGlassShape.capsule(),
    this.clearButtonSemanticLabel,
    this.cancelButtonSemanticLabel,
    this.settings,
    this.useOwnLayer = false,
    this.quality,
  });

  // ===========================================================================
  // Search Bar Properties
  // ===========================================================================

  /// Controls the text being edited.
  ///
  /// If null, a controller will be created and managed internally.
  final TextEditingController? controller;

  /// Optional focus node for the search field.
  ///
  /// Providing a [FocusNode] gives you programmatic control over keyboard
  /// focus independently of [autofocus].
  ///
  /// If null, an internal node is created and disposed automatically.
  final FocusNode? focusNode;

  /// Placeholder text shown when the field is empty.
  final String placeholder;

  /// Called when the search text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search.
  final ValueChanged<String>? onSubmitted;

  /// Called when the cancel button is tapped.
  final VoidCallback? onCancel;

  /// Whether to show the cancel button when the search bar is focused.
  ///
  /// Defaults to `true`.
  final bool showsCancelButton;

  /// The visual presentation of the cancel button.
  ///
  /// Defaults to [GlassCancelButtonType.icon].
  final GlassCancelButtonType cancelButtonType;

  /// Custom text for the cancel button when [cancelButtonType] is [GlassCancelButtonType.text].
  ///
  /// If null, defaults to localized cancel text (e.g. 'Cancel' or 'إلغاء').
  final String? cancelButtonText;

  /// The text style for the cancel button text.
  final TextStyle? cancelTextStyle;

  /// Custom width allocated for the cancel button.
  ///
  /// Defaults to [height] for [GlassCancelButtonType.icon], and `72.0` for
  /// [GlassCancelButtonType.text].
  final double? cancelButtonWidth;

  /// Custom builder for the cancel button when [cancelButtonType] is [GlassCancelButtonType.custom].
  final Widget Function(BuildContext context, VoidCallback onCancel)?
      cancelButtonBuilder;

  /// Optional custom leading widget replacing the default search icon.
  final Widget? leading;

  /// Optional trailing widget placed inside the search field after the clear button.
  final Widget? trailing;

  /// Optional additional action widgets placed inside the search field
  /// (e.g. voice search/microphone icon, filter button, barcode/QR scanner).
  final List<Widget>? actions;

  /// Whether the search field should auto-focus.
  final bool autofocus;

  /// Whether the search field is enabled.
  final bool enabled;

  // ===========================================================================
  // Animation & Sizing Properties
  // ===========================================================================

  /// Compact width of the search pill when unfocused.
  ///
  /// When non-null, the search bar renders as a compact floating glass pill
  /// centered when unfocused. When focused, it smoothly expands and glides to the
  /// left, while the circular glass cancel button animates in on the right.
  ///
  /// Set to `null` to disable compact mode and have the search bar always take
  /// full width. Defaults to `340.0`.
  final double? collapsedWidth;

  /// Additional logical pixels to extend the search bar toward the start (left in LTR)
  /// when focused.
  ///
  /// Defaults to `8.0`. Set to `0.0` for no start extension.
  final double expandedStartOffset;

  /// Duration of the focus expansion/collapse animation.
  ///
  /// Defaults to `320ms`.
  final Duration animationDuration;

  /// Curve of the focus expansion/collapse animation.
  ///
  /// Defaults to [Curves.easeOutCubic].
  final Curve animationCurve;

  // ===========================================================================
  // Style Properties
  // ===========================================================================

  /// Color of the leading search icon.
  ///
  /// Defaults to solid black in light mode and white in dark mode.
  final Color? searchIconColor;

  /// Color of the inner clear (×) button icon.
  final Color? clearIconColor;

  /// Color of the trailing cancel (×) icon inside the glass button.
  final Color? cancelButtonColor;

  /// Custom icon widget for the cancel button.
  ///
  /// Defaults to [CupertinoIcons.xmark].
  final Widget? cancelIcon;

  /// Size of the cancel (×) icon in logical pixels. Defaults to `18.0`.
  final double cancelIconSize;

  /// Screen reader label of the clear (×) button inside the field.
  final String? clearButtonSemanticLabel;

  /// Screen reader label of the cancel button beside the field.
  final String? cancelButtonSemanticLabel;

  /// The style of the search input text.
  final TextStyle? textStyle;

  /// The style of the placeholder text.
  final TextStyle? placeholderStyle;

  /// Height of the search bar. Defaults to `46.0`.
  final double height;

  /// Glass material variant; see [LiquidGlassStyle].
  ///
  /// Defaults to [LiquidGlassStyle.regular].
  final LiquidGlassStyle style;

  /// Outline shape of the search surface. Defaults to [LiquidGlassShape.capsule].
  final LiquidGlassShape shape;

  /// Legacy glass effect settings for custom fallback configuration.
  final LiquidGlassSettings? settings;

  /// Legacy layer flag (kept for backwards compatibility).
  final bool useOwnLayer;

  /// Legacy quality flag (kept for backwards compatibility).
  final GlassQuality? quality;

  @override
  State<GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends State<GlassSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(GlassSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _controller.removeListener(_onTextChanged);
        _controller.dispose();
      } else {
        _controller.removeListener(_onTextChanged);
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = TextEditingController();
        _ownsController = true;
      }
      _controller.addListener(_onTextChanged);
      _hasText = _controller.text.isNotEmpty;
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (_ownsFocusNode) {
        _focusNode.removeListener(_onFocusChanged);
        _focusNode.dispose();
      } else {
        _focusNode.removeListener(_onFocusChanged);
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _ownsFocusNode = false;
      } else {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      }
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    _controller.clear();
    _focusNode.unfocus();
    widget.onCancel?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark ||
        GlassTheme.brightnessOf(context) == Brightness.dark;

    final searchIconColor = widget.searchIconColor ??
        (isDark ? CupertinoColors.white : CupertinoColors.black);
    final clearIconColor = widget.clearIconColor ??
        (isDark
            ? CupertinoColors.white.withValues(alpha: 0.65)
            : const Color(0xFF3C3C43).withValues(alpha: 0.60));
    final cancelButtonColor = widget.cancelButtonColor ??
        (isDark ? CupertinoColors.white : CupertinoColors.black);

    final isExpanded = _focusNode.hasFocus || _hasText;
    final bool hasCancelButton = widget.showsCancelButton &&
        widget.cancelButtonType != GlassCancelButtonType.none;
    final bool showCancel = hasCancelButton && isExpanded;

    final double cancelWidth;
    switch (widget.cancelButtonType) {
      case GlassCancelButtonType.icon:
        cancelWidth = widget.cancelButtonWidth ?? widget.height;
        break;
      case GlassCancelButtonType.text:
        cancelWidth = widget.cancelButtonWidth ?? 72.0;
        break;
      case GlassCancelButtonType.custom:
        cancelWidth = widget.cancelButtonWidth ?? widget.height;
        break;
      case GlassCancelButtonType.none:
        cancelWidth = 0.0;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final targetCollapsedWidth = widget.collapsedWidth != null
            ? widget.collapsedWidth!.clamp(140.0, maxWidth)
            : maxWidth;

        final startExtension = isExpanded ? widget.expandedStartOffset : 0.0;

        final searchWidth = isExpanded
            ? (hasCancelButton
                ? maxWidth - cancelWidth - 8.0 + startExtension
                : maxWidth + startExtension)
            : targetCollapsedWidth;

        final searchStart = isExpanded
            ? -startExtension
            : (maxWidth - targetCollapsedWidth) / 2.0;

        return SizedBox(
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Animated Search Bar Pill (slides and expands toward start)
              AnimatedPositionedDirectional(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                start: searchStart,
                top: 0,
                bottom: 0,
                width: searchWidth,
                child: LiquidGlassContainer(
                  height: widget.height,
                  style: widget.style,
                  shape: widget.shape,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: widget.enabled
                        ? () => _focusNode.requestFocus()
                        : null,
                    child: Center(
                      child: CupertinoTextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        autofocus: widget.autofocus,
                        textInputAction: TextInputAction.search,
                        textAlignVertical: TextAlignVertical.center,
                        placeholder: widget.placeholder,
                        placeholderStyle: widget.placeholderStyle ??
                            TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? CupertinoColors.white
                                      .withValues(alpha: 0.55)
                                  : const Color(0xFF3C3C43)
                                      .withValues(alpha: 0.55),
                              letterSpacing: -0.3,
                            ),
                        style: widget.textStyle ??
                            TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                              letterSpacing: -0.3,
                            ),
                        decoration: null,
                        padding: EdgeInsets.zero,
                        prefix: widget.leading ??
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 16,
                                end: 8,
                              ),
                              child: Icon(
                                CupertinoIcons.search,
                                size: 20,
                                color: searchIconColor,
                              ),
                            ),
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_hasText)
                              GestureDetector(
                                onTap: _handleClear,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 8,
                                  ),
                                  child: Semantics(
                                    button: true,
                                    label: widget.clearButtonSemanticLabel ??
                                        glassCupertinoLocalizationsOf(context)
                                            .clearButtonLabel,
                                    child: Icon(
                                      CupertinoIcons.clear_circled_solid,
                                      size: 18,
                                      color: clearIconColor,
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.actions != null) ...widget.actions!,
                            if (widget.trailing != null) widget.trailing!,
                            if (!_hasText &&
                                widget.actions == null &&
                                widget.trailing == null)
                              const SizedBox(width: 16)
                            else
                              const SizedBox(width: 10),
                          ],
                        ),
                        cursorColor: isDark
                            ? CupertinoColors.white
                            : CupertinoColors.activeBlue,
                        onChanged: (val) {
                          widget.onChanged?.call(val);
                        },
                        onSubmitted: (val) {
                          _focusNode.unfocus();
                          widget.onSubmitted?.call(val);
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Animated Glass Cancel Button (slides/scales in at end)
              if (hasCancelButton)
                AnimatedPositionedDirectional(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  end: 0,
                  top: 0,
                  bottom: 0,
                  width: cancelWidth,
                  child: AnimatedScale(
                    scale: showCancel ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      opacity: showCancel ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: !showCancel,
                        child: widget.cancelButtonBuilder != null
                            ? widget.cancelButtonBuilder!(
                                context,
                                _handleCancel,
                              )
                            : LiquidGlassContainer(
                                width: cancelWidth,
                                height: widget.height,
                                style: widget.style,
                                shape: const LiquidGlassShape.capsule(),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _handleCancel,
                                  child: Center(
                                    child: Semantics(
                                      button: true,
                                      label: widget.cancelButtonSemanticLabel ??
                                          glassCupertinoLocalizationsOf(context)
                                              .cancelButtonLabel,
                                      child: _buildCancelContent(
                                        context,
                                        cancelButtonColor,
                                        isDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelContent(
    BuildContext context,
    Color cancelButtonColor,
    bool isDark,
  ) {
    if (widget.cancelButtonType == GlassCancelButtonType.text) {
      final text = widget.cancelButtonText ??
          glassCupertinoLocalizationsOf(context).cancelButtonLabel;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: widget.cancelTextStyle ??
              TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                color: widget.cancelButtonColor ??
                    (isDark ? CupertinoColors.white : CupertinoColors.activeBlue),
                letterSpacing: -0.2,
              ),
        ),
      );
    }

    return widget.cancelIcon ??
        Icon(
          CupertinoIcons.xmark,
          size: widget.cancelIconSize,
          color: cancelButtonColor,
        );
  }
}
