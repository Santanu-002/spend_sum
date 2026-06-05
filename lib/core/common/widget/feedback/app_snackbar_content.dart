part of 'app_snackbar.dart';

class _AppSnackbarContent extends StatelessWidget {
  final String message;
  final Widget? trailingAction;
  final _AppSnackbarType type;

  const _AppSnackbarContent({
    required this.message,
    required this.type,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // Determine background and foreground colors matching the theme and types.
    Color backgroundColor;
    Color foregroundColor;

    switch (type) {
      case _AppSnackbarType.neutral:
        backgroundColor = theme.colorScheme.inverseSurface;
        foregroundColor = theme.colorScheme.onInverseSurface;
        break;
      case _AppSnackbarType.success:
        backgroundColor = theme.colorScheme.secondaryContainer;
        foregroundColor = theme.colorScheme.onSecondaryContainer;
        break;
      case _AppSnackbarType.destructive:
        backgroundColor = theme.colorScheme.errorContainer;
        foregroundColor = theme.colorScheme.onErrorContainer;
        break;
      case _AppSnackbarType.pending:
        backgroundColor = theme.colorScheme.tertiaryContainer;
        foregroundColor = theme.colorScheme.onTertiaryContainer;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: foregroundColor,
              ),
            ),
          ),
          if (trailingAction != null) ...[
            const SizedBox(width: 12.0),
            IconTheme(
              data: IconThemeData(color: foregroundColor, size: 20),
              child: trailingAction!,
            ),
          ],
        ],
      ),
    );
  }
}
