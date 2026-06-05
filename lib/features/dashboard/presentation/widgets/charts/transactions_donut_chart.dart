import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:animated_digit/animated_digit.dart';
import 'package:spend_sum/core/theme/app_colors.dart';

/// Dynamic, interactive donut chart with pill edges (StrokeCap.round) and entry animations.
class TransactionsDonutChart extends StatefulWidget {
  final double expenseAmount;
  final double budgetAmount;
  final String monthLabel;
  final String currencySymbol;
  final bool isLoading;

  const TransactionsDonutChart({
    super.key,
    required this.expenseAmount,
    required this.budgetAmount,
    required this.monthLabel,
    this.currencySymbol = '\$',
    this.isLoading = false,
  });

  @override
  State<TransactionsDonutChart> createState() => _TransactionsDonutChartState();
}

class _TransactionsDonutChartState extends State<TransactionsDonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _chartAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _chartAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 1.0, curve: Curves.fastOutSlowIn),
    );

    _rotationAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant TransactionsDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expenseAmount != widget.expenseAmount ||
        oldWidget.budgetAmount != widget.budgetAmount) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;

    final double expense = widget.expenseAmount;
    final double budget = widget.budgetAmount;

    // Calculate ratio
    final double ratio;
    if (budget <= 0) {
      ratio = expense > 0 ? 1.0 : 0.0;
    } else {
      ratio = (expense / budget).clamp(0.0, 1.0);
    }

    final bool isOverBudget = expense > budget && budget > 0;
    final bool hasNoData = expense == 0 && budget == 0;

    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SizedBox(
            width: 220.0,
            height: 220.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating custom painter for pill-edge donut chart
                Transform.rotate(
                  angle: (1.0 - _rotationAnimation.value) * -0.25,
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: _PillDonutChartPainter(
                        primaryColor:
                            isOverBudget ? themeExt.error : themeExt.primary,
                        secondaryColor: themeExt.secondary,
                        trackColor: themeExt.outlineVariant,
                        chartProgress: _chartAnimation.value,
                        overallOpacity: _fadeAnimation.value,
                        expenseRatio: ratio,
                        hasNoData: hasNoData,
                      ),
                    ),
                  ),
                ),
                // Centered text content
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Spent in ${widget.monthLabel}',
                        style: TextStyle(fontFamily: 'Inter', 
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themeExt.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      AnimatedDigitWidget(
                        value: widget.expenseAmount,
                        prefix: widget.currencySymbol,
                        fractionDigits: 2,
                        enableSeparator: false,
                        textStyle: TextStyle(fontFamily: 'Outfit', 
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: themeExt.onSurface,
                          letterSpacing: -0.5,
                        ),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                      ),
                    ],
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

class _PillDonutChartPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color trackColor;
  final double chartProgress;
  final double overallOpacity;
  final double expenseRatio;
  final bool hasNoData;

  _PillDonutChartPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.trackColor,
    required this.chartProgress,
    required this.overallOpacity,
    required this.expenseRatio,
    required this.hasNoData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.width * 0.08;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // 1. Background Track
    paint.color = trackColor.withValues(alpha: 0.12);
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint);

    if (hasNoData) {
      return;
    }

    // Dynamic gaps for visual separation between segments
    final double gapAngle =
        (expenseRatio > 0.01 && expenseRatio < 0.99) ? 0.064 * math.pi : 0.0;
    final double totalActiveAngle = 2.0 * math.pi - (2.0 * gapAngle);

    final double finalPurpleSweep = totalActiveAngle * expenseRatio;
    final double finalGreenSweep = totalActiveAngle * (1.0 - expenseRatio);

    // 2. Green Budget Segment (Remaining amount)
    paint.color = secondaryColor;
    final double greenStart =
        -0.5 * math.pi + (finalPurpleSweep + gapAngle) * chartProgress;
    final double greenSweep =
        2.0 * math.pi - (2.0 * math.pi - finalGreenSweep) * chartProgress;

    if (greenSweep > 0.01) {
      canvas.drawArc(rect, greenStart, greenSweep, false, paint);
    }

    // 3. Purple/Error Expense Segment (Spent amount)
    if (chartProgress > 0.0) {
      paint.color = primaryColor.withValues(alpha: overallOpacity);
      final double purpleSweep = finalPurpleSweep * chartProgress;
      if (purpleSweep > 0.01) {
        canvas.drawArc(rect, -0.5 * math.pi, purpleSweep, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PillDonutChartPainter oldDelegate) {
    return oldDelegate.chartProgress != chartProgress ||
        oldDelegate.overallOpacity != overallOpacity ||
        oldDelegate.expenseRatio != expenseRatio ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.hasNoData != hasNoData;
  }
}
