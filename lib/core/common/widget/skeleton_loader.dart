import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spend_sum/core/theme/app_colors.dart';

/// A wrapper widget that applies a shimmer gradient effect to all child [SkeletonBox] items.
class SkeletonLoader extends StatelessWidget {
  final Widget child;

  const SkeletonLoader({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    return Shimmer.fromColors(
      baseColor: themeExt.outlineVariant.withValues(alpha: 0.18),
      highlightColor: themeExt.outlineVariant.withValues(alpha: 0.05),
      child: child,
    );
  }
}

/// A singular building-block shape used to compose skeleton loaders.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
    );
  }
}

/// A loading skeleton mockup representing a single TransactionTile.
class SkeletonTransactionTile extends StatelessWidget {
  const SkeletonTransactionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const SkeletonBox(
            width: 40,
            height: 40,
            borderRadius: 12,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                SkeletonBox(width: 120, height: 14, borderRadius: 4),
                SizedBox(height: 4),
                SkeletonBox(width: 80, height: 12, borderRadius: 4),
              ],
            ),
          ),
          const SkeletonBox(width: 60, height: 16, borderRadius: 4),
          const SizedBox(width: 8),
          const SkeletonBox(width: 18, height: 18, shape: BoxShape.circle),
        ],
      ),
    );
  }
}

/// A wireframe mockup skeleton mimicking the Home screen layout.
class SkeletonHomeView extends StatelessWidget {
  const SkeletonHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // This Month Spend Header & Amount (centered)
          Center(
            child: Column(
              children: const [
                SkeletonBox(width: 120, height: 14, borderRadius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: 180, height: 48, borderRadius: 8),
                SizedBox(height: 8),
                SkeletonBox(width: 160, height: 16, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Spending Wallet Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                SkeletonBox(width: 42, height: 42, shape: BoxShape.circle),
                SizedBox(width: 14),
                SkeletonBox(width: 120, height: 16, borderRadius: 4),
                Spacer(),
                SkeletonBox(width: 70, height: 16, borderRadius: 4),
                SizedBox(width: 8),
                SkeletonBox(width: 20, height: 20, shape: BoxShape.circle),
              ],
            ),
          ),
          const SizedBox(height: 36),
          // Recent Transactions Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonBox(width: 160, height: 20, borderRadius: 4),
              SkeletonBox(width: 50, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          // Transaction tiles loading skeletons
          for (int i = 0; i < 3; i++) ...[
            const SkeletonTransactionTile(),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// A wireframe mockup skeleton mimicking the Transactions list view.
class SkeletonTransactionsView extends StatelessWidget {
  const SkeletonTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Centered title "Transactions" skeleton
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: const SkeletonBox(
                  width: 180,
                  height: 28,
                  borderRadius: 6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Donut Chart Card
            Center(
              child: const SkeletonBox(
                width: 220,
                height: 220,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 28),
            // Top Spending section header
            const SkeletonBox(width: 120, height: 20, borderRadius: 4),
            const SizedBox(height: 12),
            // Top Spending Card skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SkeletonBox(width: 42, height: 42, shape: BoxShape.circle),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SkeletonBox(width: 100, height: 16, borderRadius: 4),
                        SizedBox(height: 4),
                        SkeletonBox(width: 150, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                  const SkeletonBox(width: 60, height: 16, borderRadius: 4),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // All Transactions section header
            const SkeletonBox(width: 140, height: 20, borderRadius: 4),
            const SizedBox(height: 16),
            // Search Bar skeleton
            const SkeletonBox(height: 52, borderRadius: 30),
            const SizedBox(height: 16),
            // Choice chips row
            Row(
              children: const [
                SkeletonBox(width: 60, height: 32, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 90, height: 32, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 80, height: 32, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 16),
            // Transaction tiles
            for (int i = 0; i < 3; i++) ...[
              const SkeletonTransactionTile(),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 100), // match the FAB spacing
          ],
        ),
      ),
    );
  }
}

/// A wireframe mockup skeleton mimicking the Analytics page structure.
class SkeletonAnalyticsView extends StatelessWidget {
  const SkeletonAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Centered title "Analytics" skeleton
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: const SkeletonBox(
                  width: 140,
                  height: 28,
                  borderRadius: 6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Period selector dropdown + legend skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonBox(width: 160, height: 36, borderRadius: 20),
                Row(
                  children: const [
                    SkeletonBox(width: 50, height: 12, borderRadius: 6),
                    SizedBox(width: 14),
                    SkeletonBox(width: 50, height: 12, borderRadius: 6),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Chart Card skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const SkeletonBox(height: 180, borderRadius: 12),
            ),
            const SizedBox(height: 28),
            // Income/Expense card rows skeleton
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const SkeletonBox(width: 38, height: 38, borderRadius: 12),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SkeletonBox(width: 50, height: 16, borderRadius: 4),
                              SizedBox(height: 4),
                              SkeletonBox(width: 60, height: 12, borderRadius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const SkeletonBox(width: 38, height: 38, borderRadius: 12),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SkeletonBox(width: 50, height: 16, borderRadius: 4),
                              SizedBox(height: 4),
                              SkeletonBox(width: 60, height: 12, borderRadius: 4),
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
            // History list header
            const SkeletonBox(width: 80, height: 20, borderRadius: 4),
            const SizedBox(height: 12),
            // History list items skeleton
            for (int i = 0; i < 3; i++) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SkeletonBox(width: 40, height: 40, shape: BoxShape.circle),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SkeletonBox(width: 90, height: 14, borderRadius: 4),
                          SizedBox(height: 4),
                          SkeletonBox(width: 110, height: 10, borderRadius: 4),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SkeletonBox(width: 50, height: 12, borderRadius: 4),
                        SizedBox(height: 4),
                        SkeletonBox(width: 50, height: 12, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 100), // FAB spacing
          ],
        ),
      ),
    );
  }
}
