import 'package:spend_sum/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:spend_sum/features/onboarding/domain/repository/i_onboarding_repository.dart';

class OnboardingRepository implements IOnboardingRepository {
  final IOnboardingLocalDataSource localDataSource;

  OnboardingRepository({required this.localDataSource});

  @override
  bool get isOnboardingCompleted => localDataSource.isOnboardingCompleted;

  @override
  Future<void> completeOnboarding() async {
    await localDataSource.completeOnboarding();
  }
}
