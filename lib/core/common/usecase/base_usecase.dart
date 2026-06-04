import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/error/app_errors.dart';

/// Base contract interface for all SpendSum Domain UseCases.
/// Enforces consistent return types via the functional Either pattern.
abstract interface class BaseUseCase<SuccessType, Params> {
  Future<Either<AppFailure, SuccessType>> call(Params params);
}

/// Helper parameter class for UseCases that do not require any input parameters.
class NoParams {
  const NoParams();
}
