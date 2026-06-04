import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/common/util/category_icon_util.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/domain/entities/home_overview_data.dart';
import 'package:spend_sum/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:spend_sum/core/common/widget/transaction/transaction_tile.dart';
import 'package:spend_sum/core/common/widget/layout/skeleton_loader.dart';
import 'package:spend_sum/core/common/widget/layout/fade_in_transition.dart';
import 'package:spend_sum/core/common/widget/button/app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/transaction_cubit.dart';

class HomeContentLayout extends StatelessWidget {
  final HomeOverviewData? data;
  final bool isLoading;
  final AppThemeExtension themeExt;

  const HomeContentLayout({
    super.key,
    required this.data,
    required this.isLoading,
    required this.themeExt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    String currencySymbol = '\$';
    final userState = context.watch<UserCubit>().state;
    if (userState is UserLoggedIn) {
      currencySymbol = getUserCurrencySymbol(userState.user);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // This Month Spend Header Card (full width card with gradient)
        FadeInTransition(
          delay: Duration.zero,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeExt.primary,
                  themeExt.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: themeExt.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // — Large ghost currency symbol watermark —
                Positioned(
                  right: 8,
                  bottom: -28,
                  child: Text(
                    currencySymbol,
                    style: GoogleFonts.outfit(
                      fontSize: 160,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.07),
                      height: 1,
                    ),
                  ),
                ),

                // — Foreground content —
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'This Month Spend',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: themeExt.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        Icon(
                          Icons.trending_up_rounded,
                          color: themeExt.onPrimary.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoading || data == null)
                      const SkeletonLoader(
                        child: SkeletonBox(width: 180, height: 44, borderRadius: 8),
                      )
                    else
                      AnimatedDigitWidget(
                        value: data!.thisMonthSpend,
                        prefix: '$currencySymbol ',
                        fractionDigits: 2,
                        enableSeparator: true,
                        textStyle: theme.textTheme.displayMedium?.copyWith(
                          color: themeExt.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      ),
                    const SizedBox(height: 16),
                    if (isLoading || data == null)
                      const SkeletonLoader(
                        child: SkeletonBox(width: 140, height: 24, borderRadius: 12),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (data!.percentageChange == 0) ...[
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: themeExt.onPrimary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Up to date',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.onPrimary,
                                ),
                              ),
                            ] else ...[
                              Icon(
                                data!.percentageChange < 0
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: data!.percentageChange < 0
                                    ? themeExt.error
                                    : const Color(0xFFFF6B6B),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              AnimatedDigitWidget(
                                value: data!.percentageChange.abs().round(),
                                suffix: '%',
                                textStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: data!.percentageChange < 0
                                      ? themeExt.error
                                      : const Color(0xFFFF6B6B),
                                ),
                                duration: const Duration(milliseconds: 800),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                data!.percentageChange < 0
                                    ? 'less than last month'
                                    : 'more than last month',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: data!.percentageChange < 0
                                      ? themeExt.error
                                      : const Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              ],           // Stack children
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Spending Wallet Card
        FadeInTransition(
          delay: const Duration(milliseconds: 100),
          child: GestureDetector(
            onTap: () {
              if (isLoading || data == null) return;
              HapticFeedback.lightImpact();
              SystemSound.play(SystemSoundType.click);
              context.pushNamed(
                AppRoutes.wallet.name,
                extra: data!.budgetAmount,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.cardPadMd,
                vertical: AppDimensions.cardPadMd,
              ),
              decoration: BoxDecoration(
                color: themeExt.cardColor,
                borderRadius: BorderRadius.circular(AppDimensions.cardPadLg),
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
                      size: AppDimensions.iconLg,
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
                  if (isLoading || data == null)
                    const SkeletonLoader(
                      child: SkeletonBox(width: 70, height: 16, borderRadius: 4),
                    )
                  else
                    AnimatedDigitWidget(
                      value: data!.walletBalance,
                      prefix: '$currencySymbol ',
                      fractionDigits: 2,
                      enableSeparator: false,
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: themeExt.onSurface,
                      ),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                    ),
                  SizedBox(width: AppDimensions.stackSm),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: themeExt.onSurfaceVariant.withValues(alpha: 0.6),
                    size: AppDimensions.iconMd,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Categories Section
        FadeInTransition(
          delay: const Duration(milliseconds: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Categories',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (isLoading || data == null)
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) => const SkeletonLoader(
                      child: Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: SkeletonBox(width: 120, height: 110, borderRadius: 16),
                      ),
                    ),
                  ),
                )
              else
                _buildCategoryList(context, currencySymbol),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Recent Transactions Section Header
        FadeInTransition(
          delay: const Duration(milliseconds: 180),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleLarge,
              ),
              AppButton.ghost(
                onPressed: () {
                  context
                      .findAncestorStateOfType<DashboardPageContentState>()
                      ?.changeTab(1);
                },
                text: 'See All',
                width: null,
                height: null,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.stackMd),

        if (isLoading || data == null)
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonTransactionTile(),
              SizedBox(height: 12),
              SkeletonTransactionTile(),
              SizedBox(height: 12),
              SkeletonTransactionTile(),
              SizedBox(height: 12),
              SkeletonTransactionTile(),
              SizedBox(height: 12),
              SkeletonTransactionTile(),
            ],
          )
        else if (data!.recentTransactions.isEmpty)
          FadeInTransition(
            delay: const Duration(milliseconds: 240),
            child: Center(
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
            ),
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: data!.recentTransactions.asMap().entries.map((entry) {
              final index = entry.key;
              final tx = entry.value;
              return FadeInTransition(
                delay: Duration(milliseconds: 200 + index * 80),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: index < data!.recentTransactions.length - 1 ? 12 : 0,
                  ),
                  child: Dismissible(
                    key: ValueKey(tx.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      decoration: BoxDecoration(
                        color: themeExt.error,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: themeExt.onError,
                        size: AppDimensions.iconLg,
                      ),
                    ),
                    onDismissed: (direction) {
                      context.read<TransactionCubit>().deleteTransaction(tx);
                    },
                    child: TransactionTile(
                      transaction: tx,
                      currencySymbol: currencySymbol,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 100), // padding for FAB offset
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context, String currencySymbol) {
    final now = DateTime.now();
    final thisMonthExpenses = data!.allTransactions.where((e) {
      return !e.isIncome && e.date.year == now.year && e.date.month == now.month;
    }).toList();

    final Map<String, double> categorySums = {};
    for (final e in thisMonthExpenses) {
      final key = e.category.trim();
      categorySums[key] = (categorySums[key] ?? 0.0) + e.amount;
    }

    // Ensure common categories are shown even if 0, for completeness
    final defaultCategories = ['Food', 'Travel', 'Shopping', 'Groceries', 'Bills'];
    for (final cat in defaultCategories) {
      // Check case-insensitive to avoid duplicates
      final exists = categorySums.keys.any((k) => k.toLowerCase() == cat.toLowerCase());
      if (!exists) {
        categorySums[cat] = 0.0;
      }
    }

    final sortedCategories = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final entry = sortedCategories[index];
          final catName = entry.key;
          final catAmount = entry.value;
          final catDetails = getCategoryDetails(catName);

          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeExt.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: catDetails.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    catDetails.icon,
                    color: catDetails.color,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  catName[0].toUpperCase() + catName.substring(1),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: themeExt.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  catAmount > 0
                      ? '$currencySymbol${catAmount.toStringAsFixed(0)}'
                      : '${currencySymbol}0',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: themeExt.onSurface,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
