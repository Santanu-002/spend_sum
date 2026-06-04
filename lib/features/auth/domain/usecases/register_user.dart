import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';

/// Parameter arguments required to execute RegisterUser UseCase.
class RegisterUserParams {
  final String uid;
  final String name;
  final DateTime? dob;
  final String? gender;
  final String? email;

  const RegisterUserParams({
    required this.uid,
    required this.name,
    this.dob,
    this.gender,
    this.email,
  });
}

/// UseCase to complete user profile registration.
class RegisterUser implements BaseUseCase<Unit, RegisterUserParams> {
  final IAuthRepository repository;

  const RegisterUser(this.repository);

  @override
  Future<Either<AppFailure, Unit>> call(RegisterUserParams params) {
    return repository.registerUser(
      uid: params.uid,
      name: params.name,
      dob: params.dob,
      gender: params.gender,
      email: params.email,
    );
  }
}
