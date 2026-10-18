import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import '../../theme/glass_theme_data.dart';
import '../../types/glass_quality.dart';
import '../containers/glass_container.dart';
import '../interactive/glass_button.dart';
import '../shared/neo_liquid_glass_layer.dart';

/// A glass morphism progress indicator following Apple's iOS 26 Liquid Glass
/// design patterns.
///
/// [GlassProgressIndicator] provides both circular and linear progress indicators
/// with glass effect, matching iOS's ProgressView appearance with liquid glass
/// aesthetics.
///
/// ## iOS 26 Specifications
///
/// This widget implements the exact iOS 26 Liquid Glass progress indicators:
/// - **Circular**: 20pt diameter (default), 2.5pt stroke width
/// - **Linear**: Full width, 4pt height (default)
/// - **Animation**: 1.0 second rotation for indeterminate
/// - **Glass Effect**: Translucent with specular highlights
/// - **Tint Color**: Adaptive based on theme (blue default)
///
/// ## Usage
///
/// ### Circular Indeterminate (Loading Spinner)
/// ```dart
/// GlassProgressIndicator.circular()
/// ```
///
/// ### Circular Determinate (Progress Ring)
/// ```dart
/// GlassProgressIndicator.circular(
///   value: 0.7, // 70% complete
/// )
/// ```
///
/// ### Linear Indeterminate (Loading Bar)
/// ```dart
/// GlassProgressIndicator.linear()
/// ```
///
/// ### Linear Determinate (Progress Bar)
/// ```dart
/// GlassProgressIndicator.linear(
///   value: 0.5, // 50% complete
/// )
/// ```
///
/// ### Custom Size and Color
/// ```dart
/// GlassProgressIndicator.circular(
///   value: 0.3,
///   size: 40.0,
///   strokeWidth: 4.0,
///   color: Colors.green,
/// )
/// ```
///
/// ### Standalone Mode
/// ```dart
/// GlassProgressIndicator.circular(
///   useOwnLayer: true,
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 12,
///   ),
/// )
/// ```
///
/// ### Within LiquidGlassLayer
/// ```dart
/// AdaptiveLiquidGlassLayer(
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 12,
///   ),
///   child: Column(
///     children: [
///       GlassProgressIndicator.circular(),
///       SizedBox(height: 20),
///       GlassProgressIndicator.linear(value: 0.6),
///     ],
///   ),
/// )
/// ```
class GlassProgressIndicator extends StatefulWidget {
  /// Creates a circular glass progress indicator.
  ///
  /// If [value] is null, the indicator is indeterminate (infinite animation).
  /// If [value] is non-null (0.0 to 1.0), the indicator shows determinate progress.
  const GlassProgressIndicator.circular({
    super.key,
    this.value,
    this.size = 20.0,
    this.strokeWidth = 2.5,
    this.color,
    this.backgroundColor,
    this.useOwnLayer = false,
    this.settings,
    this.quality,
    this.semanticLabel,
  })  : _type = _ProgressIndicatorType.circular,
        height = null,
        minWidth = null;

  /// Creates a linear glass progress indicator.
  ///
  /// If [value] is null, the indicator is indeterminate (infinite animation).
  /// If [value] is non-null (0.0 to 1.0), the indicator shows determinate progress.
  const GlassProgressIndicator.linear({
    super.key,
    this.value,
    this.height = 4.0,
    this.minWidth = 200.0,
    this.color,
    this.backgroundColor,
    this.useOwnLayer = false,
    this.settings,
    this.quality,
    this.semanticLabel,
  })  : _type = _ProgressIndicatorType.linear,
        size = null,
        strokeWidth = null;

  // ===========================================================================
  // Progress Properties
  // ===========================================================================

  /// The current progress value (0.0 to 1.0).
  ///
  /// If null, the indicator is indeterminate (infinite animation).
  /// If non-null, the indicator shows determinate progress.
  ///
  /// - `0.0` = 0% complete (no progress)
  /// - `0.5` = 50% complete (half progress)
  /// - `1.0` = 100% complete (full progress)
  final double? value;

  /// The color of the progress indicator.
  ///
  /// If null, uses theme's primary glow color or iOS blue (#007AFF).
  final Color? color;

  /// The background color (track color).
  ///
  /// If null, uses semi-transparent white (#26FFFFFF - 15% opacity).
  final Color? backgroundColor;

  // ===========================================================================
  // Size Properties
  // ===========================================================================

  /// Size of the circular progress indicator (diameter).
  ///
  /// **iOS 26 Standard Sizes**:
  /// - `20.0` - Default (matches UIActivityIndicator medium)
  /// - `14.0` - Small
  /// - `28.0` - Large
  ///
  /// Only applies to circular indicators. Ignored for linear.
  final double? size;

  /// Stroke width of the circular progress indicator.
  ///
  /// **iOS 26 Standard**: `2.5pt` (default)
  ///
  /// Only applies to circular indicators. Ignored for linear.
  final double? strokeWidth;

