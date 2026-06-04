import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/entities/auth_response.dart';

/// Domain Layer repository contract for authentication operations.
abstract interface class IAuthRepository {
  /// Requests a 6-digit confirmation code for the formatted phone number.
  Future<Either<AppFailure, Unit>> sendOtp(String phoneNumber);

  /// Submits the 6-digit confirmation code to verify the mobile number.
  Future<Either<AppFailure, AuthResponse>> verifyOtp({
    required String phoneNumber,
    required String verificationCode,
  });

  /// Completes profile registration details for new users.
  Future<Either<AppFailure, Unit>> registerUser({
    required String uid,
    required String name,
    DateTime? dob,
    String? gender,
    String? email,
  });

  /// Saves the initial budget details survey.
  Future<Either<AppFailure, Unit>> submitBudgetDetails({
    required String uid,
    required double amount,
    required String period,
  });

  /// Updates profile details for existing users.
  Future<Either<AppFailure, Unit>> updateProfile({
    required String uid,
    required String name,
    DateTime? dob,
    String? gender,
    String? email,
    String? currency,
  });

  /// Retrieves the active logged-in user profile, if any.
  Future<Either<AppFailure, User?>> getActiveUser();

  /// Retrieves a specific user profile by their UID.
  Future<Either<AppFailure, User?>> getUser(String uid);

  /// Logs the active user out and clears session state.
  Future<Either<AppFailure, Unit>> logout();
}
