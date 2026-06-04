import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

class AnalyticsHistoryTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final double incomeAmount;
  final double expenseAmount;
  final String currencySymbol;

  const AnalyticsHistoryTile({
    super.key,
    required this.label,
    required this.sublabel,
    required this.incomeAmount,
    required this.expenseAmount,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.iconContainerPad),
            decoration: BoxDecoration(
              color: themeExt.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              color: themeExt.primary,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(width: AppDimensions.tileHorizontalPad),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: themeExt.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sublabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: themeExt.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '+$currencySymbol${incomeAmount.toStringAsFixed(2)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: themeExt.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '-$currencySymbol${expenseAmount.toStringAsFixed(2)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: themeExt.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
