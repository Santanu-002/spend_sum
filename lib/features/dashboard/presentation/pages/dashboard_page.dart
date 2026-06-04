import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/widget/layout/app_scaffold.dart';
import 'package:spend_sum/core/common/widget/feedback/app_snackbar.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/views/account_view.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/views/analytics_view.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/views/home_view.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/views/transactions_view.dart';

import 'package:spend_sum/core/theme/app_colors.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:spend_sum/features/dashboard/presentation/cubit/transaction_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => sl<HomeCubit>(),
        ),
        BlocProvider<TransactionCubit>(
          create: (context) => sl<TransactionCubit>(),
        ),
      ],
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
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbar.neutral(
              message: 'Press back again to exit',
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        SystemNavigator.pop();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<UserCubit, UserState>(
            listener: (context, state) {
              if (state is UserLoggedIn) {
                context.read<HomeCubit>().loadHomeOverview(state.user.uid);
              }
            },
          ),
          BlocListener<TransactionCubit, TransactionState>(
            listener: (context, state) {
              if (state is TransactionDeleteSuccess) {
                final tx = state.transaction;
                final userState = context.read<UserCubit>().state;
                final uid = userState is UserLoggedIn ? userState.user.uid : (tx.userUid ?? '');
                final messenger = ScaffoldMessenger.of(context);
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  AppSnackbar.neutral(
                    message: 'Transaction deleted',
                    duration: const Duration(seconds: 5),
                    trailingAction: InkWell(
                      onTap: () {
                        messenger.hideCurrentSnackBar();
                        context.read<TransactionCubit>().restoreTransaction(userUid: uid, tx: tx);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          'UNDO',
                          style: GoogleFonts.inter(
                            color: themeExt.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else if (state is TransactionFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  AppSnackbar.destructive(
                    message: state.message,
                  ),
                );
              } else if (state is TransactionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  AppSnackbar.success(
                    message: 'Transaction restored',
                  ),
                );
              }
            },
          ),
        ],
        child: AppScaffold(
          showAppBar: false,
          extendBody: true,
          bottomNavigationBar: _FloatingNavBar(
            currentIndex: _currentIndex,
            onTap: changeTab,
            onFabPressed: () {
              HapticFeedback.lightImpact();
              SystemSound.play(SystemSoundType.click);
              context.pushNamed(AppRoutes.addTransaction.name);
            },
          ),
          child: IndexedStack(index: _currentIndex, children: _views),
        ),
      ),
    );
  }
}

// ─── Floating Pill Navigation Bar ────────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabPressed;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
  });

  static const _items = [
    (icon: Icons.home_rounded, unsel: Icons.home_outlined, label: 'Home'),
    (icon: Icons.assignment_rounded, unsel: Icons.assignment_outlined, label: 'Transactions'),
    (icon: Icons.insert_chart_rounded, unsel: Icons.insert_chart_outlined_rounded, label: 'Analytics'),
    (icon: Icons.person_rounded, unsel: Icons.person_outline_rounded, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pill background
    final pillBg = isDark ? themeExt.fabColor : themeExt.cardColor;

    // Selected circle fill
    final selCircleBg = isDark
        ? const Color(0xFFF5F5F7)         // off-white color in dark mode
        : themeExt.primary;               // primary purple on light pill

    // Selected icon color
    final selIconColor = isDark
        ? const Color(0xFF121212)         // dark color for icon in dark mode
        : themeExt.onPrimary;

    // Unselected icon/label color
    final unselColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : themeExt.onSurfaceVariant.withValues(alpha: 0.55);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Pill nav ─────────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Sliding selected circle background
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          left: currentIndex * 58,
                          top: 0,
                          width: 58,
                          height: 50,
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: selCircleBg,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        // Row of interactive items
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_items.length, (i) {
                            final item = _items[i];
                            final selected = currentIndex == i;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  SystemSound.play(SystemSoundType.click);
                                  onTap(i);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(
                                        selected ? item.icon : item.unsel,
                                        key: ValueKey(selected),
                                        color: selected ? selIconColor : unselColor,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── FAB ──────────────────────────────────────────────────────
              GestureDetector(
                onTap: onFabPressed,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? themeExt.surfaceContainerHigh : themeExt.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: themeExt.primary,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
