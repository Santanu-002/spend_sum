import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';

/// Parameter arguments required to execute SubmitBudgetDetails UseCase.
class SubmitBudgetParams {
  final String uid;
  final double amount;
  final String period;

  const SubmitBudgetParams({
    required this.uid,
    required this.amount,
    required this.period,
  });
}

/// UseCase to submit budget details survey data.
class SubmitBudgetDetails implements BaseUseCase<Unit, SubmitBudgetParams> {
  final IAuthRepository repository;

  const SubmitBudgetDetails(this.repository);

  @override
  Future<Either<AppFailure, Unit>> call(SubmitBudgetParams params) {
    return repository.submitBudgetDetails(
      uid: params.uid,
      amount: params.amount,
      period: params.period,
    );
  }
}
