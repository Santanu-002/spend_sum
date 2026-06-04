import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/presentation/pages/dashboard_page.dart';

class HomeHeaderRow extends StatelessWidget {
  const HomeHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;
    final userState = context.watch<UserCubit>().state;

    String firstName = 'User';
    if (userState is UserLoggedIn) {
      final name = userState.user.name?.trim() ?? '';
      if (name.isNotEmpty) {
        firstName = name.split(' ').first;
      }
    }

    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    final List<Color> avatarColors = [
      const Color(0xFF6638E5),
      const Color(0xFF00B475),
      const Color(0xFF007AFF),
      const Color(0xFFFF9500),
      const Color(0xFFFF2D55),
      const Color(0xFFFF3B30),
      const Color(0xFFAF52DE),
      const Color(0xFF5856D6),
      const Color(0xFF30B0C7),
    ];
    final String avatarName = firstName.trim().isEmpty ? 'User' : firstName;
    final avatarBgColor = avatarColors[(avatarName.hashCode.abs()) % avatarColors.length];
    final isDarkBg = ThemeData.estimateBrightnessForColor(avatarBgColor) == Brightness.dark;
    final avatarTextColor = isDarkBg ? themeExt.onPrimary : themeExt.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar and Greeting Row
        Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                SystemSound.play(SystemSoundType.click);
                context
                    .findAncestorStateOfType<DashboardPageContentState>()
                    ?.changeTab(3);
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: avatarBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: avatarTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: themeExt.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  firstName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: themeExt.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Date Widget on the Right
        Builder(
          builder: (context) {
            final now = DateTime.now();
            final formattedDate = DateFormat('E, d MMM').format(now);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: themeExt.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: themeExt.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 16,
                    color: themeExt.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: themeExt.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ],
    );
  }
}
