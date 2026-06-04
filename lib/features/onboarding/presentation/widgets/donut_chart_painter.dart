import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated custom painter to draw the budget-to-expense transition donut chart.
class AnimatedDonutChartPainter extends CustomPainter {
  final Color primaryColor; // Expense (Purple)
  final Color secondaryColor; // Budget (Green)
  final Color trackColor;
  final double chartProgress; // 0.0 to 1.0 transition progress
  final double overallOpacity;
  final double expenseRatio; // Dynamic ratio of expense to budget

  AnimatedDonutChartPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.trackColor,
    required this.chartProgress,
    required this.overallOpacity,
    required this.expenseRatio,
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

    // Dynamic gaps matching onboarding slide 3 specification
    final double gapAngle = (expenseRatio > 0.005 && expenseRatio < 0.995)
        ? 0.064 * math.pi
        : 0.0;
    final double totalActiveAngle = 2.0 * math.pi - (2.0 * gapAngle);

    final double finalPurpleSweep = totalActiveAngle * expenseRatio;
    final double finalGreenSweep = totalActiveAngle * (1.0 - expenseRatio);

    // 2. Green Budget Segment (Shrinks as animation progresses)
    paint.color = secondaryColor;
    final double greenStart =
        -0.5 * math.pi + (finalPurpleSweep + gapAngle) * chartProgress;
    final double greenSweep =
        2.0 * math.pi - (2.0 * math.pi - finalGreenSweep) * chartProgress;

    if (greenSweep > 0.01) {
      canvas.drawArc(rect, greenStart, greenSweep, false, paint);
    }

    // 3. Purple Expense Segment (Grows as animation progresses)
    if (chartProgress > 0.0) {
      paint.color = primaryColor.withValues(alpha: overallOpacity);
      final double purpleSweep = finalPurpleSweep * chartProgress;
      if (purpleSweep > 0.01) {
        canvas.drawArc(rect, -0.5 * math.pi, purpleSweep, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedDonutChartPainter oldDelegate) {
    return oldDelegate.chartProgress != chartProgress ||
        oldDelegate.overallOpacity != overallOpacity ||
        oldDelegate.expenseRatio != expenseRatio ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.trackColor != trackColor;
  }
}
