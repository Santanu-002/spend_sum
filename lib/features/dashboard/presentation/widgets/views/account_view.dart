import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/widget/button/app_button.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/theme/theme_cubit.dart';
import 'package:spend_sum/core/common/widget/layout/fade_in_transition.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/account/account_option_tile.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/account/account_divider.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;
    final userState = context.watch<UserCubit>().state;

    // Resolve name/phone or use placeholder hardcoded ui data
    String displayName = 'Santanu Dev';
    String displayPhone = '+91 9876543210';

    if (userState is UserLoggedIn) {
      displayName = userState.user.name ?? 'Guest User';
      displayPhone = userState.user.phoneNumber;
    }

    return Stack(
      children: [
        // Premium gradient fade background
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 220,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeExt.backgroundGradientStart.withValues(alpha: 0.3),
                  themeExt.backgroundGradientStart.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.marginPage,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header custom App Bar Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: themeExt.onSurface,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        SystemSound.play(SystemSoundType.click);
                        context.pushNamed(AppRoutes.editProfile.name);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Edit',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: themeExt.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar and User details
                FadeInTransition(
                  delay: const Duration(milliseconds: 50),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: themeExt.primaryContainer.withValues(
                              alpha: 0.2,
                            ),
                            border: Border.all(
                              color: themeExt.primaryContainer.withValues(
                                alpha: 0.3,
                              ),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 44,
                              color: themeExt.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: AppDimensions.stackMd),
                        Text(
                          displayName,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: themeExt.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayPhone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: themeExt.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Profile options block
                FadeInTransition(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeExt.cardColor,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.brightness_6_outlined,
                                    color: themeExt.onSurfaceVariant,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Theme Mode',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: themeExt.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              _buildThemeToggle(context),
                            ],
                          ),
                        ),
                        const AccountDivider(),
                        AccountOptionTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Account Settings',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: themeExt.onSurfaceVariant,
                          ),
                          onTap: () {
                            context.pushNamed(AppRoutes.profileSettings.name);
                          },
                        ),
                        const AccountDivider(),
                        AccountOptionTile(
                          icon: Icons.info_outline_rounded,
                          title: 'About / Help',
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: themeExt.onSurfaceVariant,
                          ),
                          onTap: () {
                            _showAboutHelpBottomSheet(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.stackLg),

                // Logout Button
                FadeInTransition(
                  delay: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onTap: () async {
                      await context.read<UserCubit>().logout();
                      if (context.mounted) {
                        context.go(AppRoutes.auth.login.path);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.cardPadMd),
                      decoration: BoxDecoration(
                        color: themeExt.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
                      ),
                      child: Center(
                        child: Text(
                          'Logout',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: themeExt.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100), // FAB Spacing
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;
    final activeMode = context.watch<ThemeCubit>().state;

    Widget buildToggleItem({
      required ThemeMode mode,
      required IconData icon,
      required String tooltip,
    }) {
      final isActive = activeMode == mode;
      return Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            SystemSound.play(SystemSoundType.click);
            context.read<ThemeCubit>().setThemeMode(mode);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? themeExt.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? themeExt.onPrimary : themeExt.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: themeExt.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildToggleItem(
            mode: ThemeMode.light,
            icon: Icons.wb_sunny_rounded,
            tooltip: 'Light Mode',
          ),
          const SizedBox(width: 4),
          buildToggleItem(
            mode: ThemeMode.system,
            icon: Icons.desktop_windows_rounded,
            tooltip: 'System Default',
          ),
          const SizedBox(width: 4),
          buildToggleItem(
            mode: ThemeMode.dark,
            icon: Icons.nightlight_round,
            tooltip: 'Dark Mode',
          ),
        ],
      ),
    );
  }

  void _showAboutHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = context.theme;
        final themeExt = theme.colorscheme;
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusMd),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.marginPage,
            vertical: AppDimensions.marginPage,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: themeExt.outlineVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'About SpendSum',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeExt.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'SpendSum is a premium personal finance tracking application. It helps you manage your daily expenses, monitor your budget, and analyze your financial behavior with simple, beautiful visualizations.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: themeExt.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Divider(color: themeExt.outlineVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'App Version',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: themeExt.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeExt.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Developer',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: themeExt.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Santanu Dev',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeExt.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton.filled(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