  /// Height of the linear progress indicator.
  ///
  /// **iOS 26 Standard**: `4.0pt` (default)
  ///
  /// Only applies to linear indicators. Ignored for circular.
  final double? height;

  /// Minimum width of the linear progress indicator.
  ///
  /// Defaults to `200.0` to ensure visibility.
  ///
  /// Only applies to linear indicators. Ignored for circular.
  final double? minWidth;

  // ===========================================================================
  // Glass Effect Properties
  // ===========================================================================

  /// Whether to create its own [AdaptiveLiquidGlassLayer].
  ///
  /// If false (default), the indicator must be inside a [AdaptiveLiquidGlassLayer].
  /// If true, creates an independent glass layer with [settings].
  final bool useOwnLayer;

  /// Glass effect settings for standalone mode.
  ///
  /// Only used when [useOwnLayer] is true.
  /// If null, uses [LiquidGlassSettings] defaults.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  ///
  /// If null, inherits from parent or theme, or defaults to [GlassQuality.standard].
  final GlassQuality? quality;

  /// Overrides the VoiceOver / TalkBack label for this indicator.
  ///
  /// When null the default is `'Progress'`. Set this to describe what is
  /// actually loading so screen-reader users get meaningful context:
  ///
  /// ```dart
  /// GlassProgressIndicator.linear(
  ///   value: downloadProgress,
  ///   semanticLabel: 'Download progress',
  /// )
  /// ```
  final String? semanticLabel;

  // ===========================================================================
  // Private Properties
  // ===========================================================================

  final _ProgressIndicatorType _type;

  @override
  State<GlassProgressIndicator> createState() => _GlassProgressIndicatorState();
}

