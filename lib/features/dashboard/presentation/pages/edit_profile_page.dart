import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/widget/button/app_button.dart';
import 'package:spend_sum/core/common/widget/layout/app_scaffold.dart';
import 'package:spend_sum/core/common/widget/feedback/app_snackbar.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:drift/drift.dart' show Value;
import 'package:spend_sum/features/dashboard/presentation/cubit/profile_cubit.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => sl<ProfileCubit>(),
      child: const _EditProfilePageContent(),
    );
  }
}

class _EditProfilePageContent extends StatefulWidget {
  const _EditProfilePageContent();

  @override
  State<_EditProfilePageContent> createState() => _EditProfilePageContentState();
}

class _EditProfilePageContentState extends State<_EditProfilePageContent> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  bool _dobHasError = false;
  bool _isLoading = false;

  final List<String> _genders = const ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoggedIn) {
      final user = userState.user;
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _selectedDateOfBirth = user.dob;
      if (user.dob != null) {
        _dobController.text = _formatDate(user.dob!);
      }
      _selectedGender = user.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _selectDateOfBirth() async {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
    final today = DateTime.now();
    final firstDate = DateTime(today.year - 100, today.month, today.day);
    final lastDate = DateTime(today.year - 12, today.month, today.day);
    final initialDate = _selectedDateOfBirth ?? lastDate;

    final theme = context.theme;
    final themeExt = theme.colorscheme;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: themeExt.primary,
              onPrimary: themeExt.onPrimary,
              surface: themeExt.surfaceContainerHigh,
              onSurface: themeExt.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
        _dobController.text = _formatDate(pickedDate);
        _dobHasError = false;
      });
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      if (_selectedDateOfBirth == null) {
        setState(() {
          _dobHasError = true;
        });
      }
      return;
    }

    if (_selectedDateOfBirth == null) {
      setState(() {
        _dobHasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.destructive(
          message: 'Please select your date of birth',
        ),
      );
      return;
    }

    setState(() {
      _dobHasError = false;
    });

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
      name: _nameController.text.trim(),
      dob: _selectedDateOfBirth,
      gender: _selectedGender,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      currency: currentUser.currency,
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
              name: Value(_nameController.text.trim()),
              dob: Value(_selectedDateOfBirth),
              gender: Value(_selectedGender),
              email: Value(_emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim()),
            );
            context.read<UserCubit>().updateUserState(updatedUser);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbar.success(
              message: 'Profile updated successfully!',
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfileFailure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbar.destructive(
              message: 'Failed to update profile: ${state.message}',
            ),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          useScrollView: true,
          resizeToAvoidBottomInset: true,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.stackMd),
                  Text(
                    'Update Your Details',
                    style: textThemeExt.headlineLgMobile.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: themeExt.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackSm),
                  Text(
                    'Modify your account name, email address, date of birth, and gender preferences.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: themeExt.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackXl),

                  // Name Input (Required)
                  Text.rich(
                    TextSpan(
                      text: 'Full Name ',
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
                    controller: _nameController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    style: GoogleFonts.inter(color: themeExt.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Enter full name',
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
                        borderSide: BorderSide(
                          color: themeExt.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.stackLg),

                  // Email Input (Optional)
                  Text(
                    'Email Address (Optional)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeExt.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9@._\-\+]'),
                      ),
                    ],
                    onFieldSubmitted: (_) => _saveProfile(),
                    style: GoogleFonts.inter(color: themeExt.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Enter email address',
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
                        borderSide: BorderSide(
                          color: themeExt.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.stackLg),

                  // Row for Date of Birth & Gender Selection
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date of Birth Choice
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Date of Birth ',
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
                            InkWell(
                              onTap: _isLoading ? null : _selectDateOfBirth,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusDefault,
                              ),
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  color: themeExt.surfaceContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusDefault,
                                  ),
                                  border: Border.all(
                                    color: _dobHasError
                                        ? theme.colorScheme.error
                                        : themeExt.outlineVariant,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      color: _dobHasError
                                          ? theme.colorScheme.error
                                          : themeExt.onSurfaceVariant,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _selectedDateOfBirth == null
                                            ? 'DD/MM/YYYY'
                                            : _formatDate(_selectedDateOfBirth!),
                                        style: GoogleFonts.inter(
                                          color: _selectedDateOfBirth == null
                                              ? themeExt.onSurfaceVariant
                                                  .withValues(alpha: 0.5)
                                              : themeExt.onSurface,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_dobHasError) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Date of birth is required',
                                style: GoogleFonts.inter(
                                  color: theme.colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Gender Dropdown Selection (Optional)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Gender (Optional)',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: themeExt.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: themeExt.surfaceContainer,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusDefault,
                                ),
                                border: Border.all(
                                  color: themeExt.outlineVariant,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedGender,
                                  hint: Text(
                                    'Select',
                                    style: TextStyle(
                                      color: themeExt.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: themeExt.onSurfaceVariant,
                                  ),
                                  dropdownColor: themeExt.surfaceContainerHigh,
                                  style: GoogleFonts.inter(
                                    color: themeExt.onSurface,
                                    fontSize: 15,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusDefault,
                                  ),
                                  items: _genders.map((gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                          HapticFeedback.lightImpact();
                                          SystemSound.play(
                                            SystemSoundType.click,
                                          );
                                          setState(() {
                                            _selectedGender = value;
                                          });
                                        },
                                  isExpanded: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.stackXl),

                  // Save Changes button
                  AppButton.filled(
                    onPressed: _isLoading ? null : _saveProfile,
                    loading: _isLoading,
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackMd),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
