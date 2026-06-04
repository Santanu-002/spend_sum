part of 'app_button.dart';

/// Concrete implementation for the Custom styled button.
class _CustomAppButton extends AppButton {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;

  const _CustomAppButton({
    super.key,
    required super.onPressed,
    super.child,
    super.text,
    super.width = double.infinity,
    super.height = double.infinity,
    this.backgroundColor,
    this.foregroundColor,
    this.borderSide,
    this.borderRadius,
    super.padding,
    super.textStyle,
    super.loading,
    super.shape,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;
    final baseStyle = resolveButtonStyle(
      context,
      customBorderRadius: borderRadius,
    );
    final resolvedForegroundColor =
        foregroundColor ?? themeExt.onPrimary;

    return FilledButton(
      onPressed: wrapOnPressed(context),
      style: baseStyle.copyWith(
        backgroundColor: backgroundColor != null
            ? WidgetStateProperty.all(backgroundColor)
            : null,
        foregroundColor: foregroundColor != null
            ? WidgetStateProperty.all(foregroundColor)
            : null,
        side: borderSide != null ? WidgetStateProperty.all(borderSide) : null,
      ),
      child: buildContent(context, resolvedForegroundColor),
    );
  }
}
