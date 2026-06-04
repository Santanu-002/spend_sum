import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/widget/app_scaffold.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/account_view.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/analytics_view.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/home_view.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/transactions_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (context) => sl<HomeCubit>(),
      child: const DashboardPageContent(),
    );
  }
}

class DashboardPageContent extends StatefulWidget {
  const DashboardPageContent({super.key});

  @override
  State<DashboardPageContent> createState() => DashboardPageContentState();
}

class DashboardPageContentState extends State<DashboardPageContent> {
  int _currentIndex = 0;
  DateTime? _lastPressedAt;

  void changeTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    // Trigger loading of home overview so it does a hard refresh with skeleton loaders
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoggedIn) {
      context.read<HomeCubit>().loadHomeOverview(userState.user.uid);
    }
  }

  final List<Widget> _views = const [
    HomeView(),
    TransactionsView(),
    AnalyticsView(),
    AccountView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<UserCubit>().state;
      if (userState is UserLoggedIn) {
        context.read<HomeCubit>().loadHomeOverview(userState.user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Press back again to exit',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusDefault,
                ),
              ),
              backgroundColor: themeExt.secondaryContainer,
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoggedIn) {
            context.read<HomeCubit>().loadHomeOverview(state.user.uid);
          }
        },
        child: AppScaffold(
          showAppBar: false,
          extendBody: true, // Allows content to flow behind notched BottomAppBar
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            color: themeExt.cardColor,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            padding: EdgeInsets.zero,
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Left Group: Home & Transaction
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.home_filled,
                        unselectedIcon: Icons.home_outlined,
                        label: 'Home',
                        themeExt: themeExt,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.assignment_rounded,
                        unselectedIcon: Icons.assignment_outlined,
                        label: 'Transactions',
                        themeExt: themeExt,
                      ),
                    ],
                  ),
                ),
                // Middle empty space for FAB Notch
                const SizedBox(width: 60),
                // Right Group: Analytics & Account
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        index: 2,
                        icon: Icons.insert_chart_rounded,
                        unselectedIcon: Icons.insert_chart_outlined_rounded,
                        label: 'Analytics',
                        themeExt: themeExt,
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.person_rounded,
                        unselectedIcon: Icons.person_outline_rounded,
                        label: 'Account',
                        themeExt: themeExt,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E1243).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                SystemSound.play(SystemSoundType.click);
                context.pushNamed(AppRoutes.addTransaction.name);
              },
              backgroundColor: const Color(
                0xFF1E1243,
              ), // High contrast indigo FAB
              elevation: 0,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          child: IndexedStack(index: _currentIndex, children: _views),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData unselectedIcon,
    required String label,
    required AppThemeExtension themeExt,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? themeExt.primary
        : themeExt.onSurfaceVariant.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
        changeTab(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? icon : unselectedIcon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
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
