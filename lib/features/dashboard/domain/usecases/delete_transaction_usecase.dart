import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';

/// UseCase to delete a transaction/expense from the local database.
class DeleteTransactionUseCase {
  final IHomeRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<Either<AppFailure, int>> call(Expense expense) {
    return repository.deleteExpense(expense);
  }
}
