import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/widget/button/app_button.dart';
import 'package:spend_sum/core/common/widget/layout/app_scaffold.dart';
import 'package:spend_sum/core/common/widget/feedback/app_snackbar.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_event.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_state.dart';

/// Screen collecting initial budget details (amount & period) as a survey.
class ExpenseDetailsSurveyPage extends StatelessWidget {
  final String uid;

  const ExpenseDetailsSurveyPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: _ExpenseDetailsSurveyPageContent(uid: uid),
    );
  }
}

class _ExpenseDetailsSurveyPageContent extends StatefulWidget {
  final String uid;

  const _ExpenseDetailsSurveyPageContent({required this.uid});

  @override
  State<_ExpenseDetailsSurveyPageContent> createState() =>
      _ExpenseDetailsSurveyPageContentState();
}

class _ExpenseDetailsSurveyPageContentState
    extends State<_ExpenseDetailsSurveyPageContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userCubit = context.read<UserCubit>();
    if (userCubit.state is! UserLoggedIn) {
      userCubit.loadUserProfile(widget.uid);
    }
  }

  String _selectedPeriod = 'monthly';
  final List<Map<String, String>> _periods = const [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitBudget() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.destructive(message: 'Please enter a valid budget amount'),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthSubmitBudgetRequested(
        uid: widget.uid,
        amount: amount,
        period: _selectedPeriod,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;
    final textThemeExt = context.textThemeExt;
    final userState = context.watch<UserCubit>().state;

    String currencySymbol = '\$';
    if (userState is UserLoggedIn) {
      currencySymbol = getUserCurrencySymbol(userState.user);
    }

    return AppScaffold(
      useScrollView: true,
      resizeToAvoidBottomInset: true,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.read<UserCubit>().loadUserProfile(widget.uid);

            ScaffoldMessenger.of(context).showSnackBar(
              AppSnackbar.success(message: 'Budget set successfully!'),
            );
            // Redirect direct to dashboard
            context.go(AppRoutes.dashboard.path);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              AppSnackbar.destructive(message: state.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.stackMd),
                Text(
                  'Set Your Budget',
                  style: textThemeExt.headlineLgMobile.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: themeExt.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.stackSm),
                Text(
                  'Set your budget survey limit to track your spending and calculate your total savings later.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: themeExt.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppDimensions.stackXl),

                // Budget Amount Input
                Text.rich(
                  TextSpan(
                    text: 'Budget Amount ',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeExt.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: themeExt.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  enabled: !isLoading,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
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
                      borderSide: BorderSide(
                        color: themeExt.primary,
                        width: 2,
                      ),
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
                const SizedBox(height: AppDimensions.stackLg),

                // Budget Frequency (Period) Selection
                Text.rich(
                  TextSpan(
                    text: 'Budget Period ',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeExt.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: '*',
                        style: TextStyle(
                          color: themeExt.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: themeExt.surfaceContainer,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusDefault,
                    ),
                    border: Border.all(color: themeExt.outlineVariant),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: themeExt.onSurfaceVariant,
                      ),
                      dropdownColor: themeExt.surfaceContainerHigh,
                      style: GoogleFonts.inter(
                        color: themeExt.onSurface,
                        fontSize: 16,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusDefault,
                      ),
                      items: _periods.map((period) {
                        return DropdownMenuItem<String>(
                          value: period['value'],
                          child: Text(period['label']!),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                HapticFeedback.lightImpact();
                                SystemSound.play(SystemSoundType.click);
                                setState(() {
                                  _selectedPeriod = value;
                                });
                              }
                            },
                      isExpanded: true,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.stackXl),

                // Submit budget button
                AppButton.filled(
                  onPressed: isLoading ? null : _submitBudget,
                  loading: isLoading,
                  child: Text(
                    'Save and Continue',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.stackMd),
              ],
            ),
          );
        },
      ),
    );
  }
}
