import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';

/// Sealed class representing the different states of the active user profile.
sealed class UserState {
  const UserState();
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoggedIn extends UserState {
  final User user;
  const UserLoggedIn(this.user);
}

class UserLoggedOut extends UserState {
  const UserLoggedOut();
}

/// Global Cubit managing user profile session state and storage persistence.
class UserCubit extends Cubit<UserState> {
  final IAuthRepository authRepository;

  UserCubit({required this.authRepository})
    : super(const UserInitial());

  /// Loads the user profile metadata by unique user ID.
  Future<void> loadUserProfile(String uid) async {
    emit(const UserLoading());
    final result = await authRepository.getUser(uid);
    result.fold(
      (failure) => emit(const UserLoggedOut()),
      (user) {
        if (user != null) {
          emit(UserLoggedIn(user));
        } else {
          emit(const UserLoggedOut());
        }
      },
    );
  }

  /// Refreshes the local memory state directly when updating details.
  void updateUserState(User user) {
    emit(UserLoggedIn(user));
  }

  /// Clears active SharedPreferences credentials and signs out.
  Future<void> logout() async {
    emit(const UserLoading());
    final result = await authRepository.logout();
    result.fold(
      (failure) => {}, // Keep logged out state in UI anyway on failure
      (_) {},
    );
    emit(const UserLoggedOut());
  }
}
