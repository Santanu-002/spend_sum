import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

part 'filled_app_button.dart';
part 'outlined_app_button.dart';
part 'ghost_app_button.dart';
part 'custom_app_button.dart';

/// Available shapes for the AppButton.
enum AppButtonShape { rounded, pill, hardEdge, roundedFull }

/// A premium, reusable button widget conforming to the SpendSum design specifications.
/// Implements polymorphic button behaviors through specific factory constructors.
abstract class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool loading;
  final AppButtonShape shape;

  const AppButton({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
    this.width,
    this.height,
    this.padding,
    this.textStyle,
    this.loading = false,
    this.shape = AppButtonShape.pill,
  });

  /// The primary filled brand button.
  const factory AppButton.filled({
    Key? key,
    required VoidCallback? onPressed,
    Widget? child,
    String? text,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    bool loading,
    AppButtonShape shape,
  }) = _FilledAppButton;

  /// An outlined button with surface background and outline borders.
  const factory AppButton.outlined({
    Key? key,
    required VoidCallback? onPressed,
    Widget? child,
    String? text,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    bool loading,
    AppButtonShape shape,
  }) = _OutlinedAppButton;

  /// A text/flat button with transparent background.
  const factory AppButton.ghost({
    Key? key,
    required VoidCallback? onPressed,
    Widget? child,
    String? text,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    bool loading,
    AppButtonShape shape,
  }) = _GhostAppButton;

  /// A fully custom configured button.
  const factory AppButton.custom({
    Key? key,
    required VoidCallback? onPressed,
    Widget? child,
    String? text,
    double? width,
    double? height,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    bool loading,
    AppButtonShape shape,
  }) = _CustomAppButton;

  /// Wraps the onPressed handler to provide light haptic and click sound feedback.
  /// Automatically disables click interactions while button is loading.
  VoidCallback? wrapOnPressed(BuildContext context) {
    if (onPressed == null || loading) return null;
    return () {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
      onPressed?.call();
    };
  }

  /// Builds the content of the button, displaying a loading indicator or text/child.
  Widget buildContent(BuildContext context, Color foregroundColor) {
    if (loading) {
      return SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }
    return child ?? Text(text ?? '');
  }

  /// Resolves the border radius based on selected AppButtonShape.
  BorderRadius resolveBorderRadius() {
    switch (shape) {
      case AppButtonShape.hardEdge:
        return BorderRadius.zero;
      case AppButtonShape.rounded:
        return BorderRadius.circular(AppDimensions.radiusSm); // 8px
      case AppButtonShape.roundedFull:
        return BorderRadius.circular(AppDimensions.radiusDefault); // 16px
      case AppButtonShape.pill:
        return BorderRadius.circular(AppDimensions.radiusFull); // 9999px
    }
  }

  /// Resolves the layout styles, shape, and sizing of the button.
  ButtonStyle resolveButtonStyle(
    BuildContext context, {
    BorderRadius? customBorderRadius,
  }) {
    final double minWidth = width ?? 0.0;
    final double minHeight = height == double.infinity ? 56.0 : (height ?? 0.0);
    final double maxWidth = width ?? double.infinity;
    final double maxHeight = height ?? double.infinity;

    final resolvedPadding = padding ??
        ((width == null && height == null)
            ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0)
            : const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0));

    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size(minWidth, minHeight)),
      maximumSize: WidgetStateProperty.all(Size(maxWidth, maxHeight)),
      padding: WidgetStateProperty.all(resolvedPadding),
      textStyle: WidgetStateProperty.all(
        textStyle ?? context.textTheme.labelLarge,
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? resolveBorderRadius(),
        ),
      ),
    );
  }
}
