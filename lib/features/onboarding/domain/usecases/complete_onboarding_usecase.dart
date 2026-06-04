import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/onboarding/domain/repository/i_onboarding_repository.dart';

class CompleteOnboardingUseCase implements BaseUseCase<Unit, NoParams> {
  final IOnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  @override
  Future<Either<AppFailure, Unit>> call(NoParams params) async {
    try {
      await repository.completeOnboarding();
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to complete onboarding: ${e.toString()}'));
    }
  }
}
