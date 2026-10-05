import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../context_menu/neo_single_tap_context_menu.dart';
import '../utils/platform_info.dart';

/// A widget that triggers a native iOS context menu (UIMenu) strictly on HOLD / long press
/// on iOS, opening strictly above or below the card (never covering it), with strong haptic
/// vibration, and ensuring single taps select the wallet without sticking or re-opening.
class IosHoldContextMenu extends StatefulWidget {
  final Widget child;
  final List<IosContextMenuItem> actions;
  final ValueChanged<String>? onSelected;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const IosHoldContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.onSelected,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<IosHoldContextMenu> createState() => _IosHoldContextMenuState();
}

class _IosHoldContextMenuState extends State<IosHoldContextMenu> {
  static const MethodChannel _iosHostChannel =
      MethodChannel('neo_cupertino/context_menu_methods');

  late final String _instanceId;
  late final MethodChannel _iosInstanceChannel;
  bool _isMenuOpen = false;
  DateTime _lastOpenTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastDismissTime = DateTime.fromMillisecondsSinceEpoch(0);

  bool get _isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _instanceId =
        '${identityHashCode(this)}_${DateTime.now().microsecondsSinceEpoch}';
    _iosInstanceChannel = MethodChannel(
      'neo_cupertino/context_menu_instance_$_instanceId',
    );
    _iosInstanceChannel.setMethodCallHandler(_handleCallback);
  }

  @override
  void dispose() {
    _disposeAnchorButton();
    _iosInstanceChannel.setMethodCallHandler(null);
    super.dispose();
  }

  void _disposeAnchorButton() {
    if (_isIos) {
      _iosHostChannel.invokeMethod<void>('disposeInstance', {
        'instanceId': _instanceId,
      });
    }
  }

  Future<void> _handleCallback(MethodCall call) async {
    if (call.method == 'onDismissed') {
      _isMenuOpen = false;
      _lastDismissTime = DateTime.now();
      return;
    }

    if (call.method != 'onSelected' || widget.onSelected == null) {
      return;
    }

    _isMenuOpen = false;
    _lastDismissTime = DateTime.now();

    final Object? args = call.arguments;
    if (args is! Map<Object?, Object?>) {
      return;
    }
    final Object? rawId = args['id'];
    if (rawId is String && rawId.isNotEmpty) {
      _disposeAnchorButton();
      HapticFeedback.selectionClick();
      widget.onSelected!.call(rawId);
    }
  }

  Future<void> _showIosMenu() async {
    final now = DateTime.now();
    // Guard against rapid triggering, repeated taps, or reopening right after dismissal
    if (_isMenuOpen ||
        now.difference(_lastOpenTime).inMilliseconds < 450 ||
        now.difference(_lastDismissTime).inMilliseconds < 350) {
      return;
    }

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }

    _lastOpenTime = now;
    _isMenuOpen = true;

    final double screenHeight =
        MediaQuery.maybeOf(context)?.size.height ?? 800.0;
    final Rect anchorRect =
        renderObject.localToGlobal(Offset.zero) & renderObject.size;
    final params = await _buildCreationParams();

    // Check available vertical screen space to guarantee the menu
    // appears strictly UNDER the card (or above if near the bottom edge),
    // NEVER on top of the card itself!
    final bool hasSpaceBelow = (anchorRect.bottom + 220.0) <= screenHeight;
    final double targetY = hasSpaceBelow
        ? (anchorRect.bottom + 4.0)
        : (anchorRect.top - 4.0);

    params['instanceId'] = _instanceId;
    params['x'] = anchorRect.left;
    params['y'] = targetY;
    params['width'] = anchorRect.width;
    params['height'] = 1.0;

    await _iosHostChannel.invokeMethod<void>('showMenu', params);
  }

  Future<Map<String, Object?>> _buildCreationParams() async {
    final serialized = <Map<String, Object?>>[];
    for (final item in widget.actions) {
      if (item is IosContextMenuDivider) {
        serialized.add(const <String, Object?>{'type': 'divider'});
      } else if (item is IosContextMenuAction) {
        serialized.add(<String, Object?>{
          'type': 'action',
          'id': item.id,
          'title': item.title,
          'iconSystemName': item.iconSystemName,
          'showTrailingCheckmark': item.showTrailingCheckmark,
          'destructive': item.destructive,
          'enabled': item.enabled,
        });
      }
    }
    return <String, Object?>{'actions': serialized};
  }

  void _handleTap() {
    final now = DateTime.now();
    // Ignore tap if menu is open or was dismissed within 350ms (avoids firing tap on dismissal touch)
    if (_isMenuOpen || now.difference(_lastDismissTime).inMilliseconds < 350) {
      return;
    }
    _disposeAnchorButton();
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  void _handleTapDown(TapDownDetails _) {
    // Only dispose if menu is not currently active
    if (!_isMenuOpen) {
      _disposeAnchorButton();
    }
  }

  Future<void> _showAndroidMenu() async {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final origin = renderObject.localToGlobal(Offset.zero);
    final rect = origin & renderObject.size;

    final entries = <PopupMenuEntry<String>>[];
    for (final item in widget.actions) {
      if (item is IosContextMenuDivider) {
        entries.add(const PopupMenuDivider(height: 8));
      } else if (item is IosContextMenuAction) {
        entries.add(
          PopupMenuItem<String>(
            value: item.id,
            enabled: item.enabled,
            child: Text(
              item.title,
              style: item.destructive ? const TextStyle(color: Colors.red) : null,
            ),
          ),
        );
      }
    }
    if (entries.isEmpty) return;

    HapticFeedback.mediumImpact();
    final selectedId = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(rect, Offset.zero & overlay.size),
      items: entries,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    if (selectedId != null && selectedId.isNotEmpty) {
      widget.onSelected?.call(selectedId);
    }
  }

  Future<void> _showCupertinoMenu() async {
    final now = DateTime.now();
    if (_isMenuOpen ||
        now.difference(_lastOpenTime).inMilliseconds < 450 ||
        now.difference(_lastDismissTime).inMilliseconds < 350) {
      return;
    }
    _lastOpenTime = now;
    _isMenuOpen = true;

    final selectedId = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          actions: [
            for (final item in widget.actions)
              if (item is IosContextMenuAction)
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(ctx).pop(item.id),
                  isDestructiveAction: item.destructive,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.showTrailingCheckmark) ...[
                        const Icon(CupertinoIcons.checkmark, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(item.title),
                    ],
                  ),
                ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(),
            isDefaultAction: true,
            child: Text(
              CupertinoLocalizations.of(ctx).cancelButtonLabel,
            ),
          ),
        );
      },
    );

    _isMenuOpen = false;
    _lastDismissTime = DateTime.now();

    if (selectedId != null && selectedId.isNotEmpty) {
      HapticFeedback.selectionClick();
      widget.onSelected?.call(selectedId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isIos || widget.actions.isEmpty) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.actions.isEmpty ? null : _showAndroidMenu,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      );
    }

    if (!PlatformInfo.isIOS26OrHigher()) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: () {
            final now = DateTime.now();
            if (_isMenuOpen ||
                now.difference(_lastOpenTime).inMilliseconds < 450 ||
                now.difference(_lastDismissTime).inMilliseconds < 350) {
              return;
            }
            HapticFeedback.heavyImpact();
            _showCupertinoMenu();
          },
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: _handleTapDown,
        onTap: _handleTap,
        onLongPress: () {
          final now = DateTime.now();
          if (_isMenuOpen ||
              now.difference(_lastOpenTime).inMilliseconds < 450 ||
              now.difference(_lastDismissTime).inMilliseconds < 350) {
            return;
          }
          // Deep, punchy iOS Taptic Engine vibration when hold triggers
          HapticFeedback.heavyImpact();
          _showIosMenu();
        },
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );
  }
}

// Neo-Cupertino aliases
typedef NeoHoldContextMenu = IosHoldContextMenu;
typedef NeoContextMenu = IosHoldContextMenu;
