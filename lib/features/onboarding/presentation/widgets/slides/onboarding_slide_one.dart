import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/painter/crescent_logo_painter.dart';

/// The first onboarding slide showing the orbital rotating logo graphic.
class OnboardingSlideOne extends StatelessWidget {
  final AnimationController orbitController;

  const OnboardingSlideOne({super.key, required this.orbitController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = context.theme;
        final themeExt = theme.colorscheme;
        final double containerSize = math.min(
          constraints.maxWidth * 0.75,
          280.0,
        );
        final double centerRadius =
            containerSize * 0.17; // center circle radius
        final double floaterRadius =
            containerSize * 0.1; // mini floaters radius
        final double orbitRadius = containerSize * 0.38; // orbit radius

        // Orbit icon configurations resolved through theme colors schema
        final List<Map<String, dynamic>> floaters = [
          {'icon': Icons.menu_book, 'color': themeExt.primary, 'angle': -140.0},
          {'icon': Icons.wallet, 'color': themeExt.secondary, 'angle': -90.0},
          {
            'icon': Icons.credit_card,
            'color': themeExt.primaryContainer,
            'angle': -40.0,
          },
          {'icon': Icons.campaign, 'color': themeExt.error, 'angle': 30.0},
          {'icon': Icons.flight, 'color': themeExt.tertiary, 'angle': 90.0},
          {
            'icon': Icons.directions_car,
            'color': themeExt.primary,
            'angle': 180.0,
          },
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.marginPage,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3), // Pushes orbital graphic down
              // Visual Orbit Graphic (rebuilt smoothly with AnimatedBuilder)
              AnimatedBuilder(
                animation: orbitController,
                builder: (context, child) {
                  final double angleOffset = orbitController.value * 360.0;

                  return SizedBox(
                    width: containerSize,
                    height: containerSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Orbit circle guide line
                        Container(
                          width: orbitRadius * 2,
                          height: orbitRadius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: themeExt.outlineVariant.withValues(
                                alpha: 0.15,
                              ),
                              width: 1.5,
                            ),
                          ),
                        ),

                        // Center white card containing logo
                        Container(
                          width: centerRadius * 2,
                          height: centerRadius * 2,
                          decoration: BoxDecoration(
                            color: themeExt.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 16.0,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: CustomPaint(
                            size: Size(centerRadius * 0.9, centerRadius * 0.9),
                            painter: CrescentLogoPainter(
                              color: themeExt.primaryContainer,
                            ),
                          ),
                        ),

                        // Outer floating circles with orbital motion & bobbing
                        ...floaters.map((data) {
                          final double baseAngle = data['angle'] as double;
                          final double currentAngle = baseAngle + angleOffset;
                          final double angleRad =
                              currentAngle * math.pi / 180.0;

                          // Subtle sinusoidal bobbing along the radius for floating depth
                          final double bobbing =
                              5.0 *
                              math.sin(
                                orbitController.value * 4 * math.pi +
                                    (baseAngle * math.pi / 180.0),
                              );
                          final double currentRadius = orbitRadius + bobbing;

                          final double x = currentRadius * math.cos(angleRad);
                          final double y = currentRadius * math.sin(angleRad);

                          return Positioned(
                            left: containerSize / 2 + x - floaterRadius,
                            top: containerSize / 2 + y - floaterRadius,
                            child: Container(
                              width: floaterRadius * 2,
                              height: floaterRadius * 2,
                              decoration: BoxDecoration(
                                color: themeExt.surfaceContainerLowest,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10.0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                data['icon'] as IconData,
                                color: data['color'] as Color,
                                size: floaterRadius * 0.9,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(flex: 4), // Pushes text section further down
              // Title
              Text(
                'Your Finances in One Place',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.stackMd),

              // Subtitle
              Text(
                'Get the big picture on all your money. Connect your bank, track cash, or import data.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: themeExt.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: AppDimensions.stackLg,
              ), // Pushes text close to bottom actions
            ],
          ),
        );
      },
    );
  }
}
