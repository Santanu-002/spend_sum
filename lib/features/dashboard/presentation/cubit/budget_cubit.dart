import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';

sealed class BudgetState {
  const BudgetState();
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

class BudgetSuccess extends BudgetState {
  const BudgetSuccess();
}

class BudgetFailure extends BudgetState {
  final String message;
  const BudgetFailure(this.message);
}

class BudgetCubit extends Cubit<BudgetState> {
  final IHomeRepository homeRepository;

  BudgetCubit({required this.homeRepository}) : super(const BudgetInitial());

  Future<void> updateBudget(String uid, double amount) async {
    emit(const BudgetLoading());
    final result = await homeRepository.updateBudget(uid, amount);
    result.fold(
      (failure) => emit(BudgetFailure(failure.message)),
      (_) => emit(const BudgetSuccess()),
    );
  }
}
