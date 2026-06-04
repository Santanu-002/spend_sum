import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';

/// Parameters for the AddCategoryUseCase.
class AddCategoryParams {
  final String name;
  final String icon;
  final String color;
  final bool isExpense;

  const AddCategoryParams({
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
  });
}

/// UseCase to insert a new custom category into the database.
class AddCategoryUseCase implements BaseUseCase<int, AddCategoryParams> {
  final IHomeRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<Either<AppFailure, int>> call(AddCategoryParams params) async {
    return repository.addCategory(
      name: params.name,
      icon: params.icon,
      color: params.color,
      isExpense: params.isExpense,
    );
  }
}
