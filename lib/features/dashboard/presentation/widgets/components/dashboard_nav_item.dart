import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

class DashboardNavItem extends StatelessWidget {
  final IconData icon;
  final IconData unselectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DashboardNavItem({
    super.key,
    required this.icon,
    required this.unselectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;
    final color = isSelected
        ? themeExt.primary
        : themeExt.onSurfaceVariant.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.stackSm,
          vertical: AppDimensions.stackSm / 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? icon : unselectedIcon,
              color: color,
              size: AppDimensions.iconNavSize,
            ),
            const SizedBox(height: AppDimensions.stackSm / 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
