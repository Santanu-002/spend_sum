import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';

class GetActiveUserUseCase implements BaseUseCase<User?, NoParams> {
  final IAuthRepository repository;

  GetActiveUserUseCase(this.repository);

  @override
  Future<Either<AppFailure, User?>> call(NoParams params) async {
    return await repository.getActiveUser();
  }
}
