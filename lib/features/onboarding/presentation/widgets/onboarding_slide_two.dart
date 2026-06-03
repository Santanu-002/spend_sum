import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/widget/app_button.dart';
import 'package:spend_sum/features/onboarding/presentation/widgets/network_avatar.dart';

/// The second onboarding slide showing the staggered list of invite cards.
class OnboardingSlideTwo extends StatelessWidget {
  final PageController pageController;
  final int currentIndex;

  const OnboardingSlideTwo({
    super.key,
    required this.pageController,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
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
    if (pageController.hasClients) {
      page = pageController.page ?? 0.0;
    } else {
      page = currentIndex.toDouble();
    }
    final double entryProgress = (1.0 - (page - 1.0).abs()).clamp(0.0, 1.0);

    final Color cardColor = themeExt.cardColor;

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
}
