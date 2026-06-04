import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/features/auth/domain/usecases/get_active_user.dart';
import 'package:spend_sum/features/onboarding/domain/usecases/is_onboarding_completed_usecase.dart';

sealed class AuthGateState {
  const AuthGateState();
}

class AuthGateInitial extends AuthGateState {
  const AuthGateInitial();
}

class AuthGateLoading extends AuthGateState {
  const AuthGateLoading();
}

class AuthGateOnboardingRequired extends AuthGateState {
  const AuthGateOnboardingRequired();
}

class AuthGateLoginRequired extends AuthGateState {
  const AuthGateLoginRequired();
}

class AuthGateSurveyRequired extends AuthGateState {
  final String uid;
  const AuthGateSurveyRequired(this.uid);
}

class AuthGateDashboardRequired extends AuthGateState {
  final User user;
  const AuthGateDashboardRequired(this.user);
}

class AuthGateCubit extends Cubit<AuthGateState> {
  final IsOnboardingCompletedUseCase isOnboardingCompletedUseCase;
  final GetActiveUserUseCase getActiveUserUseCase;

  AuthGateCubit({
    required this.isOnboardingCompletedUseCase,
    required this.getActiveUserUseCase,
  }) : super(const AuthGateInitial());

  Future<void> evaluateAuthRoute() async {
    emit(const AuthGateLoading());

    final onboardingResult = await isOnboardingCompletedUseCase(const NoParams());
    final isOnboardingCompleted = onboardingResult.fold((_) => false, (completed) => completed);

    if (!isOnboardingCompleted) {
      emit(const AuthGateOnboardingRequired());
      return;
    }

    final activeUserResult = await getActiveUserUseCase(const NoParams());
    activeUserResult.fold(
      (failure) => emit(const AuthGateLoginRequired()),
      (user) {
        if (user != null) {
          if (user.isBudgetCompleted) {
            emit(AuthGateDashboardRequired(user));
          } else {
            emit(AuthGateSurveyRequired(user.uid));
          }
        } else {
          emit(const AuthGateLoginRequired());
        }
      },
    );
  }
}
