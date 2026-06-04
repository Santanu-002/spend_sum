import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/theme/theme_cubit.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.marginPage,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Title
                Center(
                  child: Text(
                    'Profile',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: themeExt.onSurface,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Avatar and User details
                Center(
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
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: themeExt.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayPhone,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: themeExt.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Profile options block
                Container(
                  decoration: BoxDecoration(
                    color: themeExt.cardColor,
                    borderRadius: BorderRadius.circular(24),
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
                      _buildOptionTile(
                        icon: Icons.brightness_6_outlined,
                        title: 'Theme Mode',
                        trailing: Switch.adaptive(
                          value: theme.brightness == Brightness.dark,
                          activeTrackColor: themeExt.primary,
                          onChanged: (value) {
                            context.read<ThemeCubit>().toggleTheme(
                              theme.brightness,
                            );
                          },
                        ),
                        themeExt: themeExt,
                      ),
                      _buildDivider(themeExt),
                      _buildOptionTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Account Settings',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: themeExt.onSurfaceVariant,
                        ),
                        themeExt: themeExt,
                      ),
                      _buildDivider(themeExt),
                      _buildOptionTile(
                        icon: Icons.notifications_none_outlined,
                        title: 'Notifications',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: themeExt.onSurfaceVariant,
                        ),
                        themeExt: themeExt,
                      ),
                      _buildDivider(themeExt),
                      _buildOptionTile(
                        icon: Icons.shield_outlined,
                        title: 'Security',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: themeExt.onSurfaceVariant,
                        ),
                        themeExt: themeExt,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                GestureDetector(
                  onTap: () async {
                    await context.read<UserCubit>().logout();
                    if (context.mounted) {
                      context.go(AppRoutes.auth.login.path);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: themeExt.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: themeExt.error,
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

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    required AppThemeExtension themeExt,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: themeExt.onSurfaceVariant, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: themeExt.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildDivider(AppThemeExtension themeExt) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: themeExt.outlineVariant.withValues(alpha: 0.2),
    );
  }
}
