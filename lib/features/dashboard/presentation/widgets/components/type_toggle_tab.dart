import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

/// A reusable type tab selector (e.g. for choosing between Expense and Income tabs).
class TypeToggleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TypeToggleTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: AppDimensions.tabHeight,
        decoration: BoxDecoration(
          color: isSelected ? themeExt.primary : themeExt.surfaceContainer,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeExt.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected ? themeExt.onPrimary : themeExt.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
