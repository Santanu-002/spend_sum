import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';

class TransactionFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const TransactionFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: ['All', 'Expense', 'Income'].map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              label: Text(filter),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                if (selected) {
                  onFilterSelected(filter);
                }
              },
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? themeExt.onPrimary : themeExt.onSurface,
              ),
              selectedColor: themeExt.primary,
              backgroundColor: themeExt.cardColor,
              shadowColor: Colors.black.withValues(alpha: 0.02),
              elevation: isSelected ? 2 : 0,
              side: BorderSide(
                color: isSelected
                    ? themeExt.primary
                    : themeExt.outlineVariant.withValues(alpha: 0.15),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
