import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/widget/app_button.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/network_avatar.dart';

/// The second onboarding slide showing the staggered list of invite cards.
/// Rebuilt with an internal AnimationController to ensure staggered animations play smoothly
/// regardless of navigation method (swiping vs programmatic click).
class OnboardingSlideTwo extends StatefulWidget {
  final PageController pageController;
  final int currentIndex;

  const OnboardingSlideTwo({
    super.key,
    required this.pageController,
    required this.currentIndex,
  });

  @override
  State<OnboardingSlideTwo> createState() => _OnboardingSlideTwoState();
}

class _OnboardingSlideTwoState extends State<OnboardingSlideTwo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final List<Animation<double>> _slideAnimations;
  late final List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Rebuild UI when animation updates
    _animationController.addListener(() {
      if (mounted) setState(() {});
    });

    // Create staggered animations for the contact cards
    _slideAnimations = List.generate(3, (index) {
      final start = 0.1 * index;
      final end = (start + 0.65).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    _opacityAnimations = List.generate(3, (index) {
      final start = 0.1 * index;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    // Start playing immediately if this page is already active on initialization
    if (widget.currentIndex == 1) {
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

  @override
  void didUpdateWidget(covariant OnboardingSlideTwo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when the page index changes to active
    if (widget.currentIndex == 1 && oldWidget.currentIndex != 1) {
      _animationController.forward();
    } else if (widget.currentIndex != 1 && oldWidget.currentIndex == 1) {
      _animationController.reset();
    }
  }

  void _onPageScroll() {
    if (!mounted) return;
    if (widget.pageController.hasClients) {
      final page = widget.pageController.page ?? 0.0;
      // Start the animation when scrolling into slide 2 (pages between 0.05 and 1.95)
      if (page > 0.05 && page < 1.95) {
        if (!_animationController.isAnimating &&
            _animationController.status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      } else if (page <= 0.0 || page >= 2.0) {
        // Reset when user scrolls completely out of slide 2
        if (!_animationController.isAnimating &&
            _animationController.status != AnimationStatus.dismissed) {
          _animationController.reset();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    // Staggered contacts data
    final contacts = [
      {
        'name': 'Ethan Cole',
        'email': 'ethancoleux@gmail.com',
        'image':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'init': 'EC',
        'bg': themeExt.errorContainer,
        'offset': 0.0,
      },
      {
        'name': 'Alex Carter',
        'email': 'alex.carter@email.com',
        'image':
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
        'init': 'AC',
        'bg': themeExt.secondaryContainer,
        'offset': 24.0,
      },
      {
        'name': 'Maya Bennett',
        'email': 'maya.bennett@email.com',
        'image':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'init': 'MB',
        'bg': themeExt.primaryContainer,
        'offset': 48.0,
      },
    ];

    final Color cardColor = themeExt.cardColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3), // Pushes contacts graphic down
          // Column layout containing the staggered contacts cards list
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: contacts.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final baseOffset = data['offset'] as double;

                // Staggered parameters driven by animations
                final slideProgress = _slideAnimations[index].value;
                final opacityProgress = _opacityAnimations[index].value;
                final double slideOffset = (1.0 - slideProgress) * 160.0;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == contacts.length - 1
                        ? 0.0
                        : AppDimensions.stackSm,
                  ),
                  child: Transform.translate(
                    offset: Offset(slideOffset, 0.0),
                    child: Opacity(
                      opacity: opacityProgress,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: baseOffset,
                          right: 48.0 - baseOffset,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: themeExt.outlineVariant.withValues(
                                alpha: 0.12,
                              ),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Custom circular avatar widget
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
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: themeExt.onSurfaceVariant,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8.0),

                              // Invite button
                              AppButton.custom(
                                width: null,
                                height: 32.0,
                                backgroundColor: themeExt.primaryContainer
                                    .withValues(alpha: 0.12),
                                foregroundColor: themeExt.primary,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusDefault,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Invite',
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                  ),
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

          const SizedBox(height: AppDimensions.stackLg),
        ],
      ),
    );
  }
}
