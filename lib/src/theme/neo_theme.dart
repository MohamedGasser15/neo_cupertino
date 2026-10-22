import 'package:flutter/cupertino.dart';
import '../liquid_glass/liquid_glass.dart';
import 'neo_theme_data.dart';

/// An [InheritedWidget] that provides [NeoThemeData] to descendant widgets.
///
/// Automatically synchronizes both [CupertinoTheme] and [GlassTheme] down the
/// subtree, allowing standard Cupertino controls and Liquid Glass widgets to
/// share cohesive colors, typography, and brightness styling.
///
/// ## Usage
///
/// ```dart
/// NeoTheme(
///   data: NeoThemeData.light(
///     primaryColor: CupertinoColors.systemIndigo,
///   ),
///   child: const MyApp(),
/// )
/// ```
class NeoTheme extends StatelessWidget {
  /// Creates a Neo-Cupertino theme provider.
  const NeoTheme({
    super.key,
    required this.data,
    required this.child,
  });

  /// The theme configuration.
  final NeoThemeData data;

  /// The widget below this in the tree.
  final Widget child;

  /// Retrieves the nearest [NeoThemeData] from the widget tree, or falls back
  /// to a system-adapted default theme if none is found.
  static NeoThemeData of(BuildContext context) {
    final _NeoThemeInherited? inherited =
        context.dependOnInheritedWidgetOfExactType<_NeoThemeInherited>();
    return inherited?.data ?? _defaultThemeFor(context);
  }

  /// Retrieves the nearest [NeoThemeData] from the widget tree, or null if none.
  static NeoThemeData? maybeOf(BuildContext context) {
    final _NeoThemeInherited? inherited =
        context.dependOnInheritedWidgetOfExactType<_NeoThemeInherited>();
    return inherited?.data;
  }

  /// Resolves the effective brightness from the nearest [NeoTheme], or falls back
  /// to the device system brightness.
  static Brightness brightnessOf(BuildContext context) {
    final theme = maybeOf(context);
    if (theme?.brightness != null) return theme!.brightness!;
    return MediaQuery.platformBrightnessOf(context);
  }

  static NeoThemeData _defaultThemeFor(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.dark
        ? NeoThemeData.dark()
        : NeoThemeData.light();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedBrightness =
        data.brightness ?? MediaQuery.platformBrightnessOf(context);

    final cupertinoTheme = CupertinoThemeData(
      brightness: resolvedBrightness,
      primaryColor: data.primaryColor,
      primaryContrastingColor: data.primaryContrastingColor,
      barBackgroundColor: data.barBackgroundColor,
      scaffoldBackgroundColor: data.scaffoldBackgroundColor,
      textTheme: data.textTheme,
    );

    return _NeoThemeInherited(
      data: data,
      child: GlassTheme(
        data: data.glassTheme,
        child: CupertinoTheme(
          data: cupertinoTheme,
          child: child,
        ),
      ),
    );
  }
}

class _NeoThemeInherited extends InheritedWidget {
  const _NeoThemeInherited({
    required this.data,
    required super.child,
  });

  final NeoThemeData data;

  @override
  bool updateShouldNotify(_NeoThemeInherited oldWidget) =>
      data != oldWidget.data;
}
