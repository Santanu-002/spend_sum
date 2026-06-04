import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';

/// Parameter arguments required to execute UpdateProfile UseCase.
class UpdateProfileParams {
  final String uid;
  final String name;
  final DateTime? dob;
  final String? gender;
  final String? email;
  final String? currency;

  const UpdateProfileParams({
    required this.uid,
    required this.name,
    this.dob,
    this.gender,
    this.email,
    this.currency,
  });
}

/// UseCase to update user profile.
class UpdateProfile implements BaseUseCase<Unit, UpdateProfileParams> {
  final IAuthRepository repository;

  const UpdateProfile(this.repository);

  @override
  Future<Either<AppFailure, Unit>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      uid: params.uid,
      name: params.name,
      dob: params.dob,
      gender: params.gender,
      email: params.email,
      currency: params.currency,
    );
  }
}
