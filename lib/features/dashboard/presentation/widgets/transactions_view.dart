import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/common/util/category_icon_util.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/widget/transaction_tile.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/transactions_donut_chart.dart';
import 'package:spend_sum/core/common/widget/skeleton_loader.dart';

/// Transactions tab view showing the animated donut chart, top spending category,
/// and a searchable/filterable list of all transactions.
class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchBarKey = GlobalKey();
  String _selectedFilter = 'All'; // 'All', 'Expense', 'Income'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      _scrollToSearchBar();
    }
  }

  void _scrollToSearchBar() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _searchBarKey.currentContext != null) {
        Scrollable.ensureVisible(
          _searchBarKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFilterSelected(String filter) {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _selectedFilter = filter;
    });
  }

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
                  child: SkeletonTransactionsView(),
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

                // Group current month's expenses by category to find the top spending category dynamically
                final Map<String, double> categorySums = {};
                for (final tx in allTx) {
                  if (!tx.isIncome &&
                      tx.date.year == now.year &&
                      tx.date.month == now.month) {
                    categorySums[tx.category] =
                        (categorySums[tx.category] ?? 0.0) + tx.amount;
                  }
                }
                final sortedCategories = categorySums.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                // Filter transactions for the search and type filter
                final filteredTx = allTx.where((tx) {
                  final matchesQuery =
                      tx.title.toLowerCase().contains(_searchQuery);

                  bool matchesType = true;
                  if (_selectedFilter == 'Expense') {
                    matchesType = !tx.isIncome;
                  } else if (_selectedFilter == 'Income') {
                    matchesType = tx.isIncome;
                  }

                  return matchesQuery && matchesType;
                }).toList();

                final monthsFull = [
                  'January', 'February', 'March', 'April', 'May', 'June',
                  'July', 'August', 'September', 'October', 'November', 'December'
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Transactions',
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
                            // Donut Chart Card
                            TransactionsDonutChart(
                              expenseAmount: data.thisMonthSpend,
                              budgetAmount: data.budgetAmount,
                              monthLabel: monthsFull[now.month - 1],
                              currencySymbol: currencySymbol,
                            ),
                            const SizedBox(height: 28),
                            // Top Spending Section
                            Text(
                              'Top Spending',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: themeExt.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Top Spending Card (Dynamic highest category)
                            Builder(
                              builder: (context) {
                                final hasExpenses = sortedCategories.isNotEmpty;
                                final topCategory = hasExpenses ? sortedCategories.first.key : 'Other';
                                final topAmount = hasExpenses ? sortedCategories.first.value : 0.0;
                                final catDetails = getCategoryDetails(topCategory);

                                return Container(
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
                                          color: catDetails.color.withValues(
                                            alpha: 0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          catDetails.icon,
                                          color: catDetails.color,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              topCategory,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: themeExt.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              hasExpenses
                                                  ? 'Highest spend category this month'
                                                  : 'No expenses this month',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: themeExt.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '$currencySymbol${topAmount.toStringAsFixed(2)}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: themeExt.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            ),
                            const SizedBox(height: 32),
                            // Transactions List Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Text(
                                    'All Transactions',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: themeExt.onSurface,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Search bar
                            TextFormField(
                              key: _searchBarKey,
                              focusNode: _searchFocusNode,
                              onTap: _scrollToSearchBar,
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.trim().toLowerCase();
                                });
                              },
                              style: GoogleFonts.inter(color: themeExt.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Search by title...',
                                hintStyle: TextStyle(
                                  color: themeExt.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: themeExt.onSurfaceVariant,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear_rounded,
                                          color: themeExt.onSurfaceVariant,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: themeExt.surfaceContainer,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: themeExt.primary, width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Quick filters Choice chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: ['All', 'Expense', 'Income'].map((filter) {
                                  final isSelected = _selectedFilter == filter;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      label: Text(filter),
                                      selected: isSelected,
                                      checkmarkColor: Colors.white,
                                      onSelected: (selected) {
                                        if (selected) {
                                          _onFilterSelected(filter);
                                        }
                                      },
                                      labelStyle: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.white : themeExt.onSurface,
                                      ),
                                      selectedColor: themeExt.primary,
                                      backgroundColor: themeExt.cardColor,
                                      shadowColor: Colors.black.withValues(alpha: 0.02),
                                      elevation: isSelected ? 3 : 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.transparent
                                              : themeExt.outlineVariant.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Transaction list items
                            if (filteredTx.isEmpty)
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
                                        'No transactions found.',
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
                              Column(
                                children: filteredTx.map((tx) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: TransactionTile(
                                      transaction: tx,
                                      currencySymbol: currencySymbol,
                                    ),
                                  );
                                }).toList(),
                              ),
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
}
