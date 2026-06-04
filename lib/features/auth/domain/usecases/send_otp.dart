import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';

/// UseCase to request sending a 6-digit confirmation code.
class SendOtp implements BaseUseCase<Unit, String> {
  final IAuthRepository repository;

  const SendOtp(this.repository);

  @override
  Future<Either<AppFailure, Unit>> call(String phoneNumber) {
    return repository.sendOtp(phoneNumber);
  }
}
