import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/widget/layout/skeleton_loader.dart';

class SkeletonHistoryTile extends StatelessWidget {
  const SkeletonHistoryTile({super.key});

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadMd),
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SkeletonLoader(
        child: Row(
          children: const [
            SkeletonBox(width: 40, height: 40, shape: BoxShape.circle),
            SizedBox(width: AppDimensions.tileHorizontalPad),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(width: 90, height: 14, borderRadius: 4),
                  SizedBox(height: 4),
                  SkeletonBox(width: 110, height: 10, borderRadius: 4),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(width: 50, height: 12, borderRadius: 4),
                SizedBox(height: 4),
                SkeletonBox(width: 50, height: 12, borderRadius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
