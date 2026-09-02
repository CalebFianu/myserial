import 'package:flutter/material.dart';

/// A [SliverPersistentHeader] that keeps [child] fixed at the top of a
/// [CustomScrollView] instead of scrolling away with the rest of the
/// content — used for back-button bars that must stay tappable while
/// the screen scrolls.
SliverPersistentHeader pinnedHeader({
  required double height,
  required Widget child,
  Color? background,
}) {
  return SliverPersistentHeader(
    pinned: true,
    delegate: _PinnedHeaderDelegate(
      height: height,
      background: background,
      child: child,
    ),
  );
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedHeaderDelegate({
    required this.height,
    required this.child,
    this.background,
  });

  final double height;
  final Widget child;
  final Color? background;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Force the exact declared height regardless of the child's intrinsic
    // size — otherwise a child shorter than `height` makes the sliver
    // report a paintExtent smaller than its layoutExtent, which crashes
    // with "layoutExtent exceeds paintExtent".
    return SizedBox(
      height: height,
      child: Container(color: background, child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.child != child ||
        oldDelegate.background != background;
  }
}
