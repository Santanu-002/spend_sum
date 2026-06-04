import 'package:flutter/material.dart';

/// Right-facing crescent logo custom painter.
class CrescentLogoPainter extends CustomPainter {
  final Color color;

  CrescentLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path1 = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    // Subtract an overlapping oval on the left to leave a crescent on the right
    final path2 = Path()
      ..addOval(
        Rect.fromLTWH(
          -size.width * 0.38,
          size.height * 0.1,
          size.width,
          size.height * 0.8,
        ),
      );

    final resultPath = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(resultPath, paint);
  }

  @override
  bool shouldRepaint(covariant CrescentLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
