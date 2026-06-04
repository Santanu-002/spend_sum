import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';

class GetCategoriesParams {
  final bool isExpense;
  const GetCategoriesParams({required this.isExpense});
}

/// UseCase to retrieve active categories from the database, sorted alphabetically by name.
class GetCategoriesUseCase implements BaseUseCase<List<Category>, GetCategoriesParams> {
  final IHomeRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<AppFailure, List<Category>>> call(GetCategoriesParams params) async {
    final result = await repository.getCategories(isExpense: params.isExpense);
    return result.map((categories) {
      final sorted = List<Category>.from(categories)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sorted;
    });
  }
}
