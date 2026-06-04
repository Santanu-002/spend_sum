import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/common/util/category_icon_util.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/get_categories_usecase.dart';

class SelectCategorySheet extends StatefulWidget {
  final bool isExpense;
  const SelectCategorySheet({super.key, this.isExpense = true});

  @override
  State<SelectCategorySheet> createState() => _SelectCategorySheetState();
}

class _SelectCategorySheetState extends State<SelectCategorySheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _allCategories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getCategoriesUseCase = sl<GetCategoriesUseCase>();
      final result = await getCategoriesUseCase(GetCategoriesParams(isExpense: widget.isExpense));

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = failure.message;
            });
          }
        },
        (categoriesList) {
          if (mounted) {
            final List<Map<String, dynamic>> loaded = [
              {
                'name': 'Add',
                'icon': Icons.add_rounded,
                'color': const Color(0xFF6638E5),
                'isAddButton': true,
              },
            ];

            for (final cat in categoriesList) {
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
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    // Filter categories based on search query
    final filteredCategories = _allCategories.where((cat) {
      if (cat['isAddButton'] == true) return true; // Always show Add button
      return cat['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    SystemSound.play(SystemSoundType.click);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.stackSm),
                    decoration: BoxDecoration(
                      color: themeExt.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: themeExt.onSurface,
                      size: 24,
                    ),
                  ),
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
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: GoogleFonts.inter(color: themeExt.onSurface),
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

          // Grid View of Categories
          Expanded(
            child: _buildBody(theme, themeExt, filteredCategories),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    AppThemeExtension themeExt,
    List<Map<String, dynamic>> filteredCategories,
  ) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: themeExt.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: AppDimensions.stackMd),
            Text(
              _errorMessage ?? 'Failed to load categories',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: themeExt.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.stackMd),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeExt.primary,
                foregroundColor: themeExt.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppDimensions.gutterGrid,
        crossAxisSpacing: AppDimensions.gutterGrid,
        childAspectRatio: 0.78,
      ),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final cat = filteredCategories[index];
        final isAdd = cat['isAddButton'] == true;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            SystemSound.play(SystemSoundType.click);

            if (isAdd) {
              Navigator.pop(context); // close the sheet first
              context.pushNamed(
                AppRoutes.addCategory.name,
                extra: widget.isExpense,
              );
              return;
            }

            // Return the selected category data
            Navigator.pop(context, cat);
          },
          child: Column(
            children: [
              // Circular Icon Card
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusDefault,
                  ),
                  border: isAdd
                      ? Border.all(
                          color: themeExt.primary.withValues(
                            alpha: 0.4,
                          ),
                          style: BorderStyle.solid,
                          width: 1.5,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    cat['icon'],
                    color: cat['color'],
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.stackSm),
              // Label
              Text(
                cat['name'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: themeExt.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
