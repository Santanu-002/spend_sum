import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:spend_sum/features/onboarding/domain/usecases/is_onboarding_completed_usecase.dart';

sealed class OnboardingState {
  const OnboardingState();
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

class OnboardingStatusChecked extends OnboardingState {
  final bool isCompleted;
  const OnboardingStatusChecked(this.isCompleted);
}

class OnboardingFailure extends OnboardingState {
  final String message;
  const OnboardingFailure(this.message);
}

class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboardingUseCase completeOnboardingUseCase;
  final IsOnboardingCompletedUseCase isOnboardingCompletedUseCase;

  OnboardingCubit({
    required this.completeOnboardingUseCase,
    required this.isOnboardingCompletedUseCase,
  }) : super(const OnboardingInitial());

  Future<void> checkOnboardingStatus() async {
    emit(const OnboardingLoading());
    final result = await isOnboardingCompletedUseCase(const NoParams());
    result.fold(
      (failure) => emit(OnboardingFailure(failure.message)),
      (completed) => emit(OnboardingStatusChecked(completed)),
    );
  }

  Future<void> completeOnboarding() async {
    emit(const OnboardingLoading());
    final result = await completeOnboardingUseCase(const NoParams());
    result.fold(
      (failure) => emit(OnboardingFailure(failure.message)),
      (_) => emit(const OnboardingCompleted()),
    );
  }
}
