import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spend_sum/core/theme/app_colors.dart';

export 'skeleton_box.dart' show SkeletonBox;
export 'skeleton_ring.dart' show SkeletonRing;
export 'skeleton_transaction_tile.dart' show SkeletonTransactionTile;
export 'skeleton_history_tile.dart' show SkeletonHistoryTile;

/// A wrapper widget that applies a shimmer gradient effect to all child [SkeletonBox] items.
class SkeletonLoader extends StatelessWidget {
  final Widget child;

  const SkeletonLoader({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;

    return Shimmer.fromColors(
      baseColor: themeExt.outlineVariant.withValues(alpha: 0.18),
      highlightColor: themeExt.outlineVariant.withValues(alpha: 0.05),
      child: child,
    );
  }
}
