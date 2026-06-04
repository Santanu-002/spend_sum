part of 'app_button.dart';

/// Concrete implementation for the Outlined surface button.
class _OutlinedAppButton extends AppButton {
  const _OutlinedAppButton({
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
    final themeExt = context.colorscheme;
    final baseStyle = resolveButtonStyle(context);

    return OutlinedButton(
      onPressed: wrapOnPressed(context),
      style: baseStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(themeExt.surfaceContainer),
        side: WidgetStateProperty.all(
          BorderSide(color: themeExt.outline, width: 1),
        ),
        foregroundColor: WidgetStateProperty.all(themeExt.onSurface),
      ),
      child: buildContent(context, themeExt.onSurface),
    );
  }
}
