import 'package:flutter/foundation.dart';

/// Represents all user interactions that drive the authentication flow.
@immutable
sealed class AuthEvent {
  const AuthEvent();
}

/// Triggered when the user requests an OTP for a mobile number.
class AuthSendOtpRequested extends AuthEvent {
  final String formattedPhone;

  const AuthSendOtpRequested(this.formattedPhone);
}

/// Triggered when the user submits the 6-digit confirmation code.
class AuthVerifyOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String verificationCode;

  const AuthVerifyOtpRequested({
    required this.phoneNumber,
    required this.verificationCode,
  });
}

/// Triggered to submit registration profile details for new users.
class AuthRegisterRequested extends AuthEvent {
  final String uid;
  final String name;
  final DateTime? dob;
  final String? gender;
  final String? email;

  const AuthRegisterRequested({
    required this.uid,
    required this.name,
    this.dob,
    this.gender,
    this.email,
  });
}

/// Triggered to submit initial budget survey values.
class AuthSubmitBudgetRequested extends AuthEvent {
  final String uid;
  final double amount;
  final String period;

  const AuthSubmitBudgetRequested({
    required this.uid,
    required this.amount,
    required this.period,
  });
}

/// Resets the auth flow back to the mobile number input screen.
class AuthResetRequested extends AuthEvent {
  const AuthResetRequested();
}