class _GlassProgressIndicatorState extends State<GlassProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000), // iOS 26: 1.0s rotation
      vsync: this,
    );

    // Start animation only if indeterminate
    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(GlassProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle indeterminate ↔ determinate transitions
    if (widget.value == null && oldWidget.value != null) {
      // Switched to indeterminate
      _controller.repeat();
    } else if (widget.value != null && oldWidget.value == null) {
      // Switched to determinate
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve colors from theme if not explicitly provided
    final themeData = GlassThemeData.of(context);
    final effectiveColor = widget.color ??
        themeData.glowColorsFor(context).primary ??
        CupertinoColors.activeBlue.resolveFrom(
            context); // iOS system blue (adaptive: 007AFF light / 0A84FF dark)
    final effectiveBackgroundColor =
        widget.backgroundColor ?? const Color(0x26FFFFFF); // 15% white

    final indicator = widget._type == _ProgressIndicatorType.circular
        ? _buildCircular(effectiveColor, effectiveBackgroundColor)
        : _buildLinear(effectiveColor, effectiveBackgroundColor);

    // Semantics: determinate → percentage value; indeterminate → "Loading"
    // Matches iOS ProgressView VoiceOver behaviour.
    final valueStr = widget.value != null
        ? '${(widget.value!.clamp(0.0, 1.0) * 100).round()}%'
        : null;
    final semanticWidget = Semantics(
      label: widget.semanticLabel ?? 'Progress',
      value: valueStr,
      // liveRegion so dynamic changes are announced without needing focus
      liveRegion: widget.value != null,
      child: indicator,
    );

    // Wrap in glass layer if standalone
    if (widget.useOwnLayer) {
      return AdaptiveLiquidGlassLayer(
        settings: widget.settings ?? const LiquidGlassSettings(),
        quality: widget.quality,
        child: semanticWidget,
      );
    }

    return semanticWidget;
  }

  Widget _buildCircular(Color color, Color backgroundColor) {
    final size = widget.size ?? 20.0;
    final strokeWidth = widget.strokeWidth ?? 2.5;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularProgressPainter(
              value: widget.value,
              color: color,
              backgroundColor: backgroundColor,
              strokeWidth: strokeWidth,
              rotation: _controller.value * 2 * math.pi,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinear(Color color, Color backgroundColor) {
    final height = widget.height ?? 4.0;
    final minWidth = widget.minWidth ?? 200.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: height,
        maxHeight: height,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _LinearProgressPainter(
              value: widget.value,
              color: color,
              backgroundColor: backgroundColor,
              animation: _controller.value,
              textDirection: Directionality.of(context),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Circular Progress Painter
// =============================================================================

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.rotation,
  });

  final double? value;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background track (glass)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      backgroundPaint,
    );

    // Draw progress arc with glow
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Add glass glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    if (value == null) {
      // Indeterminate: rotating arc (90 degrees)
      final startAngle = rotation - math.pi / 2; // Start at top
      final sweepAngle = math.pi / 2; // 90 degrees (iOS standard)

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    } else {
      // Determinate: progress ring
      final startAngle = -math.pi / 2; // Start at top
      final sweepAngle = 2 * math.pi * value!.clamp(0.0, 1.0);

      if (sweepAngle > 0) {
        canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
        canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return value != oldDelegate.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        rotation != oldDelegate.rotation;
  }
}

// =============================================================================
// Linear Progress Painter
// =============================================================================

class _LinearProgressPainter extends CustomPainter {
  _LinearProgressPainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.animation,
    required this.textDirection,
  });

  final double? value;
  final Color color;
  final Color backgroundColor;
  final double animation;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    final borderRadius = height / 2; // Fully rounded ends

    // Draw background track (glass)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // Draw progress bar with glow
    double progressWidth;
    double progressX;

    if (value == null) {
      // Indeterminate: moving bar (iOS standard)
      // Bar moves from -30% to 130% (160% total range)
      // Bar width is 30% of track width
      final barWidth = width * 0.3;
      final position = animation * (width + barWidth) - barWidth;

      progressWidth = barWidth;
      progressX = textDirection == TextDirection.rtl
          ? width - position - progressWidth
          : position;
    } else {
      // Determinate: fill from left (or right in RTL)
      progressWidth = width * value!.clamp(0.0, 1.0);
      progressX =
          textDirection == TextDirection.rtl ? width - progressWidth : 0;
    }

    if (progressWidth > 0) {
      // Add glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final glowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(progressX, 0, progressWidth, height),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(glowRect, glowPaint);

      // Draw solid progress
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(progressX, 0, progressWidth, height),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(progressRect, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_LinearProgressPainter oldDelegate) {
    return value != oldDelegate.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor ||
        animation != oldDelegate.animation ||
        textDirection != oldDelegate.textDirection;
  }
}

// =============================================================================
// Internal Types
// =============================================================================

enum _ProgressIndicatorType {
  circular,
  linear,
}

/// A glass-aesthetic empty state and search-unavailable view following Apple's
/// iOS `ContentUnavailableView` design patterns.
class GlassContentUnavailableView extends StatelessWidget {
  /// The icon displayed inside the glass emblem.
  final IconData icon;

  /// Primary bold title.
  final String title;

  /// Optional explanatory subtitle text.
  final String? message;

  /// Optional action button label.
  final String? actionLabel;

  /// Called when the action button is tapped.
  final VoidCallback? onAction;

  /// Custom action widget (overrides [actionLabel] and [onAction]).
  final Widget? action;

  /// Liquid glass settings for the icon emblem.
  final LiquidGlassSettings? settings;

  /// Internal padding.
  final EdgeInsetsGeometry padding;

  /// Creates a standard [GlassContentUnavailableView].
  const GlassContentUnavailableView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.action,
    this.settings,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
  });

  /// Creates an iOS-style search unavailable view matching `ContentUnavailableView.search`.
  factory GlassContentUnavailableView.search({
    Key? key,
    required String query,
    VoidCallback? onClear,
    String? title,
    String? message,
    String? clearButtonLabel,
    LiquidGlassSettings? settings,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
  }) {
    return GlassContentUnavailableView(
      key: key,
      icon: CupertinoIcons.search,
      title: title ?? (query.trim().isEmpty ? 'No Results' : 'No Results for "$query"'),
      message: message ??
          'Check the spelling or try a new search.',
      actionLabel: onClear != null ? (clearButtonLabel ?? 'Clear Search') : null,
      onAction: onClear,
      settings: settings,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF09090B);
    final secondaryTextColor =
        isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    final glassSettings = settings ??
        (isDark
            ? const LiquidGlassSettings(
                thickness: 16,
                blur: 16,
                glassColor: Color(0x33FFFFFF),
                refractiveIndex: 1.15,
              )
            : const LiquidGlassSettings(
                thickness: 14,
                blur: 14,
                glassColor: Color(0x66FFFFFF),
                refractiveIndex: 1.12,
              ));

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Liquid Glass Icon Emblem
            GlassContainer(
              useOwnLayer: true,
              width: 76,
              height: 76,
              shape: const LiquidRoundedRectangle(borderRadius: 24),
              settings: glassSettings,
              child: Center(
                child: Icon(
                  icon,
                  size: 34,
                  color: isDark
                      ? const Color(0xFFE4E4E7)
                      : const Color(0xFF3F3F46),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: primaryTextColor,
              ),
            ),

            // Subtitle / Message
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  color: secondaryTextColor,
                ),
              ),
            ],

            // Action Button
            if (action != null) ...[
              const SizedBox(height: 22),
              action!,
            ] else if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              GlassButton.custom(
                useOwnLayer: true,
                onTap: onAction!,
                shape: const LiquidRoundedRectangle(borderRadius: 18),
                height: 38,
                settings: isDark
                    ? const LiquidGlassSettings(
                        thickness: 12,
                        blur: 12,
                        glassColor: Color(0x33FFFFFF),
                      )
                    : const LiquidGlassSettings(
                        thickness: 12,
                        blur: 12,
                        glassColor: Color(0x88FFFFFF),
                      ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFE4E4E7)
                            : const Color(0xFF18181B),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
