import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A standard iOS-style back button widget using arrow_back_ios_new
/// to be utilized across all platforms in SpendSum.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const AppBackButton({super.key, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
        if (onPressed != null) {
          onPressed?.call();
        } else {
          Navigator.of(context).maybePop();
        }
      },
    );
  }
}
