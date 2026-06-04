import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/widget/app_button.dart';
import 'package:spend_sum/core/common/widget/app_scaffold.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/add_category_usecase.dart';

/// Full-page form for creating a new custom category.
class AddCategoryPage extends StatefulWidget {
  /// Whether to create an expense category. If false, creates an income category.
  final bool isExpense;

  const AddCategoryPage({super.key, this.isExpense = true});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;
  bool _isExpense = true;

  // Default icon: Dollar
  IconData _selectedIcon = Icons.attach_money_rounded;
  Color _selectedColor = const Color(0xFF5856D6);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Available icon options for selection
  static const List<_IconOption> _iconOptions = [
    _IconOption(icon: Icons.attach_money_rounded, label: 'Dollar'),
    _IconOption(icon: Icons.shopping_basket_rounded, label: 'Groceries'),
    _IconOption(icon: Icons.restaurant_rounded, label: 'Food'),
    _IconOption(icon: Icons.directions_car_rounded, label: 'Car'),
    _IconOption(icon: Icons.home_rounded, label: 'Home'),
    _IconOption(icon: Icons.school_rounded, label: 'Education'),
    _IconOption(icon: Icons.fitness_center_rounded, label: 'Gym'),
    _IconOption(icon: Icons.medical_services_rounded, label: 'Health'),
    _IconOption(icon: Icons.shopping_bag_rounded, label: 'Shopping'),
    _IconOption(icon: Icons.airplanemode_active_rounded, label: 'Travel'),
    _IconOption(icon: Icons.wifi_rounded, label: 'Internet'),
    _IconOption(icon: Icons.receipt_long_rounded, label: 'Bills'),
    _IconOption(icon: Icons.savings_rounded, label: 'Savings'),
    _IconOption(icon: Icons.work_rounded, label: 'Work'),
    _IconOption(icon: Icons.trending_up_rounded, label: 'Investments'),
    _IconOption(icon: Icons.card_giftcard_rounded, label: 'Gifts'),
    _IconOption(icon: Icons.campaign_rounded, label: 'Marketing'),
    _IconOption(icon: Icons.beach_access_rounded, label: 'Vacation'),
    _IconOption(icon: Icons.local_play_rounded, label: 'Entertainment'),
    _IconOption(icon: Icons.water_drop_rounded, label: 'Water'),
    _IconOption(icon: Icons.key_rounded, label: 'Rent'),
    _IconOption(icon: Icons.shield_rounded, label: 'Insurance'),
    _IconOption(icon: Icons.notifications_rounded, label: 'Subscription'),
    _IconOption(icon: Icons.payments_rounded, label: 'Payments'),
  ];

  // Available color options for selection
  static const List<Color> _colorOptions = [
    Color(0xFF5856D6),
    Color(0xFF4CD964),
    Color(0xFF5AC8FA),
    Color(0xFF007AFF),
    Color(0xFFFF9500),
    Color(0xFFFF2D55),
    Color(0xFFFF3B30),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFFAF52DE),
    Color(0xFFFF6482),
    Color(0xFF30B0C7),
  ];

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleType(bool isExpense) {
    if (_isExpense == isExpense) return;
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _isExpense = isExpense;
    });
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final addCategoryUseCase = sl<AddCategoryUseCase>();
    final result = await addCategoryUseCase(AddCategoryParams(
      name: _nameController.text.trim(),
      icon: _selectedIcon.codePoint.toRadixString(16),
      color: '0x${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
      isExpense: _isExpense,
    ));

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save category: ${failure.message}'),
              backgroundColor: const Color(0xFFFF2D55),
            ),
          );
        },
        (_) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Category created successfully!',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF4CD964),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;

    return AppScaffold(
      title: 'New Category',
      useScrollView: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.marginPage,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.stackMd),

                // Type Toggle (Expense / Income)
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeTab(
                        label: 'Expense',
                        isSelected: _isExpense,
                        onTap: () => _toggleType(true),
                        themeExt: themeExt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeTab(
                        label: 'Income',
                        isSelected: !_isExpense,
                        onTap: () => _toggleType(false),
                        themeExt: themeExt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.stackLg),

                // Preview Card
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _selectedColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      border: Border.all(
                        color: _selectedColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _selectedIcon,
                        color: _selectedColor,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.stackLg),

                // Category Name
                Text(
                  'Category Name',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeExt.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.stackSm),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.inter(color: themeExt.onSurface),
                  decoration: InputDecoration(
                    hintText: 'e.g. Transport, Dividends, Utilities',
                    hintStyle: TextStyle(
                      color: themeExt.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: themeExt.surfaceContainer,
                    prefixIcon: Icon(
                      Icons.label_outline_rounded,
                      color: themeExt.onSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusDefault,
                      ),
                      borderSide: BorderSide(color: themeExt.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusDefault,
                      ),
                      borderSide: BorderSide(color: themeExt.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusDefault,
                      ),
                      borderSide: BorderSide(
                        color: themeExt.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.stackLg),

                // Icon Selector
                Text(
                  'Choose Icon',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeExt.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.stackSm),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: AppDimensions.stackSm,
                    crossAxisSpacing: AppDimensions.stackSm,
                  ),
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final option = _iconOptions[index];
                    final isSelected =
                        _selectedIcon == option.icon;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedIcon = option.icon;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.15)
                              : themeExt.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusDefault,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : themeExt.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            option.icon,
                            color: isSelected
                                ? _selectedColor
                                : themeExt.onSurfaceVariant,
                            size: 22,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.stackLg),

                // Color Selector
                Text(
                  'Choose Color',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeExt.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.stackSm),
                Wrap(
                  spacing: AppDimensions.stackSm,
                  runSpacing: AppDimensions.stackSm,
                  children: _colorOptions.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? themeExt.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppDimensions.stackXl),

                // Save Button
                AppButton.filled(
                  onPressed: _isSaving ? null : _saveCategory,
                  loading: _isSaving,
                  child: Text(
                    'Create Category',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.stackXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeExtension themeExt,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? themeExt.primary : themeExt.surfaceContainer,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeExt.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : themeExt.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper class for icon options in the grid.
class _IconOption {
  final IconData icon;
  final String label;

  const _IconOption({required this.icon, required this.label});
}
