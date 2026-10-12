import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../liquid_glass/liquid_glass.dart';

/// Floating Glass "Next" / "التالي" action button above iOS numeric/phone keyboards.
///
/// On iOS, numeric and phone keypads lack a built-in "Done" or "Next" button.
/// This widget provides a native-feeling liquid glass floating pill button anchored
/// cleanly right above the keyboard.
class IosKeyboardFloatingButton extends StatelessWidget {
  /// The focus node(s) associated with the numeric field(s).
  final List<FocusNode> focusNodes;

  /// Optional extra visibility condition (e.g. check for active page in a PageView).
  final bool Function()? isVisible;

  /// Optional custom label. Defaults to 'التالي' in Arabic and 'Next' in English.
  final String? label;

  /// Optional callback invoked when the button is tapped before unfocusing.
  final VoidCallback? onTap;

  /// Distance from the bottom of the screen (default: 8 points above the keyboard).
  final double bottomOffset;

  /// Distance from the trailing edge (default: 16 points).
  final double endOffset;

  /// Whether to use liquid glass styling. Defaults to true on iOS.
  final bool isGlass;

  IosKeyboardFloatingButton({
    super.key,
    FocusNode? focusNode,
    List<FocusNode>? focusNodes,
    this.isVisible,
    this.label,
    this.onTap,
    this.bottomOffset = 8.0,
    this.endOffset = 16.0,
    this.isGlass = true,
  }) : focusNodes = [
          if (focusNode != null) focusNode,
          if (focusNodes != null) ...focusNodes,
        ];

  /// Convenient helper to wrap any widget inside a Stack with this floating button.
  static Widget wrap({
    required Widget child,
    FocusNode? focusNode,
    List<FocusNode>? focusNodes,
    bool Function()? isVisible,
    String? label,
    VoidCallback? onTap,
    double bottomOffset = 8.0,
    double endOffset = 16.0,
    bool isGlass = true,
  }) {
    return Stack(
      children: [
        child,
        IosKeyboardFloatingButton(
          focusNode: focusNode,
          focusNodes: focusNodes,
          isVisible: isVisible,
          label: label,
          onTap: onTap,
          bottomOffset: bottomOffset,
          endOffset: endOffset,
          isGlass: isGlass,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return const SizedBox.shrink();

    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    if (viewInsetsBottom <= 0) return const SizedBox.shrink();

    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final effectiveLabel = label ?? (isAr ? 'التالي' : 'Next');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final listenable = focusNodes.isEmpty
        ? FocusManager.instance.primaryFocus
        : (focusNodes.length == 1
            ? focusNodes.first
            : Listenable.merge(focusNodes));

    Widget buildButton() {
      final hasFocus = focusNodes.isEmpty
          ? (FocusManager.instance.primaryFocus != null)
          : focusNodes.any((node) => node.hasFocus);

      if (!hasFocus) return const SizedBox.shrink();
      if (isVisible != null && !isVisible!()) return const SizedBox.shrink();

      void handleTap() {
        HapticFeedback.selectionClick();
        onTap?.call();
        for (final node in focusNodes) {
          node.unfocus();
        }
        FocusScope.of(context).unfocus();
      }

      Widget textWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text(
            effectiveLabel,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: isDarkMode ? Colors.white : const Color(0xFF09090B),
            ),
          ),
        ),
      );

      return isGlass
          ? GlassButton.custom(
              height: 38,
              shape: const LiquidRoundedRectangle(borderRadius: 19),
              useOwnLayer: true,
              quality: GlassQuality.premium,
              stretch: 0.0,
              interactionScale: 1.0,
              settings: isDarkMode
                  ? const LiquidGlassSettings(
                      thickness: 24,
                      blur: 16,
                      refractiveIndex: 1.25,
                      lightIntensity: 1.8,
                      glassColor: Color(0x35FFFFFF),
                    )
                  : const LiquidGlassSettings(
                      thickness: 24,
                      blur: 16,
                      refractiveIndex: 1.25,
                      lightIntensity: 1.8,
                      glassColor: Color(0x80FFFFFF),
                    ),
              onTap: handleTap,
              child: textWidget,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Material(
                  color: isDarkMode
                      ? const Color(0x9927272A)
                      : const Color(0xDDFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: handleTap,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode ? Colors.white24 : Colors.black12,
                          width: 0.8,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        effectiveLabel,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF09090B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
    }

    return Positioned.directional(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      end: endOffset,
      bottom: viewInsetsBottom + bottomOffset,
      child: listenable != null
          ? ListenableBuilder(
              listenable: listenable,
              builder: (context, _) => buildButton(),
            )
          : buildButton(),
    );
  }
}

// Neo-Cupertino alias
typedef NeoKeyboardFloatingButton = IosKeyboardFloatingButton;
