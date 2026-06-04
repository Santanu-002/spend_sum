import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/common/widget/button/app_button.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/widget/feedback/app_snackbar.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/transaction_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/components/type_toggle_tab.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/sheets/select_category_sheet.dart';

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
  Color _selectedCategoryColor = const Color(0xFF00B475);
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
        _selectedCategoryColor = const Color(0xFF00B475);
      } else {
        _selectedCategory = 'Salary';
        _selectedCategoryIcon = Icons.attach_money_rounded;
        _selectedCategoryColor = const Color(0xFF00B475);
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
        AppSnackbar.destructive(message: 'Please enter a valid amount'),
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

    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.destructive(message: 'User not logged in'),
      );
      return;
    }
    final userUid = userState.user.uid;

    context.read<TransactionCubit>().addTransaction(
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;
    final userState = context.watch<UserCubit>().state;

    String currencySymbol = '\$';
    if (userState is UserLoggedIn) {
      currencySymbol = getUserCurrencySymbol(userState.user);
    }

    return BlocProvider<TransactionCubit>(
      create: (context) => sl<TransactionCubit>(),
      child: BlocListener<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state is TransactionLoading) {
            setState(() {
              _isSaving = true;
            });
          } else if (state is TransactionSuccess) {
            Navigator.pop(context); // Close bottom sheet
            ScaffoldMessenger.of(context).showSnackBar(
              AppSnackbar.success(
                message: '${_isExpense ? "Expense" : "Income"} saved successfully!',
              ),
            );
          } else if (state is TransactionFailure) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              AppSnackbar.destructive(
                message: 'Failed to save ${_isExpense ? "expense" : "income"}: ${state.message}',
              ),
            );
          }
        },
        child: Builder(
          builder: (context) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: AppDimensions.cardPadLg,
                right: AppDimensions.cardPadLg,
                top: AppDimensions.cardPadLg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.stackLg,
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
              SizedBox(height: AppDimensions.cardPadLg),

              // Title
              Text(
                _isExpense ? 'New Expense' : 'New Income',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: themeExt.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDimensions.cardPadLg),

              // Tab Selector (Expense vs Income)
              Row(
                children: [
                  Expanded(
                    child: TypeToggleTab(
                      label: 'Expense',
                      isSelected: _isExpense,
                      onTap: () => _toggleType(true),
                    ),
                  ),
                  SizedBox(width: AppDimensions.tileHorizontalPad - 2),
                  Expanded(
                    child: TypeToggleTab(
                      label: 'Income',
                      isSelected: !_isExpense,
                      onTap: () => _toggleType(false),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.stackLg),

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
              SizedBox(height: AppDimensions.stackLg),

              // Title / Label spent input
              Text(
                _isExpense ? 'Where did you spend?' : 'Where did you receive?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeExt.onSurface,
                ),
              ),
              SizedBox(height: AppDimensions.stackSm),
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
                    horizontal: AppDimensions.cardPadMd,
                    vertical: AppDimensions.cardPadMd,
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
              SizedBox(height: AppDimensions.stackLg),

              // Category Selector
              Text(
                'Category Tag',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeExt.onSurface,
                ),
              ),
              SizedBox(height: AppDimensions.stackSm),
              InkWell(
                onTap: _selectCategory,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusDefault,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.cardPadMd,
                    vertical: AppDimensions.tileVerticalPad,
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
                      SizedBox(width: AppDimensions.tileHorizontalPad - 2),
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
              SizedBox(height: AppDimensions.stackLg),

              // Spent Time picker row
              Text(
                'Spent Date & Time',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeExt.onSurface,
                ),
              ),
              SizedBox(height: AppDimensions.stackSm),
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
                          horizontal: AppDimensions.cardPadMd,
                          vertical: AppDimensions.tileVerticalPad,
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
                  SizedBox(width: AppDimensions.tileHorizontalPad - 2),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusDefault,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.cardPadMd,
                          vertical: AppDimensions.tileVerticalPad,
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
              SizedBox(height: AppDimensions.stackLg),

              // Notes Spent text field
              Text(
                'Notes (Optional)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeExt.onSurface,
                ),
              ),
              SizedBox(height: AppDimensions.stackSm),
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
                    horizontal: AppDimensions.cardPadMd,
                    vertical: AppDimensions.cardPadMd,
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
              SizedBox(height: AppDimensions.radiusDefault + AppDimensions.stackMd),

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
  },
),
),
);
  }
}
