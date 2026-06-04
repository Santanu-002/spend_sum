import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/onboarding/domain/repository/i_onboarding_repository.dart';

class IsOnboardingCompletedUseCase implements BaseUseCase<bool, NoParams> {
  final IOnboardingRepository repository;

  IsOnboardingCompletedUseCase(this.repository);

  @override
  Future<Either<AppFailure, bool>> call(NoParams params) async {
    try {
      final isCompleted = repository.isOnboardingCompleted;
      return Right(isCompleted);
    } catch (e) {
      return Left(DatabaseFailure('Failed to check if onboarding is completed: ${e.toString()}'));
    }
  }
}
