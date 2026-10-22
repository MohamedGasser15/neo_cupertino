import 'package:flutter/cupertino.dart';
import '../liquid_glass/liquid_glass.dart';

/// Centralized theme configuration for Neo-Cupertino applications and widgets.
///
/// Encapsulates visual design tokens: accent colors, typography, continuous squircle
/// curvature, haptic preferences, and shader settings for the Liquid Glass system.
@immutable
class NeoThemeData {
  /// Creates a unified Neo-Cupertino theme configuration.
  const NeoThemeData({
    this.brightness,
    this.primaryColor = CupertinoColors.activeBlue,
    this.primaryContrastingColor = CupertinoColors.white,
    this.scaffoldBackgroundColor,
    this.barBackgroundColor,
    this.cardColor,
    this.glassTheme = const GlassThemeData(),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.hapticsEnabled = true,
    this.textTheme,
  });

  /// The brightness override for this theme, or null to follow the system.
  final Brightness? brightness;

  /// Primary accent color used for active switches, prominent buttons,
  /// and interactive focus highlights. Defaults to iOS standard blue.
  final Color primaryColor;

  /// High-contrast foreground color used for text/icons displayed on [primaryColor].
  final Color primaryContrastingColor;

  /// Background color for top-level pages and scaffolds.
  final Color? scaffoldBackgroundColor;

  /// Translucent background color for navigation bars, pinned toolbars, and tab bars.
  final Color? barBackgroundColor;

  /// Surface background color for grouped cards and list tiles.
  final Color? cardColor;

  /// Liquid Glass shader configuration and glow color palettes.
  final GlassThemeData glassTheme;

  /// Default continuous squircle border radius for cards, dialogs, and sheets.
  final BorderRadiusGeometry borderRadius;

  /// Whether subtle iOS haptic clicks should be triggered on user interactions.
  final bool hapticsEnabled;

  /// Cupertino typography hierarchy.
  final CupertinoTextThemeData? textTheme;

  /// Creates a light mode Neo-Cupertino theme.
  factory NeoThemeData.light({
    Color primaryColor = CupertinoColors.activeBlue,
    Color primaryContrastingColor = CupertinoColors.white,
    Color? scaffoldBackgroundColor,
    Color? barBackgroundColor,
    Color? cardColor,
    GlassThemeData? glassTheme,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(16)),
    bool hapticsEnabled = true,
    CupertinoTextThemeData? textTheme,
  }) {
    return NeoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      primaryContrastingColor: primaryContrastingColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? const Color(0xFFF2F2F7),
      barBackgroundColor: barBackgroundColor ?? const Color(0xCCF2F2F7),
      cardColor: cardColor ?? const Color(0xFFFFFFFF),
      glassTheme: glassTheme ?? const GlassThemeData(brightness: Brightness.light),
      borderRadius: borderRadius,
      hapticsEnabled: hapticsEnabled,
      textTheme: textTheme,
    );
  }

  /// Creates a dark mode Neo-Cupertino theme.
  factory NeoThemeData.dark({
    Color primaryColor = CupertinoColors.activeBlue,
    Color primaryContrastingColor = CupertinoColors.white,
    Color? scaffoldBackgroundColor,
    Color? barBackgroundColor,
    Color? cardColor,
    GlassThemeData? glassTheme,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(16)),
    bool hapticsEnabled = true,
    CupertinoTextThemeData? textTheme,
  }) {
    return NeoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      primaryContrastingColor: primaryContrastingColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? const Color(0xFF000000),
      barBackgroundColor: barBackgroundColor ?? const Color(0xCC1C1C1E),
      cardColor: cardColor ?? const Color(0xFF1C1C1E),
      glassTheme: glassTheme ?? const GlassThemeData(brightness: Brightness.dark),
      borderRadius: borderRadius,
      hapticsEnabled: hapticsEnabled,
      textTheme: textTheme,
    );
  }

  /// Creates a copy of this theme data with the given fields replaced.
  NeoThemeData copyWith({
    Brightness? brightness,
    Color? primaryColor,
    Color? primaryContrastingColor,
    Color? scaffoldBackgroundColor,
    Color? barBackgroundColor,
    Color? cardColor,
    GlassThemeData? glassTheme,
    BorderRadiusGeometry? borderRadius,
    bool? hapticsEnabled,
    CupertinoTextThemeData? textTheme,
  }) {
    return NeoThemeData(
      brightness: brightness ?? this.brightness,
      primaryColor: primaryColor ?? this.primaryColor,
      primaryContrastingColor:
          primaryContrastingColor ?? this.primaryContrastingColor,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      barBackgroundColor: barBackgroundColor ?? this.barBackgroundColor,
      cardColor: cardColor ?? this.cardColor,
      glassTheme: glassTheme ?? this.glassTheme,
      borderRadius: borderRadius ?? this.borderRadius,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      textTheme: textTheme ?? this.textTheme,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NeoThemeData &&
        other.brightness == brightness &&
        other.primaryColor == primaryColor &&
        other.primaryContrastingColor == primaryContrastingColor &&
        other.scaffoldBackgroundColor == scaffoldBackgroundColor &&
        other.barBackgroundColor == barBackgroundColor &&
        other.cardColor == cardColor &&
        other.glassTheme == glassTheme &&
        other.borderRadius == borderRadius &&
        other.hapticsEnabled == hapticsEnabled &&
        other.textTheme == textTheme;
  }

  @override
  int get hashCode => Object.hash(
        brightness,
        primaryColor,
        primaryContrastingColor,
        scaffoldBackgroundColor,
        barBackgroundColor,
        cardColor,
        glassTheme,
        borderRadius,
        hapticsEnabled,
        textTheme,
      );
}
