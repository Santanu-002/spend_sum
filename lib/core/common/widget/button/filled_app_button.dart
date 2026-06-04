part of 'app_button.dart';

/// Concrete implementation for the Filled brand button.
class _FilledAppButton extends AppButton {
  const _FilledAppButton({
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

    return FilledButton(
      onPressed: wrapOnPressed(context),
      style: resolveButtonStyle(context).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (loading) {
            return themeExt.primary;
          }
          return null; // fallback to default
        }),
      ),
      child: buildContent(context, themeExt.onPrimary),
    );
  }
}
