part of 'select_category_sheet.dart';

// ---------------------------------------------------------------------------
// _CategoryGridItem — single icon + label tile
// ---------------------------------------------------------------------------

class _CategoryGridItem extends StatelessWidget {
  final Map<String, dynamic> category;
  final void Function(Map<String, dynamic> cat) onTap;
  final bool isExpense;

  const _CategoryGridItem({
    required this.category,
    required this.onTap,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;
    final isAdd = category['isAddButton'] == true;

    // For the Add button, derive color from theme; for categories use stored color.
    final iconColor = isAdd ? themeExt.primary : category['color'] as Color;

    return GestureDetector(
      onTap: () => onTap(category),
      child: Column(
        children: [
          // Icon card
          Container(
            width: AppDimensions.avatarLg,
            height: AppDimensions.avatarLg,
            decoration: BoxDecoration(
              color: themeExt.cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
              border: isAdd
                  ? Border.all(
                      color: themeExt.primary.withValues(alpha: 0.4),
                      style: BorderStyle.solid,
                      width: 1.5,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                category['icon'] as IconData,
                color: iconColor,
                size: AppDimensions.iconLg,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.stackSm),
          // Label
          Text(
            category['name'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: themeExt.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
