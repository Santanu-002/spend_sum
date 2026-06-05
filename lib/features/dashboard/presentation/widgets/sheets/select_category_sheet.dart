import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/util/category_icon_util.dart';
import 'package:spend_sum/core/common/widget/button/app_back_button.dart';
import 'package:spend_sum/core/common/widget/button/app_button.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/category_cubit.dart';

part 'category_grid.dart';
part 'category_grid_item.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

class SelectCategorySheet extends StatelessWidget {
  final bool isExpense;
  const SelectCategorySheet({super.key, this.isExpense = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryCubit>(
      create: (context) => sl<CategoryCubit>()..loadCategories(isExpense: isExpense),
      child: _SelectCategorySheetContent(isExpense: isExpense),
    );
  }
}

// ---------------------------------------------------------------------------
// Content — owns data fetching, search state, and tap routing only
// ---------------------------------------------------------------------------

class _SelectCategorySheetContent extends StatefulWidget {
  final bool isExpense;
  const _SelectCategorySheetContent({required this.isExpense});

  @override
  State<_SelectCategorySheetContent> createState() => _SelectCategorySheetContentState();
}

class _SelectCategorySheetContentState extends State<_SelectCategorySheetContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _allCategories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  void _loadCategories() {
    context.read<CategoryCubit>().loadCategories(isExpense: widget.isExpense);
  }

  void _onCategoryTap(Map<String, dynamic> cat) {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);

    if (cat['isAddButton'] == true) {
      Navigator.pop(context);
      context.pushNamed(AppRoutes.addCategory.name, extra: widget.isExpense);
      return;
    }

    Navigator.pop(context, cat);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    final filteredCategories = _allCategories.where((cat) {
      if (cat['isAddButton'] == true) return true;
      return cat['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return BlocListener<CategoryCubit, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        } else if (state is CategoryLoaded) {
          final List<Map<String, dynamic>> loaded = [
            {
              'name': 'Add',
              'icon': Icons.add_rounded,
              'isAddButton': true,
            },
          ];

          for (final cat in state.categories) {
            final details = getCategoryDetails(cat.name);
            loaded.add({
              'name': cat.name,
              'icon': details.icon,
              'color': details.color,
              'isAddButton': false,
            });
          }

          setState(() {
            _allCategories = loaded;
            _isLoading = false;
          });
        } else if (state is CategoryFailure) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Container(
        height: context.height * 0.75,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusMd),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.marginPage,
          vertical: AppDimensions.marginPage,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Notch Line
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: themeExt.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.stackMd),

            // Header Row (Back Chevron + Title)
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Text(
                  'Select Category',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: themeExt.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Field
            TextFormField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: themeExt.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search for Categories',
                hintStyle: TextStyle(
                  color: themeExt.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: themeExt.onSurfaceVariant,
                ),
                filled: true,
                fillColor: themeExt.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: themeExt.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.stackLg),

            // Grid body (loading / error / grid)
            Expanded(
              child: _CategoryGridBody(
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                categories: filteredCategories,
                onRetry: _loadCategories,
                onCategoryTap: _onCategoryTap,
                isExpense: widget.isExpense,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
