import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spend_sum/core/theme/app_colors.dart';

/// A custom double bar chart that renders dynamic monthly data using the fl_chart package.
/// The chart features a bouncy growth animation on load or data update.
class DoubleBarChart extends StatefulWidget {
  final List<Map<String, dynamic>> monthlyData;
  final String currencySymbol;

  const DoubleBarChart({
    super.key,
    required this.monthlyData,
    this.currencySymbol = '\$',
  });

  @override
  State<DoubleBarChart> createState() => _DoubleBarChartState();
}

class _DoubleBarChartState extends State<DoubleBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _growthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _growthAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  bool _areMonthlyDataEqual(List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      final m1 = list1[i];
      final m2 = list2[i];
      if (m1.length != m2.length) return false;
      for (final key in m1.keys) {
        if (m1[key] != m2[key]) return false;
      }
    }
    return true;
  }

  @override
  void didUpdateWidget(covariant DoubleBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_areMonthlyDataEqual(oldWidget.monthlyData, widget.monthlyData)) {
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

    if (widget.monthlyData.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No historical chart data available',
            style: GoogleFonts.inter(
              color: themeExt.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Find the maximum value to scale the chart correctly
    double maxVal = 50.0;
    for (final item in widget.monthlyData) {
      final inc = (item['income'] as num).toDouble();
      final exp = (item['expense'] as num).toDouble();
      maxVal = math.max(maxVal, math.max(inc, exp));
    }
    // Round maxVal up to the nearest clean 10 or 100 for clean look
    maxVal = (maxVal / 10).ceil() * 10.0;

    return AnimatedBuilder(
      animation: _growthAnimation,
      builder: (context, child) {
        final progress = _growthAnimation.value;
        return SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => themeExt.inverseSurface,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final String type = rodIndex == 0 ? 'Income' : 'Expense';
                      final originalY = rodIndex == 0 
                          ? (widget.monthlyData[groupIndex]['income'] as num).toDouble()
                          : (widget.monthlyData[groupIndex]['expense'] as num).toDouble();
                      return BarTooltipItem(
                        '$type: ${widget.currencySymbol}${originalY.toStringAsFixed(2)}',
                        GoogleFonts.inter(
                          color: themeExt.inverseOnSurface,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => const SizedBox.shrink(),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: maxVal / 3 > 0 ? maxVal / 3 : 1.0,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 6,
                          child: Text(
                            '${widget.currencySymbol}${value.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: themeExt.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();
                        if (index < 0 || index >= widget.monthlyData.length) {
                          return const SizedBox.shrink();
                        }
                        final String label = widget.monthlyData[index]['month'];
                        final isCurrent = index == widget.monthlyData.length - 1;
                        final double fontSize = label.length > 6 ? 9.5 : 11.0;
  
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: fontSize,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent ? themeExt.primary : themeExt.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 3 > 0 ? maxVal / 3 : 1.0,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: themeExt.outlineVariant.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(widget.monthlyData.length, (index) {
                  final item = widget.monthlyData[index];
                  final double income = (item['income'] as num).toDouble();
                  final double expense = (item['expense'] as num).toDouble();
  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      // Income rod (Green)
                      BarChartRodData(
                        toY: income * progress,
                        color: themeExt.secondaryContainer,
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      // Expense rod (Purple)
                      BarChartRodData(
                        toY: expense * progress,
                        color: themeExt.primaryContainer,
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
