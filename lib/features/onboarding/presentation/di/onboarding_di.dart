import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:spend_sum/features/onboarding/data/repository/onboarding_repository.dart';
import 'package:spend_sum/features/onboarding/domain/repository/i_onboarding_repository.dart';
import 'package:spend_sum/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:spend_sum/features/onboarding/domain/usecases/is_onboarding_completed_usecase.dart';

/// Initializes dependency injection for the Onboarding feature module.
void initOnboardingDependencies() {
  // Data Sources
  sl.registerLazySingleton<IOnboardingLocalDataSource>(
    () => OnboardingLocalDataSource(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<IOnboardingRepository>(
    () => OnboardingRepository(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));
  sl.registerLazySingleton(() => IsOnboardingCompletedUseCase(sl()));
}
