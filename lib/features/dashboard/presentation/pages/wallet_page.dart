import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/common/widget/button/app_button.dart';
import 'package:spend_sum/core/common/widget/layout/app_scaffold.dart';
import 'package:spend_sum/core/common/widget/feedback/app_snackbar.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/budget_cubit.dart';

class WalletPage extends StatelessWidget {
  final double initialBudget;

  const WalletPage({super.key, required this.initialBudget});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BudgetCubit>(
      create: (context) => sl<BudgetCubit>(),
      child: _WalletPageContent(initialBudget: initialBudget),
    );
  }
}

class _WalletPageContent extends StatefulWidget {
  final double initialBudget;

  const _WalletPageContent({required this.initialBudget});

  @override
  State<_WalletPageContent> createState() => _WalletPageContentState();
}

class _WalletPageContentState extends State<_WalletPageContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _budgetController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: widget.initialBudget.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _adjustBudget(double offset) {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);

    final double currentVal = double.tryParse(_budgetController.text.trim()) ?? 0.0;
    final double newVal = (currentVal + offset).clamp(0.0, double.infinity);
    _budgetController.text = newVal.toStringAsFixed(2);
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? amount = double.tryParse(_budgetController.text.trim());
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.destructive(message: 'Please enter a valid budget amount'),
      );
      return;
    }

    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.destructive(message: 'User is not logged in'),
      );
      return;
    }

    context.read<BudgetCubit>().updateBudget(userState.user.uid, amount);
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;
    final userState = context.watch<UserCubit>().state;

    String currencySymbol = '\$';
    if (userState is UserLoggedIn) {
      currencySymbol = getUserCurrencySymbol(userState.user);
    }

    return BlocListener<BudgetCubit, BudgetState>(
      listener: (context, state) {
        if (state is BudgetLoading) {
          setState(() {
            _isSaving = true;
          });
        } else if (state is BudgetSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbar.success(
              message: 'Budget updated successfully!',
            ),
          );
        } else if (state is BudgetFailure) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbar.destructive(
              message: 'Failed to update budget: ${state.message}',
            ),
          );
        }
      },
      child: AppScaffold(
      title: 'Monthly Budget',
      useScrollView: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.marginPage,
        vertical: AppDimensions.stackMd,
      ),
      footer: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.stackMd),
        child: AppButton.filled(
          onPressed: _isSaving ? null : _saveBudget,
          loading: _isSaving,
          child: Text(
            'Save Budget Target',
            style: TextStyle(fontFamily: 'Inter', 
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppDimensions.stackSm),

            // Budget Input Block
            Text(
              'Target Limit Amount',
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeExt.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.stackSm),
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: TextStyle(fontFamily: 'Outfit', 
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
                    style: TextStyle(fontFamily: 'Outfit', 
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
                  return 'Budget amount is required';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.stackLg),

            // Quick adjustment grid
            Row(
              children: [
                Expanded(
                  child: AppButton.filled(
                    onPressed: () => _adjustBudget(-100),
                    height: 38,
                    padding: EdgeInsets.zero,
                    textStyle: TextStyle(fontFamily: 'Inter', 
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text('-${currencySymbol}100'),
                  ),
                ),
                const SizedBox(width: AppDimensions.stackMd),
                Expanded(
                  child: AppButton.filled(
                    onPressed: () => _adjustBudget(-500),
                    height: 38,
                    padding: EdgeInsets.zero,
                    textStyle: TextStyle(fontFamily: 'Inter', 
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text('-${currencySymbol}500'),
                  ),
                ),
                const SizedBox(width: AppDimensions.stackMd),
                Expanded(
                  child: AppButton.filled(
                    onPressed: () => _adjustBudget(-1000),
                    height: 38,
                    padding: EdgeInsets.zero,
                    textStyle: TextStyle(fontFamily: 'Inter', 
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text('-${currencySymbol}1000'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.stackMd),
            Row(
              children: [
                Expanded(
                  child: AppButton.filled(
                    onPressed: () => _adjustBudget(100),
                    height: 38,
                    padding: EdgeInsets.zero,
                    textStyle: TextStyle(fontFamily: 'Inter', 
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text('+${currencySymbol}100'),
                  ),
                ),
                const SizedBox(width: AppDimensions.stackMd),
                Expanded(
                  child: AppButton.filled(
                    onPressed: () => _adjustBudget(500),
                    height: 38,
                    padding: EdgeInsets.zero,
                    textStyle: TextStyle(fontFamily: 'Inter', 
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text('+${currencySymbol}500'),
                  ),
                ),
                const SizedBox(width: AppDimensions.stackMd),
                Expanded(
                  child: AppButton.filled(
                    onPressed: () => _adjustBudget(1000),
                    height: 38,
                    padding: EdgeInsets.zero,
                    textStyle: TextStyle(fontFamily: 'Inter', 
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Text('+${currencySymbol}1000'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}
