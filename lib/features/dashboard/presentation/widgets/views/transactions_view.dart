import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/common/util/category_icon_util.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/widget/transaction/transaction_tile.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/transaction_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/charts/transactions_donut_chart.dart';
import 'package:spend_sum/core/common/widget/layout/skeleton_loader.dart';
import 'package:spend_sum/core/common/widget/layout/fade_in_transition.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/components/transaction_filter_chips.dart';
part 'transactions_view_components.dart';

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
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All'; // 'All', 'Expense', 'Income'
  String _searchQuery = '';
  int _displayLimit = 15;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _displayLimit = 15;
      });
    });
    _searchFocusNode.addListener(_onSearchFocusChange);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() {
      _displayLimit += 15;
    });
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      _scrollToSearchBar();
    }
  }

  void _scrollToSearchBar() {
    if (mounted && _searchBarKey.currentContext != null) {
      Scrollable.ensureVisible(
        _searchBarKey.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onFilterSelected(String filter) {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _selectedFilter = filter;
      _displayLimit = 15;
    });
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
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.marginPage,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _TransactionsDonutChartSection(currencySymbol: currencySymbol),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 28)),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.marginPage,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _TransactionsTopSpendingSection(currencySymbol: currencySymbol),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.marginPage,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: FadeInTransition(
                            delay: const Duration(milliseconds: 180),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'All Transactions',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppDimensions.stackMd),
                                TextFormField(
                                  key: _searchBarKey,
                                  focusNode: _searchFocusNode,
                                  controller: _searchController,
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
                                              size: AppDimensions.iconMd,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                            },
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: themeExt.surfaceContainer,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.cardPadMd,
                                      vertical: AppDimensions.tileVerticalPad,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                      borderSide: BorderSide(color: themeExt.primary, width: 1.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.stackSm),
                                TransactionFilterChips(
                                  selectedFilter: _selectedFilter,
                                  onFilterSelected: _onFilterSelected,
                                ),
                                const SizedBox(height: AppDimensions.stackMd),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.marginPage,
                        ),
                        sliver: _TransactionsSliverListSection(
                          selectedFilter: _selectedFilter,
                          searchQuery: _searchQuery,
                          currencySymbol: currencySymbol,
                          displayLimit: _displayLimit,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

