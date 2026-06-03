import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

enum AppButtonVariant {
  ghost,
  filled,
  outlined,
  custom,
}

/// A premium, reusable button widget conforming to the SpendSum design specifications.
class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final AppButtonVariant variant;

  // Custom styling properties (active only for .custom variant)
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  /// A text/flat button with transparent background.
  const AppButton.ghost({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.padding,
    this.textStyle,
  })  : variant = AppButtonVariant.ghost,
        backgroundColor = null,
        foregroundColor = null,
        borderSide = null,
        borderRadius = null;

  /// The primary filled brand button.
  const AppButton.filled({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.padding,
    this.textStyle,
  })  : variant = AppButtonVariant.filled,
        backgroundColor = null,
        foregroundColor = null,
        borderSide = null,
        borderRadius = null;

  /// An outlined button with surface background and outline borders.
  const AppButton.outlined({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.padding,
    this.textStyle,
  })  : variant = AppButtonVariant.outlined,
        backgroundColor = null,
        foregroundColor = null,
        borderSide = null,
        borderRadius = null;

  /// A fully custom configured button.
  const AppButton.custom({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.backgroundColor,
    this.foregroundColor,
    this.borderSide,
    this.borderRadius,
    this.padding,
    this.textStyle,
  }) : variant = AppButtonVariant.custom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    // Resolve sizing sizes:
    // If width/height is double.infinity, it expands. If null, it wraps. If specific value, it conforms.
    final double minWidth = width ?? 0.0;
    final double minHeight = height == double.infinity ? 56.0 : (height ?? 0.0);
    final double maxWidth = width ?? double.infinity;
    final double maxHeight = height ?? double.infinity;

    final buttonStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size(minWidth, minHeight)),
      maximumSize: WidgetStateProperty.all(Size(maxWidth, maxHeight)),
      padding: WidgetStateProperty.all(
        padding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      ),
      textStyle: WidgetStateProperty.all(
        textStyle ?? GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusLg), // Default 32px
        ),
      ),
    );

    switch (variant) {
      case AppButtonVariant.filled:
        return FilledButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        );

      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(themeExt.surfaceContainer),
            side: WidgetStateProperty.all(BorderSide(color: themeExt.outline, width: 1)),
            foregroundColor: WidgetStateProperty.all(themeExt.onSurface),
          ),
          child: child,
        );

      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: onPressed,
          style: buttonStyle.copyWith(
            foregroundColor: WidgetStateProperty.all(themeExt.primary),
            overlayColor: WidgetStateProperty.all(themeExt.primary.withValues(alpha: 0.08)),
          ),
          child: child,
        );

      case AppButtonVariant.custom:
        return FilledButton(
          onPressed: onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: backgroundColor != null ? WidgetStateProperty.all(backgroundColor) : null,
            foregroundColor: foregroundColor != null ? WidgetStateProperty.all(foregroundColor) : null,
            side: borderSide != null ? WidgetStateProperty.all(borderSide) : null,
            shape: borderRadius != null
                ? WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: borderRadius!))
                : null,
          ),
          child: child,
        );
    }
  }
}
