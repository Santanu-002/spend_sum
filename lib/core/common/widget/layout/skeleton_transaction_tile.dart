import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/widget/layout/skeleton_loader.dart';

/// A loading skeleton mockup representing a single TransactionTile.
class SkeletonTransactionTile extends StatelessWidget {
  const SkeletonTransactionTile({super.key});

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;

    return Container(
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.tileHorizontalPad,
        vertical: AppDimensions.tileVerticalPad,
      ),
      child: SkeletonLoader(
        child: Row(
          children: [
            const SkeletonBox(
              width: 40,
              height: 40,
              borderRadius: AppDimensions.radiusIcon,
            ),
            const SizedBox(width: AppDimensions.tileHorizontalPad),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(width: 120, height: 14, borderRadius: 4),
                  SizedBox(height: 4),
                  SkeletonBox(width: 80, height: 12, borderRadius: 4),
                ],
              ),
            ),
            const SkeletonBox(width: 60, height: 16, borderRadius: 4),
            const SizedBox(width: AppDimensions.stackSm),
            Icon(
              Icons.chevron_right_rounded,
              color: themeExt.onSurfaceVariant.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
