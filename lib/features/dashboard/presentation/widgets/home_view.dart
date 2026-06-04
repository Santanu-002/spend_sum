import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/domain/entities/home_overview_data.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/pages/wallet_page.dart';
import 'package:spend_sum/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:spend_sum/core/common/widget/transaction_tile.dart';
import 'package:spend_sum/core/common/widget/skeleton_loader.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.marginPage,
              vertical: 12,
            ),
            child: _buildHeaderRow(context, themeExt),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final userState = context.read<UserCubit>().state;
                if (userState is UserLoggedIn) {
                  await context.read<HomeCubit>().loadHomeOverview(userState.user.uid);
                }
              },
              color: themeExt.primary,
              backgroundColor: themeExt.cardColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.marginPage,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        return switch (state) {
                          HomeInitial() || HomeLoading() => _buildLoadingState(themeExt),
                          HomeError(message: final msg) => _buildErrorState(msg, themeExt, context),
                          HomeLoaded(data: final data) => _buildContentState(data, themeExt, context),
                        };
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, AppThemeExtension themeExt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCircleIconButton(
          icon: Icons.settings_outlined,
          themeExt: themeExt,
          onPressed: () {},
        ),
        Builder(
          builder: (context) {
            final now = DateTime.now();
            final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            final formattedDate = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

            return Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: themeExt.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeExt.onSurface,
                  ),
                ),
              ],
            );
          }
        ),
        _buildCircleIconButton(
          icon: Icons.notifications_none_outlined,
          themeExt: themeExt,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildLoadingState(AppThemeExtension themeExt) {
    return const SkeletonHomeView();
  }

  Widget _buildErrorState(String message, AppThemeExtension themeExt, BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: themeExt.error, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard data',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeExt.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: themeExt.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final userState = context.read<UserCubit>().state;
              if (userState is UserLoggedIn) {
                context.read<HomeCubit>().loadHomeOverview(userState.user.uid);
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentState(HomeOverviewData data, AppThemeExtension themeExt, BuildContext context) {
    String currencySymbol = '\$';
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoggedIn) {
      currencySymbol = getCurrencySymbol(userState.user.phoneNumber);
    }

    return HomeContentSection(
      data: data,
      themeExt: themeExt,
      currencySymbol: currencySymbol,
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required AppThemeExtension themeExt,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: themeExt.onSurface),
        onPressed: onPressed,
      ),
    );
  }
}

class HomeContentSection extends StatelessWidget {
  final HomeOverviewData data;
  final AppThemeExtension themeExt;
  final String currencySymbol;

  const HomeContentSection({
    super.key,
    required this.data,
    required this.themeExt,
    required this.currencySymbol,
  });





  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // This Month Spend Header & Amount
        Center(
          child: Column(
            children: [
              Text(
                'This Month Spend',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeExt.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDigitWidget(
                value: data.thisMonthSpend,
                prefix: '$currencySymbol ',
                fractionDigits: 2,
                enableSeparator: false,
                textStyle: GoogleFonts.outfit(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: themeExt.onSurface,
                  letterSpacing: -1.0,
                ),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
              ),
              const SizedBox(height: 8),
              // Trend info
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_down_rounded,
                    color: themeExt.secondary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'All figures are up to date',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: themeExt.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Spending Wallet Card
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            SystemSound.play(SystemSoundType.click);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletPage(initialBudget: data.budgetAmount),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: themeExt.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeExt.primaryContainer.withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: themeExt.primaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Spending Wallet',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: themeExt.onSurface,
                  ),
                ),
                const Spacer(),
                AnimatedDigitWidget(
                  value: data.walletBalance,
                  prefix: '$currencySymbol ',
                  fractionDigits: 2,
                  enableSeparator: false,
                  textStyle: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: themeExt.onSurface,
                    letterSpacing: -0.3,
                  ),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: themeExt.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Recent Transactions Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: themeExt.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                SystemSound.play(SystemSoundType.click);
                context
                    .findAncestorStateOfType<DashboardPageContentState>()
                    ?.changeTab(1);
              },
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeExt.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (data.recentTransactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: themeExt.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No transactions recorded yet.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: themeExt.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...data.recentTransactions.map((tx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TransactionTile(
                transaction: tx,
                currencySymbol: currencySymbol,
              ),
            );
          }),
        const SizedBox(height: 100), // padding for FAB offset
      ],
    );
  }
}
