import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_state.dart';

/// OTP code entry form component extracted as a dedicated Stateless widget.
class OtpForm extends StatelessWidget {
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final String? otpError;
  final int secondsRemaining;
  final bool canResend;
  final ValueChanged<String> onOtpCompleted;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onResendCode;
  final AuthState state;

  const OtpForm({
    super.key,
    required this.otpController,
    required this.otpFocusNode,
    required this.otpError,
    required this.secondsRemaining,
    required this.canResend,
    required this.onOtpCompleted,
    required this.onOtpChanged,
    required this.onResendCode,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;

    return Column(
      key: const ValueKey('otp_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pinput(
          length: 6,
          controller: otpController,
          focusNode: otpFocusNode,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onCompleted: onOtpCompleted,
          onChanged: onOtpChanged,
          forceErrorState: otpError != null,
          defaultPinTheme: PinTheme(
            width: 48,
            height: 56,
            textStyle: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: themeExt.onSurface,
            ),
            decoration: BoxDecoration(
              color: themeExt.surfaceContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
              border: Border.all(color: themeExt.outlineVariant),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 48,
            height: 56,
            textStyle: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: themeExt.onSurface,
            ),
            decoration: BoxDecoration(
              color: themeExt.surfaceContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
              border: Border.all(color: themeExt.primary, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: themeExt.primary.withValues(alpha: 0.15),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
          ),
          errorPinTheme: PinTheme(
            width: 48,
            height: 56,
            textStyle: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: themeExt.onSurface,
            ),
            decoration: BoxDecoration(
              color: themeExt.surfaceContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
              border: Border.all(color: themeExt.error, width: 1.0),
            ),
          ),
        ),

        if (otpError != null) ...[
          const SizedBox(height: 12),
          Text(
            otpError!,
            style: GoogleFonts.inter(
              color: themeExt.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: AppDimensions.stackLg),

        // Resend section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: GoogleFonts.inter(
                color: themeExt.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            if (state is AuthLoading && (state as AuthLoading).isResending)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(themeExt.primary),
                ),
              )
            else if (canResend)
              GestureDetector(
                onTap: onResendCode,
                child: Text(
                  'Resend Code',
                  style: GoogleFonts.inter(
                    color: themeExt.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              )
            else
              Text(
                'Resend in ${secondsRemaining}s',
                style: GoogleFonts.inter(
                  color: themeExt.onSurfaceVariant.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
