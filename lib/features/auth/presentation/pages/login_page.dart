import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/widget/app_button.dart';
import 'package:spend_sum/core/common/widget/app_scaffold.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_event.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_state.dart';
import 'package:spend_sum/features/auth/presentation/widgets/phone_form.dart';
import 'package:spend_sum/features/auth/presentation/widgets/otp_form.dart';

/// Authentication Screen presenting mobile OTP flow.
/// Powered by AuthBloc for clean separation of concerns and logic.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: const _LoginPageContent(),
    );
  }
}

class _LoginPageContent extends StatefulWidget {
  const _LoginPageContent();

  @override
  State<_LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<_LoginPageContent> {
  // Navigation flow state: false = Enter Mobile, true = Enter OTP
  bool _isOtpStep = false;

  // Mobile number step controllers & focus
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  String? _phoneError;

  // Selected Country Code
  final List<CountryCode> _countries = const [
    CountryCode(code: '+91', flag: '🇮🇳', name: 'India', maxLength: 10),
    CountryCode(code: '+1', flag: '🇺🇸', name: 'United States', maxLength: 10),
    CountryCode(
      code: '+44',
      flag: '🇬🇧',
      name: 'United Kingdom',
      maxLength: 10,
    ),
    CountryCode(code: '+65', flag: '🇸🇬', name: 'Singapore', maxLength: 8),
    CountryCode(code: '+61', flag: '🇦🇺', name: 'Australia', maxLength: 9),
  ];
  late CountryCode _selectedCountry;

  // OTP step controllers & focus
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String? _otpError;

  // Countdown timer for Resend OTP
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.first;
    _phoneFocusNode.addListener(_onFocusChange);
    _otpFocusNode.addListener(_onFocusChange);
    _phoneFocusNode.requestFocus();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_onFocusChange);
    _otpFocusNode.removeListener(_onFocusChange);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _validateAndSendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Mobile number cannot be empty';
      });
      return;
    }
    // Enforce dynamic length check based on selected country
    if (phone.length != _selectedCountry.maxLength) {
      setState(() {
        _phoneError =
            'Mobile number must be exactly ${_selectedCountry.maxLength} digits';
      });
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      setState(() {
        _phoneError = 'Please enter a valid mobile number';
      });
      return;
    }

    setState(() {
      _phoneError = null;
    });

    // Prepend number with country code while passing
    final fullPhoneNumber = '${_selectedCountry.code}$phone';
    debugPrint(
      'Passing validated phone number to backend/OTP service: $fullPhoneNumber',
    );

    context.read<AuthBloc>().add(AuthSendOtpRequested(fullPhoneNumber));
  }

  void _verifyOtp() {
    final otp = _otpController.text;
    if (otp.length < 6) {
      setState(() {
        _otpError = 'Verification code must be 6 digits';
      });
      return;
    }

    setState(() {
      _otpError = null;
    });

    final phone = _phoneController.text.trim();
    final fullPhoneNumber = '${_selectedCountry.code}$phone';
    context.read<AuthBloc>().add(
      AuthVerifyOtpRequested(
        phoneNumber: fullPhoneNumber,
        verificationCode: otp,
      ),
    );
  }

  void _resendCode() {
    if (!_canResend) return;
    _otpController.clear();
    setState(() {
      _otpError = null;
    });

    final phone = _phoneController.text.trim();
    final fullPhoneNumber = '${_selectedCountry.code}$phone';
    context.read<AuthBloc>().add(AuthSendOtpRequested(fullPhoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;
    final textThemeExt = theme.extension<AppTextThemeExtension>()!;

    return AppScaffold(
      useScrollView: true,
      resizeToAvoidBottomInset: true,
      onBackPressed: _isOtpStep
          ? () => context.read<AuthBloc>().add(const AuthResetRequested())
          : null,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            if (_isOtpStep) {
              // Code was resent successfully
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Verification code resent successfully',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusDefault,
                    ),
                  ),
                  backgroundColor: themeExt.primaryContainer,
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            setState(() {
              _isOtpStep = true;
            });

            // Auto-focus OTP input in next frame and start countdown timer
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _otpFocusNode.requestFocus();
              _startTimer();
            });
          } else if (state is AuthSuccess) {
            context.read<UserCubit>().loadUserProfile(state.uid);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      state.isNew
                          ? 'OTP Verified! Please register.'
                          : 'Welcome back! Login Successful.',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusDefault,
                  ),
                ),
                backgroundColor: themeExt.secondaryContainer,
              ),
            );

            // Perform routing decisions based on user status
            if (state.isNew) {
              context.go(AppRoutes.auth.registration.path, extra: state.uid);
            } else if (!state.isBudgetCompleted) {
              context.go(
                AppRoutes.auth.expenseDetailsSurvey.path,
                extra: state.uid,
              );
            } else {
              context.go(AppRoutes.dashboard.path);
            }
          } else if (state is AuthFailure) {
            if (_isOtpStep) {
              setState(() {
                _otpError = state.error;
              });
            } else {
              setState(() {
                _phoneError = state.error;
              });
            }
          } else if (state is AuthInitial) {
            _timer?.cancel();
            setState(() {
              _isOtpStep = false;
              _otpController.clear();
              _otpError = null;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _phoneFocusNode.requestFocus();
            });
          }
        },
        builder: (context, state) {
          final isAnyLoading = state is AuthLoading;
          final isVerificationLoading =
              state is AuthLoading && !state.isResending;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.stackMd),

              // Animated step switcher for headers
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey<bool>(_isOtpStep),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isOtpStep ? 'Verify Mobile' : 'Let\'s get started',
                        style: textThemeExt.headlineLgMobile.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: themeExt.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.stackSm),
                      Text(
                        _isOtpStep
                            ? 'Enter the 6-digit confirmation code we sent to\n${_selectedCountry.code} ${_phoneController.text}'
                            : 'Enter your mobile number to sign in or create a new account in seconds.',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: themeExt.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.stackXl),

              // Inputs Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isOtpStep
                    ? OtpForm(
                        otpController: _otpController,
                        otpFocusNode: _otpFocusNode,
                        otpError: _otpError,
                        secondsRemaining: _secondsRemaining,
                        canResend: _canResend,
                        onOtpCompleted: (pin) => _verifyOtp(),
                        onOtpChanged: (value) {
                          if (_otpError != null) {
                            setState(() {
                              _otpError = null;
                            });
                          }
                        },
                        onResendCode: _resendCode,
                        state: state,
                      )
                    : PhoneForm(
                        selectedCountry: _selectedCountry,
                        phoneController: _phoneController,
                        phoneFocusNode: _phoneFocusNode,
                        phoneError: _phoneError,
                        countries: _countries,
                        onCountryChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCountry = newValue;
                              if (_phoneController.text.length >
                                  newValue.maxLength) {
                                _phoneController.text = _phoneController.text
                                    .substring(0, newValue.maxLength);
                                _phoneController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: _phoneController.text.length,
                                      ),
                                    );
                              }
                            });
                          }
                        },
                        onPhoneChanged: (value) {
                          if (_phoneError != null) {
                            setState(() {
                              _phoneError = null;
                            });
                          }
                        },
                        onSubmitted: _validateAndSendOtp,
                      ),
              ),

              const SizedBox(height: AppDimensions.stackLg),

              // Action Button
              AppButton.filled(
                onPressed: isAnyLoading
                    ? null
                    : (_isOtpStep ? _verifyOtp : _validateAndSendOtp),
                loading: isVerificationLoading,
                child: Text(
                  _isOtpStep ? 'Verify and Continue' : 'Send Verification Code',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.stackMd),

              // Terms & Conditions notice
              if (!_isOtpStep)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: themeExt.onSurfaceVariant,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: themeExt.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: themeExt.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
