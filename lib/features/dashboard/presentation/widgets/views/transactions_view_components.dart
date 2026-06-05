part of 'transactions_view.dart';

class _TransactionsDonutChartSection extends StatelessWidget {
  final String currencySymbol;

  const _TransactionsDonutChartSection({
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial || state is HomeLoading) {
          return const SkeletonLoader(
            child: Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SkeletonRing(width: 220, height: 220),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonBox(width: 80, height: 12, borderRadius: 4),
                        SizedBox(height: 8),
                        SkeletonBox(width: 100, height: 24, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is HomeError) {
          return const SizedBox.shrink();
        } else if (state is HomeLoaded) {
          final data = state.data;
          final monthsFull = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
          ];
          final now = DateTime.now();
          return FadeInTransition(
            delay: Duration.zero,
            child: TransactionsDonutChart(
              expenseAmount: data.thisMonthSpend,
              budgetAmount: data.budgetAmount,
              monthLabel: monthsFull[now.month - 1],
              currencySymbol: currencySymbol,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TransactionsTopSpendingSection extends StatelessWidget {
  final String currencySymbol;

  const _TransactionsTopSpendingSection({
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeInTransition(
          delay: const Duration(milliseconds: 100),
          child: Text(
            'Top Spending',
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final isLoading = state is HomeInitial || state is HomeLoading;
            final data = state is HomeLoaded ? state.data : null;

            // Group current month's expenses by category to find the top spending category dynamically
            String topCategory = 'Other';
            double topAmount = 0.0;
            bool hasExpenses = false;
            if (data != null) {
              final allTx = data.allTransactions;
              final now = DateTime.now();
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

              hasExpenses = sortedCategories.isNotEmpty;
              topCategory = hasExpenses ? sortedCategories.first.key : 'Other';
              topAmount = hasExpenses ? sortedCategories.first.value : 0.0;
            }

            final catDetails = getCategoryDetails(topCategory);

            return FadeInTransition(
              delay: const Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.cardPadMd),
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  borderRadius: BorderRadius.circular(AppDimensions.cardPadLg),
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
                    if (isLoading)
                      const SkeletonLoader(
                        child: SkeletonBox(width: 42, height: 42, shape: BoxShape.circle),
                      )
                    else
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
                          size: AppDimensions.iconLg,
                        ),
                      ),
                    SizedBox(width: AppDimensions.tileHorizontalPad),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isLoading)
                            const SkeletonLoader(
                              child: SkeletonBox(width: 100, height: 16, borderRadius: 4),
                            )
                          else
                            Text(
                              topCategory,
                              style: TextStyle(fontFamily: 'Inter', 
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: themeExt.onSurface,
                              ),
                            ),
                          const SizedBox(height: 4),
                          if (isLoading)
                            const SkeletonLoader(
                              child: SkeletonBox(width: 150, height: 12, borderRadius: 4),
                            )
                          else
                            Text(
                              hasExpenses
                                  ? 'Highest spend category this month'
                                  : 'No expenses this month',
                              style: TextStyle(fontFamily: 'Inter', 
                                fontSize: 12,
                                color: themeExt.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      const SkeletonLoader(
                        child: SkeletonBox(width: 60, height: 16, borderRadius: 4),
                      )
                    else
                      Text(
                        '$currencySymbol${topAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontFamily: 'Outfit', 
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: themeExt.onSurface,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TransactionsSliverListSection extends StatefulWidget {
  final String selectedFilter;
  final String searchQuery;
  final String currencySymbol;
  final ScrollController scrollController;

  const _TransactionsSliverListSection({
    required this.selectedFilter,
    required this.searchQuery,
    required this.currencySymbol,
    required this.scrollController,
  });

  @override
  State<_TransactionsSliverListSection> createState() =>
      _TransactionsSliverListSectionState();
}

class _TransactionsSliverListSectionState
    extends State<_TransactionsSliverListSection> {
  int _displayLimit = 15;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _TransactionsSliverListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery ||
        widget.selectedFilter != oldWidget.selectedFilter) {
      setState(() {
        _displayLimit = 15;
      });
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() {
      _displayLimit += 15;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial || state is HomeLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SkeletonTransactionTile(),
                );
              },
              childCount: 5,
            ),
          );
        } else if (state is HomeError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  state.message,
                  style: TextStyle(fontFamily: 'Inter', color: themeExt.error),
                ),
              ),
            ),
          );
        } else if (state is HomeLoaded) {
          final data = state.data;
          final allTx = data.allTransactions;

          // Filter transactions for the search and type filter
          final filteredTx = allTx.where((tx) {
            final matchesQuery =
                tx.title.toLowerCase().contains(widget.searchQuery);

            bool matchesType = true;
            if (widget.selectedFilter == 'Expense') {
              matchesType = !tx.isIncome;
            } else if (widget.selectedFilter == 'Income') {
              matchesType = tx.isIncome;
            }

            return matchesQuery && matchesType;
          }).toList();

          if (filteredTx.isEmpty) {
            return SliverToBoxAdapter(
              child: FadeInTransition(
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
                          'No transactions found.',
                          style: TextStyle(fontFamily: 'Inter', 
                            fontSize: 14,
                            color: themeExt.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            final displayedTx = filteredTx.take(_displayLimit).toList();
            final hasMore = filteredTx.length > _displayLimit;

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < displayedTx.length) {
                    final tx = displayedTx[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                          currencySymbol: widget.currencySymbol,
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: themeExt.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                },
                childCount: displayedTx.length + (hasMore ? 1 : 0),
              ),
            );
          }
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
