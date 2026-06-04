import 'package:flutter/foundation.dart';

/// Represents all possible states of the authentication flow.
@immutable
sealed class AuthState {
  const AuthState();
}

/// Initial state - mobile input form is displayed.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - active OTP request or verification is running.
class AuthLoading extends AuthState {
  final bool isResending;

  const AuthLoading({this.isResending = false});
}

/// OTP request succeeded - OTP code input form is displayed.
class AuthOtpSent extends AuthState {
  final String formattedPhone;

  const AuthOtpSent(this.formattedPhone);
}

/// Auth complete success with user session meta details.
class AuthSuccess extends AuthState {
  final String uid;
  final bool isNew;
  final bool isBudgetCompleted;

  const AuthSuccess({
    required this.uid,
    required this.isNew,
    required this.isBudgetCompleted,
  });
}

/// Authentication failed.
class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);
}
