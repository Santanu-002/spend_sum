part of 'select_category_sheet.dart';

// ---------------------------------------------------------------------------
// _CategoryGrid — GridView wrapper
// ---------------------------------------------------------------------------

class _CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final void Function(Map<String, dynamic> cat) onCategoryTap;
  final bool isExpense;

  const _CategoryGrid({
    required this.categories,
    required this.onCategoryTap,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppDimensions.gutterGrid,
        crossAxisSpacing: AppDimensions.gutterGrid,
        childAspectRatio: 0.78,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _CategoryGridItem(
        category: categories[index],
        onTap: onCategoryTap,
        isExpense: isExpense,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CategoryGridBody — routes between loading / error / grid
// ---------------------------------------------------------------------------

class _CategoryGridBody extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> categories;
  final VoidCallback onRetry;
  final void Function(Map<String, dynamic> cat) onCategoryTap;
  final bool isExpense;

  const _CategoryGridBody({
    required this.isLoading,
    required this.errorMessage,
    required this.categories,
    required this.onRetry,
    required this.onCategoryTap,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _CategoryLoadingIndicator();
    if (errorMessage != null) {
      return _CategoryErrorView(message: errorMessage!, onRetry: onRetry);
    }
    return _CategoryGrid(
      categories: categories,
      onCategoryTap: onCategoryTap,
      isExpense: isExpense,
    );
  }
}

// ---------------------------------------------------------------------------
// _CategoryLoadingIndicator
// ---------------------------------------------------------------------------

class _CategoryLoadingIndicator extends StatelessWidget {
  const _CategoryLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;
    return Center(child: CircularProgressIndicator(color: themeExt.primary));
  }
}

// ---------------------------------------------------------------------------
// _CategoryErrorView
// ---------------------------------------------------------------------------

class _CategoryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CategoryErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: themeExt.error,
            size: 48,
          ),
          const SizedBox(height: AppDimensions.stackMd),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: themeExt.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.stackMd),
          AppButton.filled(onPressed: onRetry, text: 'Retry'),
        ],
      ),
    );
  }
}
