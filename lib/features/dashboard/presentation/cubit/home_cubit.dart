import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/features/dashboard/domain/entities/home_overview_data.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/get_home_data_usecase.dart';

/// Sealed class representing the presentation states of the Home View.
sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final HomeOverviewData data;
  const HomeLoaded(this.data);
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}

/// Cubit managing loading states, calculations, and active databinding for the Dashboard Home page.
class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;
  StreamSubscription<dynamic>? _subscription;

  HomeCubit({required this.getHomeDataUseCase}) : super(const HomeInitial());

  /// Triggers loading of budget amounts, monthly expenses, and recent records.
  Future<void> loadHomeOverview(String uid) async {
    emit(const HomeLoading());
    
    // Explicit 3-second delay requested by the user
    await Future.delayed(const Duration(seconds: 3));

    await _subscription?.cancel();
    _subscription = getHomeDataUseCase(uid).listen(
      (result) {
        result.fold(
          (failure) => emit(HomeError(failure.message)),
          (data) => emit(HomeLoaded(data)),
        );
      },
      onError: (e) {
        emit(HomeError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
