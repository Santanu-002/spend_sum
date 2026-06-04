import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/common/widget/app_button.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/select_category_sheet.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  const AddExpenseBottomSheet({super.key});

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCategory = 'Groceries';
  IconData _selectedCategoryIcon = Icons.shopping_basket_rounded;
  Color _selectedCategoryColor = const Color(0xFF4CD964);
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;
  bool _isExpense = true;

  void _toggleType(bool isExpense) {
    if (_isExpense == isExpense) return;
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
    setState(() {
      _isExpense = isExpense;
      if (isExpense) {
        _selectedCategory = 'Groceries';
        _selectedCategoryIcon = Icons.shopping_basket_rounded;
        _selectedCategoryColor = const Color(0xFF4CD964);
      } else {
        _selectedCategory = 'Salary';
        _selectedCategoryIcon = Icons.attach_money_rounded;
        _selectedCategoryColor = const Color(0xFF4CD964);
      }
    });
  }

  Future<void> _selectCategory() async {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectCategorySheet(isExpense: _isExpense),
    );

    if (selected != null) {
      setState(() {
        _selectedCategory = selected['name'];
        _selectedCategoryIcon = selected['icon'];
        _selectedCategoryColor = selected['color'];
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    setState(() {
      _isSaving = true;
    });

    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoggedIn) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }
    final userUid = userState.user.uid;

    final repository = sl<IHomeRepository>();
    final result = await repository.addExpense(
      userUid: userUid,
      title: _titleController.text.trim(),
      amount: amount,
      date: finalDateTime,
      category: _selectedCategory,
      isIncome: !_isExpense,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save ${_isExpense ? "expense" : "income"}: ${failure.message}'),
              backgroundColor: const Color(0xFFFF2D55),
            ),
          );
        },
        (_) {
          Navigator.pop(context); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    '${_isExpense ? "Expense" : "Income"} saved successfully!',
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
    final userState = context.watch<UserCubit>().state;

    String currencySymbol = '\$';
    if (userState is UserLoggedIn) {
      currencySymbol = getCurrencySymbol(userState.user.phoneNumber);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull Handle line
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
              const SizedBox(height: 20),

              // Title
              Text(
                _isExpense ? 'New Expense' : 'New Income',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: themeExt.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Tab Selector (Expense vs Income)
              Row(
                children: [
                  Expanded(
                    child: _buildTypeTab(
                      label: 'Expense',
                      isSelected: _isExpense,
                      onTap: () => _toggleType(true),
                      theme: theme,
                      themeExt: themeExt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeTab(
                      label: 'Income',
                      isSelected: !_isExpense,
                      onTap: () => _toggleType(false),
                      theme: theme,
                      themeExt: themeExt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeExt.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: themeExt.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 4.0),
                    child: Text(
                      currencySymbol,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeExt.primary,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  filled: false,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: themeExt.outlineVariant),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: themeExt.outlineVariant),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: themeExt.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Title / Label spent input
              Text(
                _isExpense ? 'Where did you spend?' : 'Where did you receive?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeExt.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.inter(color: themeExt.onSurface),
                decoration: InputDecoration(
                  hintText: _isExpense
                      ? 'e.g. Coffee, Groceries, Movie'
                      : 'e.g. Monthly Salary, Freelance, Gift',
                  hintStyle: TextStyle(
                    color: themeExt.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: themeExt.surfaceContainer,
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
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
                    borderSide: BorderSide(color: themeExt.primary, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Selector
              Text(
                'Category Tag',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeExt.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectCategory,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusDefault,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: themeExt.surfaceContainer,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusDefault,
                    ),
                    border: Border.all(color: themeExt.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _selectedCategoryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedCategoryIcon,
                          color: _selectedCategoryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedCategory,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeExt.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: themeExt.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Spent Time picker row
              Text(
                'Spent Date & Time',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeExt.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusDefault,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: themeExt.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusDefault,
                          ),
                          border: Border.all(color: themeExt.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: themeExt.onSurfaceVariant,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: GoogleFonts.inter(
                                color: themeExt.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusDefault,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: themeExt.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusDefault,
                          ),
                          border: Border.all(color: themeExt.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: themeExt.onSurfaceVariant,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _selectedTime.format(context),
                              style: GoogleFonts.inter(
                                color: themeExt.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes Spent text field
              Text(
                'Notes (Optional)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeExt.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.inter(color: themeExt.onSurface),
                decoration: InputDecoration(
                  hintText: 'Add additional details or remarks...',
                  hintStyle: TextStyle(
                    color: themeExt.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: themeExt.surfaceContainer,
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
                    borderSide: BorderSide(color: themeExt.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              AppButton.filled(
                onPressed: _isSaving ? null : _saveExpense,
                loading: _isSaving,
                child: Text(
                  _isExpense ? 'Save Expense' : 'Save Income',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required AppThemeExtension themeExt,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
