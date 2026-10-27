import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/neo_theme.dart';

/// A Next-Generation iOS 26 Liquid Glass 3D Wheel Picker.
///
/// Features authentic iOS cylindrical perspective scrolling, an integrated
/// translucent liquid glass selector lens, item magnification, and subtle
/// haptic feedback on selection changes.
class NeoWheelPicker extends StatefulWidget {
  /// Creates a Liquid Glass wheel picker.
  const NeoWheelPicker({
    super.key,
    required this.itemExtent,
    required this.onSelectedItemChanged,
    required this.children,
    this.initialItem = 0,
    this.magnification = 1.12,
    this.squeeze = 1.25,
    this.diameterRatio = 1.07,
    this.useMagnifier = true,
    this.hapticFeedback = true,
    this.scrollController,
  });

  /// The uniform height of each picker item.
  final double itemExtent;

  /// Callback invoked whenever the selected item changes.
  final ValueChanged<int> onSelectedItemChanged;

  /// The list of widgets to display in the wheel.
  final List<Widget> children;

  /// The index of the initially selected item.
  final int initialItem;

  /// The magnification scale factor applied to the center selected item.
  final double magnification;

  /// The squeeze factor applied to the cylindrical 3D curvature.
  final double squeeze;

  /// The relative diameter of the 3D cylinder.
  final double diameterRatio;

  /// Whether to visually magnify the selected item.
  final bool useMagnifier;

  /// Whether to fire a haptic click when the selection moves between items.
  final bool hapticFeedback;

  /// An optional scroll controller.
  final FixedExtentScrollController? scrollController;

  @override
  State<NeoWheelPicker> createState() => _NeoWheelPickerState();
}

class _NeoWheelPickerState extends State<NeoWheelPicker> {
  late FixedExtentScrollController _controller;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.initialItem;
    _controller = widget.scrollController ??
        FixedExtentScrollController(initialItem: widget.initialItem);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleSelectedItemChanged(int index) {
    if (index != _lastIndex) {
      _lastIndex = index;
      if (widget.hapticFeedback) {
        HapticFeedback.selectionClick();
      }
      widget.onSelectedItemChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.maybeOf(context);
    final isDark = (theme?.brightness ??
            MediaQuery.platformBrightnessOf(context)) ==
        Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Liquid Glass Center Selection Lens
        IgnorePointer(
          child: Container(
            height: widget.itemExtent,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.85),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.2 : 0.04,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),

        // Native Cupertino 3D Cylinder Picker
        CupertinoPicker(
          scrollController: _controller,
          itemExtent: widget.itemExtent,
          magnification: widget.magnification,
          useMagnifier: widget.useMagnifier,
          squeeze: widget.squeeze,
          diameterRatio: widget.diameterRatio,
          selectionOverlay: const SizedBox.shrink(), // We use our glass lens
          onSelectedItemChanged: _handleSelectedItemChanged,
          children: widget.children,
        ),
      ],
    );
  }
}

/// Backward compatibility and glass alias
typedef GlassWheelPicker = NeoWheelPicker;

/// Displays an iOS 26 Liquid Glass wheel picker in a modal bottom sheet.
Future<int?> showNeoWheelPicker({
  required BuildContext context,
  required List<String> items,
  int initialIndex = 0,
  String? title,
  String confirmText = 'Done',
  String cancelText = 'Cancel',
}) async {
  int selected = initialIndex;
  final theme = NeoTheme.maybeOf(context);
  final isDark =
      (theme?.brightness ?? MediaQuery.platformBrightnessOf(context)) ==
          Brightness.dark;

  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.9),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Action Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF636366),
                        ),
                      ),
                    ),
                    if (title != null)
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(sheetContext).pop(selected),
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme?.primaryColor ??
                              CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.5),

              // Wheel Picker
              SizedBox(
                height: 216,
                child: NeoWheelPicker(
                  itemExtent: 42,
                  initialItem: initialIndex,
                  onSelectedItemChanged: (index) {
                    selected = index;
                  },
                  children: items.map((text) {
                    return Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.4,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
