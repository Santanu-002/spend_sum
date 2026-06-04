import 'package:flutter/material.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/painter/donut_chart_painter.dart';

/// The third onboarding slide showing an animated circular progress chart and spending details.
class OnboardingSlideThree extends StatefulWidget {
  final PageController pageController;
  final int currentIndex;

  const OnboardingSlideThree({
    super.key,
    required this.pageController,
    required this.currentIndex,
  });

  @override
  State<OnboardingSlideThree> createState() => _OnboardingSlideThreeState();
}

class _OnboardingSlideThreeState extends State<OnboardingSlideThree>
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
      duration: const Duration(milliseconds: 1800),
    );

    // Fade-in animation for the progress indicator container and text
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    // Transition progress for the budget-to-expense chart animation (green shrinks as purple expands)
    _chartAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.15, 0.95, curve: Curves.easeInOutCubic),
    );

    // Gentle rotation animation for the entire chart (clockwise locking effect)
    _rotationAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
    );

    // Trigger animation if page is already active on build
    if (widget.currentIndex == 2) {
      _animationController.forward();
    }

    widget.pageController.addListener(_onPageScroll);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageScroll);
    _animationController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    if (!mounted) return;
    if (widget.pageController.hasClients) {
      final page = widget.pageController.page ?? 0.0;
      // Start the animation earlier (as soon as the user starts swiping into slide 3)
      if (page > 1.05) {
        if (!_animationController.isAnimating &&
            _animationController.status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      } else if (page <= 1.0) {
        // Reset animation when user scrolls completely back to slide 1 or 2
        if (!_animationController.isAnimating &&
            _animationController.status == AnimationStatus.completed) {
          _animationController.reset();
        }
      }
      // Rebuild the slide to update entryProgress dynamically during the swipe
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    // Calculate active entrance progress of the third page (1.0 when fully active, 0.0 when offscreen)
    double page = 0.0;
    if (widget.pageController.hasClients) {
      page = widget.pageController.page ?? 0.0;
    } else {
      page = widget.currentIndex.toDouble();
    }
    final double entryProgress = (1.0 - (page - 2.0).abs()).clamp(0.0, 1.0);

    return Opacity(
      opacity: entryProgress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.marginPage,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3), // Pushes progress section down
            // Centered Animated Circular Progress
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SizedBox(
                    width: 220.0,
                    height: 220.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating painter wrapping around the canvas
                        Transform.rotate(
                          angle: (1.0 - _rotationAnimation.value) * -0.25,
                          child: SizedBox.expand(
                            child: CustomPaint(
                              painter: AnimatedDonutChartPainter(
                                primaryColor: themeExt.primaryContainer,
                                secondaryColor: themeExt.secondary,
                                trackColor: themeExt.outlineVariant,
                                chartProgress: _chartAnimation.value,
                                overallOpacity: _fadeAnimation.value,
                                expenseRatio: 313.31 / 417.75,
                              ),
                            ),
                          ),
                        ),
                        // Content Text (fades in)
                        Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'July',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: themeExt.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6.0),
                              AnimatedDigitWidget(
                                value: 313.31,
                                prefix: '\$',
                                fractionDigits: 2,
                                enableSeparator: false,
                                textStyle:
                                    theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ) ??
                                    const TextStyle(),
                                duration: const Duration(milliseconds: 1400),
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

            const SizedBox(
              height: AppDimensions.stackLg,
            ), // Pushes text close to bottom actions
          ],
        ),
      ),
    );
  }
}
