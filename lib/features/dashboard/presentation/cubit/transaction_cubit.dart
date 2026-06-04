import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/delete_transaction_usecase.dart';

sealed class TransactionState {
  const TransactionState();
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionSuccess extends TransactionState {
  const TransactionSuccess();
}

class TransactionDeleteSuccess extends TransactionState {
  final Expense transaction;
  const TransactionDeleteSuccess(this.transaction);
}

class TransactionFailure extends TransactionState {
  final String message;
  const TransactionFailure(this.message);
}

class TransactionCubit extends Cubit<TransactionState> {
  final IHomeRepository homeRepository;
  final DeleteTransactionUseCase deleteTransactionUseCase;

  TransactionCubit({
    required this.homeRepository,
    required this.deleteTransactionUseCase,
  }) : super(const TransactionInitial());

  Future<void> addTransaction({
    required String userUid,
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    required bool isIncome,
    String? notes,
  }) async {
    emit(const TransactionLoading());
    final result = await homeRepository.addExpense(
      userUid: userUid,
      title: title,
      amount: amount,
      date: date,
      category: category,
      isIncome: isIncome,
      notes: notes,
    );
    result.fold(
      (failure) => emit(TransactionFailure(failure.message)),
      (_) => emit(const TransactionSuccess()),
    );
  }

  Future<void> deleteTransaction(Expense tx) async {
    emit(const TransactionLoading());
    final result = await deleteTransactionUseCase(tx);
    result.fold(
      (failure) => emit(TransactionFailure(failure.message)),
      (_) => emit(TransactionDeleteSuccess(tx)),
    );
  }

  Future<void> restoreTransaction({
    required String userUid,
    required Expense tx,
  }) async {
    emit(const TransactionLoading());
    final result = await homeRepository.addExpense(
      userUid: userUid,
      title: tx.title,
      amount: tx.amount,
      date: tx.date,
      category: tx.category,
      isIncome: tx.isIncome,
      notes: tx.notes,
    );
    result.fold(
      (failure) => emit(TransactionFailure(failure.message)),
      (_) => emit(const TransactionSuccess()),
    );
  }
}
