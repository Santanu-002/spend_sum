import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/dashboard/domain/entities/home_overview_data.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';

/// UseCase to watch current dashboard overview metrics and recent transactions.
class GetHomeDataUseCase {
  final IHomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Stream<Either<AppFailure, HomeOverviewData>> call(String uid) {
    return repository.watchHomeOverview(uid);
  }
}
