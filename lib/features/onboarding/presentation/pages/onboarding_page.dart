import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spend_sum/core/common/widget/app_button.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

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
      ..addOval(Rect.fromLTWH(
        -size.width * 0.38,
        size.height * 0.1,
        size.width,
        size.height * 0.8,
      ));

    final resultPath = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(resultPath, paint);
  }

  @override
  bool shouldRepaint(covariant CrescentLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Custom painter for drawing a dashed border around containers.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double radius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final dashPath = _dashPath(path, dashLength, gap);
    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(Path source, double dashLength, double gap) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashLength : gap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, math.min(distance + length, metric.length)),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

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

/// A circular avatar widget using CachedNetworkImage with a text fallback placeholder.
class NetworkAvatar extends StatelessWidget {
  final String imageUrl;
  final String initials;
  final Color backgroundColor;

  const NetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.initials,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 40.0,
        height: 40.0,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      width: 40.0,
      height: 40.0,
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: themeExt.onSurface,
        ),
      ),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Continuous animation controller for orbital rotation and bobbing
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    // Trigger state rebuild on scroll events to recalculate staggered swipe transitions
    _pageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
      // Completed Onboarding
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully completed onboarding!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusDefault)),
          backgroundColor: themeExt.primaryContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [themeExt.backgroundGradientStart, themeExt.backgroundGradientEnd],
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Page Carousel View
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: [
                    _buildSlideOne(),
                    _buildSlideTwo(),
                    _buildSlideThree(),
                  ],
                ),
              ),

              // Bottom Area (Smooth Page Indicator & Actions Button)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.marginPage,
                  right: AppDimensions.marginPage,
                  bottom: AppDimensions.marginPage,
                  top: AppDimensions.stackSm,
                ),
                child: Column(
                  children: [
                    // Smooth page indicator attached to the controller
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        activeDotColor: themeExt.primaryContainer,
                        dotColor: themeExt.outlineVariant,
                        dotHeight: 8.0,
                        dotWidth: 8.0,
                        expansionFactor: 3.5,
                        spacing: 8.0,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.stackXl),

                    // Primary action button (utilizes AppButton.filled)
                    AppButton.filled(
                      onPressed: _onNext,
                      child: Text(_currentIndex == 2 ? 'Get Started' : 'Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Slide 1 Screen implementation ---
  Widget _buildSlideOne() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final themeExt = theme.extension<AppThemeExtension>()!;
        final double containerSize = math.min(constraints.maxWidth * 0.75, 280.0);
        final double centerRadius = containerSize * 0.17; // center circle radius
        final double floaterRadius = containerSize * 0.1; // mini floaters radius
        final double orbitRadius = containerSize * 0.38; // orbit radius

        // Orbit icon configurations resolved through theme colors schema
        final List<Map<String, dynamic>> floaters = [
          {'icon': Icons.menu_book, 'color': themeExt.primary, 'angle': -140.0},
          {'icon': Icons.wallet, 'color': themeExt.secondary, 'angle': -90.0},
          {'icon': Icons.credit_card, 'color': themeExt.primaryContainer, 'angle': -40.0},
          {'icon': Icons.campaign, 'color': themeExt.error, 'angle': 30.0},
          {'icon': Icons.flight, 'color': themeExt.tertiary, 'angle': 90.0},
          {'icon': Icons.directions_car, 'color': themeExt.primary, 'angle': 180.0},
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3), // Pushes orbital graphic down

              // Visual Orbit Graphic (rebuilt smoothly with AnimatedBuilder)
              AnimatedBuilder(
                animation: _orbitController,
                builder: (context, child) {
                  final double angleOffset = _orbitController.value * 360.0;

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
                              color: themeExt.outlineVariant.withValues(alpha: 0.15),
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
                            painter: CrescentLogoPainter(color: themeExt.primaryContainer),
                          ),
                        ),

                        // Outer floating circles with orbital motion & bobbing
                        ...floaters.map((data) {
                          final double baseAngle = data['angle'] as double;
                          final double currentAngle = baseAngle + angleOffset;
                          final double angleRad = currentAngle * math.pi / 180.0;

                          // Subtle sinusoidal bobbing along the radius for floating depth
                          final double bobbing = 5.0 * math.sin(_orbitController.value * 4 * math.pi + (baseAngle * math.pi / 180.0));
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

              const SizedBox(height: AppDimensions.stackLg), // Pushes text close to bottom actions
            ],
          ),
        );
      },
    );
  }

  // --- Slide 2 Screen implementation ---
  Widget _buildSlideTwo() {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    // Staggered contacts data
    final contacts = [
      {
        'name': 'Ethan Cole',
        'email': 'ethancoleux@gmail.com',
        'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'init': 'EC',
        'bg': themeExt.errorContainer,
        'offset': 0.0
      },
      {
        'name': 'Alex Carter',
        'email': 'alex.carter@email.com',
        'image': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
        'init': 'AC',
        'bg': themeExt.secondaryContainer,
        'offset': 24.0
      },
      {
        'name': 'Maya Bennett',
        'email': 'maya.bennett@email.com',
        'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'init': 'MB',
        'bg': themeExt.primaryContainer,
        'offset': 48.0
      },
    ];

    // Compute active entrance progress: 1.0 when fully visible, 0.0 when offscreen
    double page = 0.0;
    if (_pageController.hasClients) {
      page = _pageController.page ?? 0.0;
    } else {
      page = _currentIndex.toDouble();
    }
    final double entryProgress = (1.0 - (page - 1.0).abs()).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3), // Pushes contacts graphic down

          // Column layout containing the staggered contacts cards list (avoids fixed height Stack overlaps)
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: contacts.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final baseOffset = data['offset'] as double;

                // Animate staggered entering translation offset
                final double slideOffset = (1.0 - entryProgress) * (160.0 + index * 60.0);

                // Revert card background to original: White in light theme, surfaceContainer (#1f1f24) in dark theme
                final Color cardColor = themeExt.cardColor;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == contacts.length - 1 ? 0.0 : AppDimensions.stackSm, // spacing between contact cards
                  ),
                  child: Transform.translate(
                    offset: Offset(slideOffset, 0.0), // horizontal translation during swipes
                    child: Opacity(
                      opacity: entryProgress,
                      child: Padding(
                        // structural padding to offset the card layout horizontally (maintaining constant card width)
                        padding: EdgeInsets.only(
                          left: baseOffset,
                          right: 48.0 - baseOffset,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: themeExt.outlineVariant.withValues(alpha: 0.12),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Custom circular avatar widget using CachedNetworkImage
                              NetworkAvatar(
                                imageUrl: data['image'] as String,
                                initials: data['init'] as String,
                                backgroundColor: data['bg'] as Color,
                              ),
                              const SizedBox(width: 12.0),

                              // Text details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      data['name'] as String,
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      data['email'] as String,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                            color: themeExt.onSurfaceVariant,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8.0),

                              // Invite button (uses AppButton.custom with wrap-content sizing)
                              AppButton.custom(
                                width: null, // Wrap content horizontally
                                height: 32.0, // Fixed height constraint
                                backgroundColor: themeExt.primaryContainer.withValues(alpha: 0.12),
                                foregroundColor: themeExt.primary,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                onPressed: () {},
                                child: const Text(
                                  'Invite',
                                  style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Spacer(flex: 4), // Pushes text section further down

          // Title
          Text(
            'Invite Other People',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),

          // Subtitle
          Text(
            'Connect all your accounts from any bank. Add savings, credit cards, PayPal and more.',
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

  // --- Slide 3 Screen implementation ---
  Widget _buildSlideThree() {
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
