import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/crescent_logo_painter.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/dashed_border_painter.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/donut_chart_painter.dart';

/// The third onboarding slide showing analytics donut charts and spending details.
class OnboardingSlideThree extends StatelessWidget {
  const OnboardingSlideThree({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3), // Pushes graphics section down

          // Double card graphics section (Cashio panel and Donut card)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Vertical Cashio brand card
              Container(
                width: 68.0,
                height: 200.0,
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: themeExt.outlineVariant.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                ),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: themeExt.outlineVariant.withValues(alpha: 0.5),
                    radius: 14.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rotated App Name text
                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'Cashio',
                          style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: themeExt.primaryContainer,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // Cashio Logo
                      CustomPaint(
                        size: const Size(24.0, 24.0),
                        painter: CrescentLogoPainter(color: themeExt.primaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12.0),

              // Expense & Spending Card
              Expanded(
                child: Container(
                  height: 230.0,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: themeExt.cardColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14.0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: themeExt.outlineVariant.withValues(alpha: 0.12),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Donut Chart + Expense Total Row
                      Center(
                        child: SizedBox(
                          width: 110.0,
                          height: 110.0,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(110.0, 110.0),
                                painter: DonutChartPainter(
                                  primaryColor: themeExt.primaryContainer,
                                  secondaryColor: themeExt.secondary,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Expense Total in July',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                          fontSize: 7.5,
                                          color: themeExt.onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    '\$313.31',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.02,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Top Spending Header
                      Text(
                        'Top Spending',
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8.0),

                      // Spending item detail
                      Row(
                        children: [
                          Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: BoxDecoration(
                              color: themeExt.primaryContainer.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.description_outlined,
                              color: themeExt.primary,
                              size: 16.0,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bills & Utilities',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 1.0),
                                Text(
                                  '\$120 more than June',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                        fontSize: 8.5,
                                        color: themeExt.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Spacer(flex: 4), // Pushes text section further down

          // Title
          Text(
            'Track your Spending',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),

          // Subtitle
          Text(
            'Track and analyse spending immediately through our bank connection.',
            style: theme.textTheme.bodyLarge?.copyWith(
                  color: themeExt.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.stackLg), // Pushes text close to bottom actions
        ],
      ),
    );
  }
}
