import 'package:flutter/material.dart';

/// A circular ring shape used to represent donut/gauge skeletons.
class SkeletonRing extends StatelessWidget {
  final double width;
  final double height;
  final double strokeWidth;

  const SkeletonRing({
    super.key,
    required this.width,
    required this.height,
    this.strokeWidth = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: strokeWidth,
        ),
      ),
    );
  }
}
