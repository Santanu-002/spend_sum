import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';
import 'package:spend_sum/core/common/widget/skeleton_loader.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/double_bar_chart.dart';

/// Analytics tab view showing the dynamic budget-to-expense donut chart,
/// top spending categories, and historical income/expense bar charts.
class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  String _selectedPeriod = 'Monthly'; // 'Daily', 'Weekly', 'Monthly', 'Yearly'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    String currencySymbol = '\$';
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoggedIn) {
      currencySymbol = getCurrencySymbol(userState.user.phoneNumber);
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
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeInitial || state is HomeLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginPage,
                  ),
                  child: SkeletonAnalyticsView(),
                );
              } else if (state is HomeError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.inter(color: themeExt.error),
                  ),
                );
              } else if (state is HomeLoaded) {
                final data = state.data;
                final allTx = data.allTransactions;
                final now = DateTime.now();

                // 2. Group transactions dynamically depending on the period selection
                final List<Map<String, dynamic>> chartData = [];

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

                // 3. Calculate Income & Expense totals for the selected period frame shown in the chart
                final double totalIncome = chartData.fold(0.0, (sum, item) => sum + (item['income'] as double));
                final double totalExpense = chartData.fold(0.0, (sum, item) => sum + (item['expense'] as double));

                return Column(
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
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: themeExt.outlineVariant.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    color: themeExt.cardColor,
                                    offset: const Offset(0, 40),
                                    itemBuilder: (BuildContext context) => [
                                      _buildPopupItem(context, 'Daily', 'Daily (Last 7 days)', themeExt),
                                      _buildPopupItem(context, 'Weekly', 'Weekly (Last 4 weeks)', themeExt),
                                      _buildPopupItem(context, 'Monthly', 'Monthly (Last 6 months)', themeExt),
                                      _buildPopupItem(context, 'Yearly', 'Yearly (Last 5 years)', themeExt),
                                    ],
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: themeExt.cardColor,
                                        borderRadius: BorderRadius.circular(20),
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
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: themeExt.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 16,
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
                                    _buildLegendItem(
                                      color: themeExt.primaryContainer,
                                      label: 'Income',
                                      themeExt: themeExt,
                                    ),
                                    const SizedBox(width: 14),
                                    _buildLegendItem(
                                      color: themeExt.secondaryContainer,
                                      label: 'Expense',
                                      themeExt: themeExt,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Double Bar Chart Container with actual values
                            Container(
                              padding: const EdgeInsets.all(16),
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
                              child: DoubleBarChart(
                                monthlyData: chartData,
                                currencySymbol: currencySymbol,
                              ),
                            ),
                             const SizedBox(height: 28),
                             // All-Time totals card
                             Row(
                               children: [
                                 // Income Summary Card
                                 Expanded(
                                   child: Container(
                                     padding: const EdgeInsets.all(14),
                                     decoration: BoxDecoration(
                                       color: themeExt.cardColor,
                                       borderRadius: BorderRadius.circular(20),
                                       boxShadow: [
                                         BoxShadow(
                                           color: Colors.black.withValues(alpha: 0.03),
                                           blurRadius: 8,
                                           offset: const Offset(0, 3),
                                         ),
                                       ],
                                     ),
                                     child: Row(
                                       children: [
                                         Container(
                                           padding: const EdgeInsets.all(8),
                                           decoration: BoxDecoration(
                                             color: themeExt.primaryContainer.withValues(
                                               alpha: 0.1,
                                             ),
                                             borderRadius: BorderRadius.circular(12),
                                           ),
                                           child: Icon(
                                             Icons.savings_outlined,
                                             color: themeExt.primaryContainer,
                                             size: 22,
                                           ),
                                         ),
                                         const SizedBox(width: 10),
                                         Expanded(
                                           child: Column(
                                             crossAxisAlignment:
                                                 CrossAxisAlignment.start,
                                             children: [
                                               Text(
                                                 '$currencySymbol${totalIncome.toStringAsFixed(0)}',
                                                 style: GoogleFonts.outfit(
                                                   fontSize: 16,
                                                   fontWeight: FontWeight.w700,
                                                   color: themeExt.onSurface,
                                                 ),
                                               ),
                                               const SizedBox(height: 2),
                                               Text(
                                                 'Total Income',
                                                 style: GoogleFonts.inter(
                                                   fontSize: 12,
                                                   color: themeExt.onSurfaceVariant,
                                                   fontWeight: FontWeight.w500,
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 // Expense Summary Card
                                 Expanded(
                                   child: Container(
                                     padding: const EdgeInsets.all(14),
                                     decoration: BoxDecoration(
                                       color: themeExt.cardColor,
                                       borderRadius: BorderRadius.circular(20),
                                       boxShadow: [
                                         BoxShadow(
                                           color: Colors.black.withValues(alpha: 0.03),
                                           blurRadius: 8,
                                           offset: const Offset(0, 3),
                                         ),
                                       ],
                                     ),
                                     child: Row(
                                       children: [
                                         Container(
                                           padding: const EdgeInsets.all(8),
                                           decoration: BoxDecoration(
                                             color: themeExt.secondaryContainer.withValues(
                                               alpha: 0.1,
                                             ),
                                             borderRadius: BorderRadius.circular(12),
                                           ),
                                           child: Icon(
                                             Icons.receipt_long_rounded,
                                             color: themeExt.secondary,
                                             size: 22,
                                           ),
                                         ),
                                         const SizedBox(width: 10),
                                         Expanded(
                                           child: Column(
                                             crossAxisAlignment:
                                                 CrossAxisAlignment.start,
                                             children: [
                                               Text(
                                                 '$currencySymbol${totalExpense.toStringAsFixed(0)}',
                                                 style: GoogleFonts.outfit(
                                                   fontSize: 16,
                                                   fontWeight: FontWeight.w700,
                                                   color: themeExt.onSurface,
                                                 ),
                                               ),
                                               const SizedBox(height: 2),
                                               Text(
                                                 'Total Expenses',
                                                 style: GoogleFonts.inter(
                                                   fontSize: 12,
                                                   color: themeExt.onSurfaceVariant,
                                                   fontWeight: FontWeight.w500,
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                             const SizedBox(height: 28),
                             // History Section
                             Text(
                               'History',
                               style: GoogleFonts.inter(
                                 fontSize: 18,
                                 fontWeight: FontWeight.w700,
                                 color: themeExt.onSurface,
                               ),
                             ),
                             const SizedBox(height: 12),
                             if (chartData.isEmpty)
                               Container(
                                 padding: const EdgeInsets.all(20),
                                 decoration: BoxDecoration(
                                   color: themeExt.cardColor,
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                                 child: Center(
                                   child: Text(
                                     'No transaction history available.',
                                     style: GoogleFonts.inter(
                                       fontSize: 13,
                                       color: themeExt.onSurfaceVariant,
                                       fontWeight: FontWeight.w500,
                                     ),
                                   ),
                                 ),
                               )
                             else
                               ...chartData.reversed.map((entry) {
                                 final label = entry['month'] as String;
                                 final incVal = entry['income'] as double;
                                 final expVal = entry['expense'] as double;

                                 return Padding(
                                   padding: const EdgeInsets.only(bottom: 12),
                                   child: Container(
                                     padding: const EdgeInsets.all(16),
                                     decoration: BoxDecoration(
                                       color: themeExt.cardColor,
                                       borderRadius: BorderRadius.circular(20),
                                       boxShadow: [
                                         BoxShadow(
                                           color: Colors.black.withValues(alpha: 0.03),
                                           blurRadius: 8,
                                           offset: const Offset(0, 3),
                                         ),
                                       ],
                                     ),
                                     child: Row(
                                       children: [
                                         Container(
                                           padding: const EdgeInsets.all(10),
                                           decoration: BoxDecoration(
                                             color: themeExt.primary.withValues(alpha: 0.1),
                                             shape: BoxShape.circle,
                                           ),
                                           child: Icon(
                                             Icons.history_rounded,
                                             color: themeExt.primary,
                                             size: 20,
                                           ),
                                         ),
                                         const SizedBox(width: 14),
                                         Expanded(
                                           child: Column(
                                             crossAxisAlignment:
                                                 CrossAxisAlignment.start,
                                             children: [
                                               Text(
                                                 label,
                                                 style: GoogleFonts.inter(
                                                   fontSize: 14,
                                                   fontWeight: FontWeight.w600,
                                                   color: themeExt.onSurface,
                                                 ),
                                               ),
                                               const SizedBox(height: 4),
                                               Text(
                                                 _selectedPeriod == 'Daily'
                                                     ? 'Daily breakdown'
                                                     : _selectedPeriod == 'Weekly'
                                                         ? 'Weekly breakdown'
                                                         : _selectedPeriod == 'Yearly'
                                                             ? 'Yearly breakdown'
                                                             : 'Monthly breakdown',
                                                 style: GoogleFonts.inter(
                                                   fontSize: 11,
                                                   color: themeExt.onSurfaceVariant,
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                         Column(
                                           crossAxisAlignment:
                                               CrossAxisAlignment.end,
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             Text(
                                               '+$currencySymbol${incVal.toStringAsFixed(2)}',
                                               style: GoogleFonts.outfit(
                                                 fontSize: 14,
                                                 fontWeight: FontWeight.w600,
                                                 color: themeExt.primaryContainer,
                                               ),
                                             ),
                                             const SizedBox(height: 2),
                                             Text(
                                               '-$currencySymbol${expVal.toStringAsFixed(2)}',
                                               style: GoogleFonts.outfit(
                                                 fontSize: 14,
                                                 fontWeight: FontWeight.w700,
                                                 color: themeExt.secondaryContainer,
                                               ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     ),
                                   ),
                                 );
                               }),
                             const SizedBox(height: 100), // FAB spacing
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required AppThemeExtension themeExt,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: themeExt.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    BuildContext context,
    String value,
    String label,
    AppThemeExtension themeExt,
  ) {
    final isSelected = _selectedPeriod == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? themeExt.primary : themeExt.onSurface,
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_rounded,
              size: 16,
              color: themeExt.primary,
            ),
        ],
      ),
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
