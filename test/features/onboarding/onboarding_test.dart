import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:spend_sum/features/onboarding/data/repository/onboarding_repository.dart';
import 'package:spend_sum/features/onboarding/domain/repository/i_onboarding_repository.dart';
import 'package:spend_sum/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:spend_sum/features/onboarding/domain/usecases/is_onboarding_completed_usecase.dart';

class FakeOnboardingLocalDataSource implements IOnboardingLocalDataSource {
  bool _isOnboardingCompleted = false;

  @override
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  @override
  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
  }
}

class FakeOnboardingRepository implements IOnboardingRepository {
  bool _isOnboardingCompleted = false;

  @override
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  @override
  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
  }
}

void main() {
  // Required since SharedPreferences relies on platform channels.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Local Data Source', () {
    test('should return false by default when no value is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = OnboardingLocalDataSource(sharedPreferences: prefs);

      expect(dataSource.isOnboardingCompleted, isFalse);
    });

    test('should return true when isOnboardingCompleted is true', () async {
      SharedPreferences.setMockInitialValues({'isOnboardingCompleted': true});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = OnboardingLocalDataSource(sharedPreferences: prefs);

      expect(dataSource.isOnboardingCompleted, isTrue);
    });

    test('should complete onboarding successfully', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = OnboardingLocalDataSource(sharedPreferences: prefs);

      await dataSource.completeOnboarding();
      expect(dataSource.isOnboardingCompleted, isTrue);
    });
  });

  group('Onboarding Repository', () {
    test('should proxy status check and completion call to local data source', () async {
      final fakeDataSource = FakeOnboardingLocalDataSource();
      final repository = OnboardingRepository(localDataSource: fakeDataSource);

      expect(repository.isOnboardingCompleted, isFalse);
      await repository.completeOnboarding();
      expect(repository.isOnboardingCompleted, isTrue);
    });
  });

  group('Onboarding UseCases', () {
    test('IsOnboardingCompletedUseCase should return status', () async {
      final fakeRepository = FakeOnboardingRepository();
      final useCase = IsOnboardingCompletedUseCase(fakeRepository);

      final result = await useCase(const NoParams());
      expect(result, const Right(false));
    });

    test('CompleteOnboardingUseCase should complete onboarding', () async {
      final fakeRepository = FakeOnboardingRepository();
      final useCase = CompleteOnboardingUseCase(fakeRepository);

      final result = await useCase(const NoParams());
      expect(result, const Right(unit));
      expect(fakeRepository.isOnboardingCompleted, isTrue);
    });
  });
}
