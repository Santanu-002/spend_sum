import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/widget/button/app_button.dart';
import 'package:spend_sum/core/common/widget/layout/app_scaffold.dart';
import 'package:spend_sum/core/common/widget/feedback/app_snackbar.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:drift/drift.dart' show Value;
import 'package:spend_sum/features/dashboard/presentation/cubit/profile_cubit.dart';
import 'package:spend_sum/core/common/util/currency_util.dart';
import 'package:spend_sum/features/dashboard/presentation/widgets/components/currency_dropdown.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => sl<ProfileCubit>(),
      child: const _ProfileSettingsPageContent(),
    );
  }
}

class _ProfileSettingsPageContent extends StatefulWidget {
  const _ProfileSettingsPageContent();

  @override
  State<_ProfileSettingsPageContent> createState() => _ProfileSettingsPageContentState();
}

class _ProfileSettingsPageContentState extends State<_ProfileSettingsPageContent> {
  String? _selectedCurrency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoggedIn) {
      final user = userState.user;
      _selectedCurrency = user.currency;
    }
  }

  void _saveProfile() {
    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.destructive(
          message: 'User session not active.',
        ),
      );
      return;
    }

    final currentUser = userState.user;

    context.read<ProfileCubit>().updateProfile(
      uid: currentUser.uid,
      name: currentUser.name ?? '',
      dob: currentUser.dob,
      gender: currentUser.gender,
      email: currentUser.email,
      currency: _selectedCurrency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;
    final textThemeExt = theme.textThemeExt;
    final userState = context.watch<UserCubit>().state;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is ProfileSuccess) {
          if (userState is UserLoggedIn) {
            final currentUser = userState.user;
            final updatedUser = currentUser.copyWith(
              currency: Value(_selectedCurrency),
            );
            context.read<UserCubit>().updateUserState(updatedUser);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbar.success(
              message: 'Settings updated successfully!',
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfileFailure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbar.destructive(
              message: 'Failed to update settings: ${state.message}',
            ),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          useScrollView: true,
          resizeToAvoidBottomInset: true,
          title: 'Account Settings',
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.stackMd),
              Text(
                'Currency Preferences',
                style: textThemeExt.headlineLgMobile.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: themeExt.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppDimensions.stackSm),
              Text(
                'Choose your default currency used for wallet balances, budgets, and transactions.',
                style: TextStyle(fontFamily: 'Inter', 
                  fontSize: 14,
                  color: themeExt.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.stackXl),

              CurrencyDropdownField(
                value: _selectedCurrency,
                defaultSymbol: userState is UserLoggedIn
                    ? getCurrencySymbol(userState.user.phoneNumber)
                    : '\$',
                currencies: context.read<ProfileCubit>().getAvailableCurrencies(),
                enabled: !_isLoading,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  SystemSound.play(SystemSoundType.click);
                  setState(() {
                    _selectedCurrency = value;
                  });
                },
              ),

              const SizedBox(height: AppDimensions.stackXl),

              // Save Changes button
              AppButton.filled(
                onPressed: _isLoading ? null : _saveProfile,
                loading: _isLoading,
                child: Text(
                  'Save Changes',
                  style: TextStyle(fontFamily: 'Inter', 
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
    );
  }
}
