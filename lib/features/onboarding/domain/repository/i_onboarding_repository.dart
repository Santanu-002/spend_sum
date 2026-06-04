abstract interface class IOnboardingRepository {
  bool get isOnboardingCompleted;
  Future<void> completeOnboarding();
}
