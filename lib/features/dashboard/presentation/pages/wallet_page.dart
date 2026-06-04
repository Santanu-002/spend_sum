import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/core/common/widget/app_button.dart';
import 'package:spend_sum/core/common/widget/app_scaffold.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';

class WalletPage extends StatefulWidget {
  final double initialBudget;

  const WalletPage({super.key, required this.initialBudget});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
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
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not logged in')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final repository = sl<IHomeRepository>();
    final result = await repository.updateBudget(userState.user.uid, amount);

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update budget: ${failure.message}'),
              backgroundColor: const Color(0xFFFF2D55),
            ),
          );
        },
        (_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Budget updated successfully!',
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

    return AppScaffold(
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
            style: GoogleFonts.inter(
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
              style: GoogleFonts.inter(
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
                    textStyle: GoogleFonts.inter(
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
                    textStyle: GoogleFonts.inter(
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
                    textStyle: GoogleFonts.inter(
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
                    textStyle: GoogleFonts.inter(
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
                    textStyle: GoogleFonts.inter(
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
                    textStyle: GoogleFonts.inter(
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
    );
  }
}
