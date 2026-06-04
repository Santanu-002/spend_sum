import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/dashboard/domain/entities/home_overview_data.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/get_categories_usecase.dart';

class FakeHomeRepository implements IHomeRepository {
  final List<Category> categories;

  FakeHomeRepository({required this.categories});

  @override
  Future<Either<AppFailure, List<Category>>> getCategories({required bool isExpense}) async {
    return Either.right(categories.where((cat) => cat.isExpense == isExpense).toList());
  }

  @override
  Future<Either<AppFailure, HomeOverviewData>> getHomeOverview(String uid) {
    throw UnimplementedError();
  }

  @override
  Stream<Either<AppFailure, HomeOverviewData>> watchHomeOverview(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AppFailure, Unit>> updateBudget(String uid, double amount) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AppFailure, int>> addExpense({
    required String userUid,
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    required bool isIncome,
    String? notes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AppFailure, int>> addCategory({
    required String name,
    required String icon,
    required String color,
    required bool isExpense,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('GetCategoriesUseCase', () {
    test('should return list of categories sorted alphabetically', () async {
      // Arrange
      final rawCategories = [
        const Category(id: 1, name: 'Food', icon: 'food_icon', color: '#FF0000', isExpense: true),
        const Category(id: 2, name: 'Entertainment', icon: 'ent_icon', color: '#00FF00', isExpense: true),
        const Category(id: 3, name: 'Bills', icon: 'bills_icon', color: '#0000FF', isExpense: true),
        const Category(id: 4, name: 'Shopping', icon: 'shop_icon', color: '#FFFF00', isExpense: true),
      ];

      final fakeRepository = FakeHomeRepository(categories: rawCategories);
      final useCase = GetCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(const GetCategoriesParams(isExpense: true));

      // Assert
      expect(result.isRight(), isTrue);
      
      result.fold(
        (failure) => fail('Should not return a failure'),
        (categories) {
          expect(categories.length, equals(4));
          // Alphabetical order: Bills, Entertainment, Food, Shopping
          expect(categories[0].name, equals('Bills'));
          expect(categories[1].name, equals('Entertainment'));
          expect(categories[2].name, equals('Food'));
          expect(categories[3].name, equals('Shopping'));
        },
      );
    });
  });
}
