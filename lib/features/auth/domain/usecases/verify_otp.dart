import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/entities/auth_response.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';

/// Parameter object required to execute OTP Verification UseCase.
class VerifyOtpParams {
  final String phoneNumber;
  final String verificationCode;

  const VerifyOtpParams({
    required this.phoneNumber,
    required this.verificationCode,
  });
}

/// UseCase to verify the 6-digit confirmation code and log in or prepare the user.
class VerifyOtp implements BaseUseCase<AuthResponse, VerifyOtpParams> {
  final IAuthRepository repository;

  const VerifyOtp(this.repository);

  @override
  Future<Either<AppFailure, AuthResponse>> call(VerifyOtpParams params) {
    return repository.verifyOtp(
      phoneNumber: params.phoneNumber,
      verificationCode: params.verificationCode,
    );
  }
}
