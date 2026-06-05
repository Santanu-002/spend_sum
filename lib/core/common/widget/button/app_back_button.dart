import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

/// A standard premium back button widget with a solid circular background
/// and a rounded chevron icon, utilized across all screens in SpendSum.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const AppBackButton({super.key, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;
    return Center(
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: Tooltip(
        message: MaterialLocalizations.of(context).backButtonTooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            SystemSound.play(SystemSoundType.click);
            if (onPressed != null) {
              onPressed?.call();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: themeExt.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: color ?? themeExt.onSurface,
              size: AppDimensions.iconLg,
            ),
          ),
        ),
      ),
    );
  }
}

