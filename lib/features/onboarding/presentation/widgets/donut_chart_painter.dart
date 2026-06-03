import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter to draw the donut chart matching Slide 3.
class DonutChartPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  DonutChartPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 10.0;
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

    // Purple Segment (75% circle)
    paint.color = primaryColor;
    canvas.drawArc(
      rect,
      -0.5 * math.pi, // start at top
      1.5 * math.pi,  // sweep 270 degrees
      false,
      paint,
    );

    // Green Segment (20% circle)
    paint.color = secondaryColor;
    canvas.drawArc(
      rect,
      1.1 * math.pi, // start with gap
      0.35 * math.pi, // sweep 60 degrees
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => false;
}
