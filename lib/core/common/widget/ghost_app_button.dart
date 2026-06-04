part of 'app_button.dart';

/// Concrete implementation for the Ghost/Flat text button.
class _GhostAppButton extends AppButton {
  const _GhostAppButton({
    super.key,
    required super.onPressed,
    super.child,
    super.text,
    super.width = double.infinity,
    super.height = double.infinity,
    super.padding,
    super.textStyle,
    super.loading,
    super.shape,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final baseStyle = resolveButtonStyle(context);

    return TextButton(
      onPressed: wrapOnPressed(context),
      style: baseStyle.copyWith(
        foregroundColor: WidgetStateProperty.all(themeExt.primary),
        overlayColor: WidgetStateProperty.all(
          themeExt.primary.withValues(alpha: 0.08),
        ),
      ),
      child: buildContent(context, themeExt.primary),
    );
  }
}
