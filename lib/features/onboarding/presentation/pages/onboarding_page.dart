import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spend_sum/core/common/widget/button/app_button.dart';
import 'package:spend_sum/core/common/widget/layout/app_scaffold.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/slides/onboarding_slide_one.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/slides/onboarding_slide_two.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/slides/onboarding_slide_three.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:spend_sum/core/common/widget/feedback/app_snackbar.dart';
import 'package:spend_sum/app/dependency_injection.dart';

/// Onboarding carousel page of the SpendSum application.
/// Coordinates onboarding transitions and manages layout animation timelines.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (context) => sl<OnboardingCubit>(),
      child: const _OnboardingPageContent(),
    );
  }
}

class _OnboardingPageContent extends StatefulWidget {
  const _OnboardingPageContent();

  @override
  State<_OnboardingPageContent> createState() => _OnboardingPageContentState();
}

class _OnboardingPageContentState extends State<_OnboardingPageContent>
    with SingleTickerProviderStateMixin {
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

  void _completeOnboarding() {
    context.read<OnboardingCubit>().completeOnboarding();
  }

  void _onSkip() {
    _completeOnboarding();
  }

  void _onNext() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;

    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.goNamed(AppRoutes.auth.login.name);
        } else if (state is OnboardingFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbar.destructive(message: state.message),
          );
        }
      },
      child: AppScaffold(
        showAppBar: false,
        child: Stack(
        children: [
          Column(
            children: [
              // Page Carousel View containing the separate Slide widgets
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: [
                    OnboardingSlideOne(orbitController: _orbitController),
                    OnboardingSlideTwo(
                      pageController: _pageController,
                      currentIndex: _currentIndex,
                    ),
                    OnboardingSlideThree(
                      pageController: _pageController,
                      currentIndex: _currentIndex,
                    ),
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

          // Top-right corner Skip button (hidden on the final slide)
          if (_currentIndex < 2)
            Positioned(
              top: 8.0,
              right: AppDimensions.marginPage,
              child: AppButton.ghost(
                onPressed: _onSkip,
                text: 'Skip',
                width: null,
                height: null,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
