import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/widget/layout/fade_in_transition.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';
import 'package:spend_sum/core/common/widget/layout/skeleton_loader.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/charts/double_bar_chart.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/components/legend_item.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/components/analytics_stat_card.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/components/analytics_history_tile.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/components/period_menu_item_content.dart';

/// Analytics tab view showing the dynamic budget-to-expense donut chart,
/// top spending categories, and historical income/expense bar charts.
class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  String _selectedPeriod = 'Monthly'; // 'Daily', 'Weekly', 'Monthly', 'Yearly'

  List<Map<String, dynamic>> _calculateChartData(List<Expense> allTx) {
    final List<Map<String, dynamic>> chartData = [];
    final now = DateTime.now();

    if (_selectedPeriod == 'Daily') {
      final weekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 6; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final weekdayLabel = weekdaysShort[targetDate.weekday - 1];
        final label = '$weekdayLabel ${targetDate.day}';

        final double incSum = allTx
            .where((tx) =>
                tx.isIncome &&
                tx.date.year == targetDate.year &&
                tx.date.month == targetDate.month &&
                tx.date.day == targetDate.day)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        final double expSum = allTx
            .where((tx) =>
                !tx.isIncome &&
                tx.date.year == targetDate.year &&
                tx.date.month == targetDate.month &&
                tx.date.day == targetDate.day)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        chartData.add({
          'month': label,
          'income': incSum,
          'expense': expSum,
        });
      }
    } else if (_selectedPeriod == 'Weekly') {
      for (int i = 3; i >= 0; i--) {
        final weekEnd = now.subtract(Duration(days: i * 7));
        final weekStart = weekEnd.subtract(const Duration(days: 6));
        
        final monthsShort = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final startMonth = monthsShort[weekStart.month - 1];
        final endMonth = monthsShort[weekEnd.month - 1];
        
        String label;
        if (startMonth == endMonth) {
          label = '$startMonth ${weekStart.day}-${weekEnd.day}';
        } else {
          label = '$startMonth ${weekStart.day}-$endMonth ${weekEnd.day}';
        }

        final startOfDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
        final endOfDay = DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);

        final double incSum = allTx
            .where((tx) =>
                tx.isIncome &&
                tx.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                tx.date.isBefore(endOfDay.add(const Duration(seconds: 1))))
            .fold(0.0, (sum, tx) => sum + tx.amount);

        final double expSum = allTx
            .where((tx) =>
                !tx.isIncome &&
                tx.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                tx.date.isBefore(endOfDay.add(const Duration(seconds: 1))))
            .fold(0.0, (sum, tx) => sum + tx.amount);

        chartData.add({
          'month': label,
          'income': incSum,
          'expense': expSum,
        });
      }
    } else if (_selectedPeriod == 'Yearly') {
      for (int i = 4; i >= 0; i--) {
        final targetYear = now.year - i;
        final label = '$targetYear';

        final double incSum = allTx
            .where((tx) =>
                tx.isIncome &&
                tx.date.year == targetYear)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        final double expSum = allTx
            .where((tx) =>
                !tx.isIncome &&
                tx.date.year == targetYear)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        chartData.add({
          'month': label,
          'income': incSum,
          'expense': expSum,
        });
      }
    } else {
      // Monthly (default)
      final monthsShort = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];

      for (int i = 5; i >= 0; i--) {
        final targetDate = DateTime(now.year, now.month - i, 1);
        final monthLabel = monthsShort[targetDate.month - 1];

        final double incSum = allTx
            .where((tx) =>
                tx.isIncome &&
                tx.date.year == targetDate.year &&
                tx.date.month == targetDate.month)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        final double expSum = allTx
            .where((tx) =>
                !tx.isIncome &&
                tx.date.year == targetDate.year &&
                tx.date.month == targetDate.month)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        chartData.add({
          'month': monthLabel,
          'income': incSum,
          'expense': expSum,
        });
      }
    }

    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    String currencySymbol = '\$';
    final userState = context.watch<UserCubit>().state;
    if (userState is UserLoggedIn) {
      currencySymbol = getUserCurrencySymbol(userState.user);
    }

    return Stack(
      children: [
        // Premium gradient fade background
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 200,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Analytics',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: themeExt.onSurface,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
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
                        // Chart Period Filter Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Theme(
                              data: theme.copyWith(
                                cardColor: themeExt.cardColor,
                              ),
                              child: PopupMenuButton<String>(
                                initialValue: _selectedPeriod,
                                onSelected: (String value) {
                                  setState(() {
                                    _selectedPeriod = value;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
                                  side: BorderSide(
                                    color: themeExt.outlineVariant.withValues(alpha: 0.2),
                                  ),
                                ),
                                color: themeExt.cardColor,
                                offset: const Offset(0, 40),
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'Daily',
                                    child: PeriodMenuItemContent(
                                      label: 'Daily (Last 7 days)',
                                      isSelected: _selectedPeriod == 'Daily',
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'Weekly',
                                    child: PeriodMenuItemContent(
                                      label: 'Weekly (Last 4 weeks)',
                                      isSelected: _selectedPeriod == 'Weekly',
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'Monthly',
                                    child: PeriodMenuItemContent(
                                      label: 'Monthly (Last 6 months)',
                                      isSelected: _selectedPeriod == 'Monthly',
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'Yearly',
                                    child: PeriodMenuItemContent(
                                      label: 'Yearly (Last 5 years)',
                                      isSelected: _selectedPeriod == 'Yearly',
                                    ),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: themeExt.cardColor,
                                    borderRadius: BorderRadius.circular(AppDimensions.cardPadLg),
                                    border: Border.all(
                                      color: themeExt.outlineVariant.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getPeriodLabel(_selectedPeriod),
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: themeExt.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: AppDimensions.iconSm,
                                        color: themeExt.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Legend
                            Row(
                              children: [
                                LegendItem(
                                  color: themeExt.secondaryContainer,
                                  label: 'Income',
                                ),
                                SizedBox(width: AppDimensions.stackMd),
                                LegendItem(
                                  color: themeExt.primaryContainer,
                                  label: 'Expense',
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.stackMd),

                        // Component 1: Double Bar Chart Card (Statically drawn container)
                        FadeInTransition(
                          delay: const Duration(milliseconds: 100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.cardPadLg, vertical: AppDimensions.cardPadMd),
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
                            child: BlocBuilder<HomeCubit, HomeState>(
                              builder: (context, state) {
                                if (state is HomeInitial || state is HomeLoading) {
                                  return const SkeletonLoader(
                                    child: SkeletonBox(height: 180, borderRadius: 12),
                                  );
                                } else if (state is HomeError) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 32),
                                      child: Text(
                                        state.message,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: themeExt.error,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (state is HomeLoaded) {
                                  final chartData = _calculateChartData(state.data.allTransactions);
                                  return DoubleBarChart(
                                    monthlyData: chartData,
                                    currencySymbol: currencySymbol,
                                  );
                                }
                                return const SizedBox(height: 180);
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: AppDimensions.stackMd + 12),

                        // Component 2: Totals summary cards (Dependent on data!)
                        FadeInTransition(
                          delay: const Duration(milliseconds: 150),
                          child: BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              final isLoading = state is HomeInitial || state is HomeLoading;
                              double totalIncome = 0.0;
                              double totalExpense = 0.0;

                              if (state is HomeLoaded) {
                                final chartData = _calculateChartData(state.data.allTransactions);
                                totalIncome = chartData.fold(0.0, (sum, item) => sum + (item['income'] as double));
                                totalExpense = chartData.fold(0.0, (sum, item) => sum + (item['expense'] as double));
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: AnalyticsStatCard(
                                      title: 'Total Income',
                                      amount: totalIncome,
                                      currencySymbol: currencySymbol,
                                      icon: Icons.savings_outlined,
                                      iconColor: themeExt.secondary,
                                      iconBgColor: themeExt.secondaryContainer.withValues(alpha: 0.1),
                                      isLoading: isLoading,
                                    ),
                                  ),
                                  SizedBox(width: AppDimensions.tileHorizontalPad - 2),
                                  Expanded(
                                    child: AnalyticsStatCard(
                                      title: 'Total Expenses',
                                      amount: totalExpense,
                                      currencySymbol: currencySymbol,
                                      icon: Icons.receipt_long_rounded,
                                      iconColor: themeExt.primary,
                                      iconBgColor: themeExt.primaryContainer.withValues(alpha: 0.1),
                                      isLoading: isLoading,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: AppDimensions.stackMd + 12),

                        // History Section Title (Statically drawn immediately)
                        Text(
                          'History',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),

                        // Component 3: History List (Dependent on data!)
                        BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) {
                            if (state is HomeInitial || state is HomeLoading) {
                              return const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SkeletonHistoryTile(),
                                  SizedBox(height: 12),
                                  SkeletonHistoryTile(),
                                  SizedBox(height: 12),
                                  SkeletonHistoryTile(),
                                  SizedBox(height: 12),
                                  SkeletonHistoryTile(),
                                  SizedBox(height: 12),
                                  SkeletonHistoryTile(),
                                  SizedBox(height: 12),
                                ],
                              );
                            } else if (state is HomeLoaded) {
                              final chartData = _calculateChartData(state.data.allTransactions);
                              if (chartData.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(AppDimensions.cardPadLg),
                                  decoration: BoxDecoration(
                                    color: themeExt.cardColor,
                                    borderRadius: BorderRadius.circular(AppDimensions.cardPadLg),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No transaction history available.',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: themeExt.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: chartData.reversed.toList().asMap().entries.map((item) {
                                  final index = item.key;
                                  final entry = item.value;
                                  final label = entry['month'] as String;
                                  final incVal = entry['income'] as double;
                                  final expVal = entry['expense'] as double;

                                  return FadeInTransition(
                                    delay: Duration(milliseconds: (index % 10) * 40),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: AnalyticsHistoryTile(
                                        label: label,
                                        sublabel: _selectedPeriod == 'Daily'
                                            ? 'Daily breakdown'
                                            : _selectedPeriod == 'Weekly'
                                                ? 'Weekly breakdown'
                                                : _selectedPeriod == 'Yearly'
                                                    ? 'Yearly breakdown'
                                                    : 'Monthly breakdown',
                                        incomeAmount: incVal,
                                        expenseAmount: expVal,
                                        currencySymbol: currencySymbol,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 100), // FAB spacing
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  String _getPeriodLabel(String period) {
    switch (period) {
      case 'Daily':
        return 'Daily (Last 7 days)';
      case 'Weekly':
        return 'Weekly (Last 4 weeks)';
      case 'Yearly':
        return 'Yearly (Last 5 years)';
      case 'Monthly':
      default:
        return 'Monthly (Last 6 months)';
    }
  }
}

