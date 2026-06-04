import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/add_category_usecase.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/get_categories_usecase.dart';

sealed class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  const CategoryLoaded(this.categories);
}

class CategoryAddSuccess extends CategoryState {
  const CategoryAddSuccess();
}

class CategoryFailure extends CategoryState {
  final String message;
  const CategoryFailure(this.message);
}

class CategoryCubit extends Cubit<CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;

  CategoryCubit({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
  }) : super(const CategoryInitial());

  Future<void> loadCategories({required bool isExpense}) async {
    emit(const CategoryLoading());
    final result = await getCategoriesUseCase(
      GetCategoriesParams(isExpense: isExpense),
    );
    result.fold(
      (failure) => emit(CategoryFailure(failure.message)),
      (categoriesList) => emit(CategoryLoaded(categoriesList)),
    );
  }

  Future<void> addCategory({
    required String name,
    required String icon,
    required String color,
    required bool isExpense,
  }) async {
    emit(const CategoryLoading());
    final result = await addCategoryUseCase(
      AddCategoryParams(
        name: name,
        icon: icon,
        color: color,
        isExpense: isExpense,
      ),
    );
    result.fold(
      (failure) => emit(CategoryFailure(failure.message)),
      (_) => emit(const CategoryAddSuccess()),
    );
  }
}
