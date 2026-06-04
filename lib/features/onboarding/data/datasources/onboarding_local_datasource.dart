import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_sum/core/error/app_exception.dart';

abstract interface class IOnboardingLocalDataSource {
  bool get isOnboardingCompleted;
  Future<void> completeOnboarding();
}

class OnboardingLocalDataSource implements IOnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSource({required this.sharedPreferences});

  @override
  bool get isOnboardingCompleted {
    try {
      return sharedPreferences.getBool('isOnboardingCompleted') ?? false;
    } catch (e) {
      throw DatabaseException('Failed to get onboarding completed status', details: e);
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await sharedPreferences.setBool('isOnboardingCompleted', true);
    } catch (e) {
      throw DatabaseException('Failed to save onboarding completed status', details: e);
    }
  }
}
