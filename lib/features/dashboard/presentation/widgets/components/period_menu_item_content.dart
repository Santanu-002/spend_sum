import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

/// Content widget for a period popup menu item.
///
/// Renders the label text with an optional check icon when selected.
class PeriodMenuItemContent extends StatelessWidget {
  final String label;
  final bool isSelected;

  const PeriodMenuItemContent({
    super.key,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? themeExt.primary : themeExt.onSurface,
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check_rounded,
            size: AppDimensions.iconSm,
            color: themeExt.primary,
          ),
      ],
    );
  }
}
