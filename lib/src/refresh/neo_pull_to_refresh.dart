import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/neo_theme.dart';

/// An authentic iOS 26 Liquid Glass sliver refresh control.
///
/// Designed for use inside a [CustomScrollView]'s slivers list. As the user
/// pulls down, a morphing translucent glass capsule expands from the top edge,
/// triggers haptic feedback when armed, and displays a refractive activity
/// spinner during the refresh operation.
class GlassSliverRefreshControl extends StatefulWidget {
  /// Creates a Liquid Glass sliver refresh control.
  const GlassSliverRefreshControl({
    super.key,
    this.refreshTriggerPullDistance = 100.0,
    this.refreshIndicatorExtent = 60.0,
    this.onRefresh,
    this.hapticFeedback = true,
  });

  /// The amount of overscroll required to trigger the refresh.
  final double refreshTriggerPullDistance;

  /// The resting height of the indicator during an active refresh.
  final double refreshIndicatorExtent;

  /// Callback executed when the user pulls past [refreshTriggerPullDistance].
  final Future<void> Function()? onRefresh;

  /// Whether to trigger subtle haptic feedback when the indicator becomes armed.
  final bool hapticFeedback;

  @override
  State<GlassSliverRefreshControl> createState() =>
      _GlassSliverRefreshControlState();
}

class _GlassSliverRefreshControlState extends State<GlassSliverRefreshControl> {
  bool _hasFiredHaptic = false;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.maybeOf(context);
    final isDark = (theme?.brightness ??
            MediaQuery.platformBrightnessOf(context)) ==
        Brightness.dark;

    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: widget.refreshTriggerPullDistance,
      refreshIndicatorExtent: widget.refreshIndicatorExtent,
      onRefresh: widget.onRefresh,
      builder: (
        BuildContext context,
        RefreshIndicatorMode refreshState,
        double pulledExtent,
        double refreshTriggerPullDistance,
        double refreshIndicatorExtent,
      ) {
        final double progress = (pulledExtent / refreshTriggerPullDistance)
            .clamp(0.0, 1.0);

        if (refreshState == RefreshIndicatorMode.armed && !_hasFiredHaptic) {
          if (widget.hapticFeedback) {
            HapticFeedback.mediumImpact();
          }
          _hasFiredHaptic = true;
        } else if (refreshState != RefreshIndicatorMode.armed) {
          _hasFiredHaptic = false;
        }

        if (pulledExtent <= 0.0) {
          return const SizedBox.shrink();
        }

        final double opacity = (progress * 1.5).clamp(0.0, 1.0);
        final double scale = 0.8 + (progress * 0.2);

        return Center(
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.85),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.25 : 0.06,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (refreshState == RefreshIndicatorMode.refresh)
                      CupertinoActivityIndicator(
                        radius: 9,
                        color: theme?.primaryColor ??
                            CupertinoColors.activeBlue,
                      )
                    else
                      Transform.rotate(
                        angle: progress * 2 * math.pi,
                        child: Icon(
                          CupertinoIcons.arrow_2_circlepath,
                          size: 18,
                          color: (theme?.primaryColor ??
                                  CupertinoColors.activeBlue)
                              .withValues(
                            alpha: (0.4 + progress * 0.6).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      refreshState == RefreshIndicatorMode.refresh
                          ? 'Updating…'
                          : (refreshState == RefreshIndicatorMode.armed
                              ? 'Release to refresh'
                              : 'Pull to refresh'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : const Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A drop-in iOS 26 Liquid Glass pull-to-refresh container for scrollable content.
class NeoPullToRefresh extends StatelessWidget {
  /// Wraps an existing scrollable widget (e.g. [CustomScrollView]).
  const NeoPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.refreshTriggerPullDistance = 100.0,
    this.refreshIndicatorExtent = 60.0,
    this.hapticFeedback = true,
  })  : slivers = null,
        children = null,
        itemBuilder = null,
        itemCount = null;

  /// Creates a pull-to-refresh list with explicit children.
  const NeoPullToRefresh.list({
    super.key,
    required this.onRefresh,
    required this.children,
    this.refreshTriggerPullDistance = 100.0,
    this.refreshIndicatorExtent = 60.0,
    this.hapticFeedback = true,
  })  : child = null,
        slivers = null,
        itemBuilder = null,
        itemCount = null;

  /// Creates a pull-to-refresh list with an item builder.
  const NeoPullToRefresh.builder({
    super.key,
    required this.onRefresh,
    required this.itemBuilder,
    this.itemCount,
    this.refreshTriggerPullDistance = 100.0,
    this.refreshIndicatorExtent = 60.0,
    this.hapticFeedback = true,
  })  : child = null,
        slivers = null,
        children = null;

  /// Creates a pull-to-refresh with custom slivers.
  const NeoPullToRefresh.slivers({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.refreshTriggerPullDistance = 100.0,
    this.refreshIndicatorExtent = 60.0,
    this.hapticFeedback = true,
  })  : child = null,
        children = null,
        itemBuilder = null,
        itemCount = null;

  /// The asynchronous callback invoked when refresh is triggered.
  final Future<void> Function() onRefresh;

  /// The optional single child widget.
  final Widget? child;

  /// Explicit list of children if built via [NeoPullToRefresh.list].
  final List<Widget>? children;

  /// Builder for dynamic items via [NeoPullToRefresh.builder].
  final NullableIndexedWidgetBuilder? itemBuilder;

  /// Item count for [itemBuilder].
  final int? itemCount;

  /// Explicit slivers list if built via [NeoPullToRefresh.slivers].
  final List<Widget>? slivers;

  /// The amount of overscroll required to trigger refresh.
  final double refreshTriggerPullDistance;

  /// The resting height during active refresh.
  final double refreshIndicatorExtent;

  /// Whether to fire haptic feedback when the indicator reaches the trigger threshold.
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final refreshSliver = GlassSliverRefreshControl(
      onRefresh: onRefresh,
      refreshTriggerPullDistance: refreshTriggerPullDistance,
      refreshIndicatorExtent: refreshIndicatorExtent,
      hapticFeedback: hapticFeedback,
    );

    if (slivers != null) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          refreshSliver,
          ...slivers!,
        ],
      );
    }

    if (children != null) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          refreshSliver,
          SliverList.list(children: children!),
        ],
      );
    }

    if (itemBuilder != null) {
      return CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          refreshSliver,
          SliverList.builder(
            itemCount: itemCount,
            itemBuilder: itemBuilder!,
          ),
        ],
      );
    }

    if (child is CustomScrollView) {
      final custom = child as CustomScrollView;
      return CustomScrollView(
        key: custom.key,
        scrollDirection: custom.scrollDirection,
        reverse: custom.reverse,
        controller: custom.controller,
        primary: custom.primary,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        shrinkWrap: custom.shrinkWrap,
        cacheExtent: custom.cacheExtent,
        semanticChildCount: custom.semanticChildCount,
        dragStartBehavior: custom.dragStartBehavior,
        keyboardDismissBehavior: custom.keyboardDismissBehavior,
        restorationId: custom.restorationId,
        clipBehavior: custom.clipBehavior,
        slivers: [
          refreshSliver,
          ...custom.slivers,
        ],
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        refreshSliver,
        SliverToBoxAdapter(child: child),
      ],
    );
  }
}
