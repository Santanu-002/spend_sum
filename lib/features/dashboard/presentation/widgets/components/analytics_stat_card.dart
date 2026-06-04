import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/widget/layout/skeleton_loader.dart';

class AnalyticsStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currencySymbol;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isLoading;

  const AnalyticsStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.currencySymbol,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.tileHorizontalPad),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.stackSm),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusIcon),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: AppDimensions.iconNavSize,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  const SkeletonLoader(
                    child: SkeletonBox(width: 60, height: 16, borderRadius: 4),
                  )
                else
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0.0, end: amount),
                    builder: (context, value, child) {
                      return Text(
                        '$currencySymbol${value.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: themeExt.onSurface,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: themeExt.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
