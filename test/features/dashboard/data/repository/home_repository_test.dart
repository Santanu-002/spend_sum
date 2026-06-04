import 'package:flutter_test/flutter_test.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/core/error/app_exception.dart';
import 'package:spend_sum/features/dashboard/data/datasources/home_local_datasource.dart';
import 'package:spend_sum/features/dashboard/data/repository/home_repository.dart';

class FakeHomeLocalDataSource implements IHomeLocalDataSource {
  final bool shouldThrow;
  final List<Budget> budgets;
  final List<Expense> expenses;
  final List<Category> categories;

  FakeHomeLocalDataSource({
    this.shouldThrow = false,
    this.budgets = const [],
    this.expenses = const [],
    this.categories = const [],
  });

  @override
  Future<List<Budget>> getBudgetsForUser(String uid) async {
    if (shouldThrow) {
      throw const DatabaseException('Database fetch budgets error');
    }
    return budgets;
  }

  @override
  Stream<List<Budget>> watchBudgetsForUser(String uid) {
    if (shouldThrow) {
      throw const DatabaseException('Database watch budgets error');
    }
    return Stream.value(budgets);
  }

  @override
  Future<List<Expense>> getAllExpensesForUser(String uid) async {
    if (shouldThrow) {
      throw const DatabaseException('Database fetch expenses error');
    }
    return expenses;
  }

  @override
  Stream<List<Expense>> watchAllExpensesForUser(String uid) {
    if (shouldThrow) {
      throw const DatabaseException('Database watch expenses error');
    }
    return Stream.value(expenses);
  }

  @override
  Future<List<Category>> getAllCategories() async {
    if (shouldThrow) {
      throw const DatabaseException('Database fetch categories error');
    }
    return categories;
  }

  @override
  Future<List<Category>> getCategoriesByType({required bool isExpense}) async {
    if (shouldThrow) {
      throw const DatabaseException('Database fetch categories error');
    }
    return categories.where((cat) => cat.isExpense == isExpense).toList();
  }

  @override
  Future<int> insertExpense(ExpensesCompanion companion) async {
    if (shouldThrow) {
      throw const DatabaseException('Database insert expense error');
    }
    return 1;
  }

  @override
  Future<bool> updateBudget(Budget budget) async {
    if (shouldThrow) {
      throw const DatabaseException('Database update budget error');
    }
    return true;
  }

  @override
  Future<int> insertBudget(BudgetsCompanion companion) async {
    if (shouldThrow) {
      throw const DatabaseException('Database insert budget error');
    }
    return 1;
  }

  @override
  Future<int> insertCategory(CategoriesCompanion companion) async {
    if (shouldThrow) {
      throw const DatabaseException('Database insert category error');
    }
    return 1;
  }

  @override
  Future<int> deleteCategory(Category category) async {
    if (shouldThrow) {
      throw const DatabaseException('Database delete category error');
    }
    return 1;
  }

  @override
  Future<int> deleteExpense(Expense expense) async {
    if (shouldThrow) {
      throw const DatabaseException('Database delete expense error');
    }
    return 1;
  }
}

void main() {
  group('HomeRepository Exception and Failure Handling Tests', () {
    test('should return Left(DatabaseFailure) when localDataSource throws DatabaseException', () async {
      // Arrange
      final fakeLocalDataSource = FakeHomeLocalDataSource(shouldThrow: true);
      final repository = HomeRepository(fakeLocalDataSource);

      // Act
      final result = await repository.getHomeOverview('user_123');

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, contains('Database fetch budgets error'));
        },
        (_) => fail('Should have returned Left(DatabaseFailure)'),
      );
    });

    test('should return Right(HomeOverviewData) on success with calculated metrics', () async {
      // Arrange
      final fakeBudgets = [
        Budget(id: 1, userUid: 'user_123', amount: 5000.0, period: 'Monthly', createdAt: DateTime(2026, 6, 1)),
      ];
      final fakeExpenses = [
        Expense(id: 1, title: 'Rent', amount: 1500.0, date: DateTime.now(), category: 'Rent', isIncome: false),
        Expense(id: 2, title: 'Salary', amount: 3000.0, date: DateTime.now(), category: 'Salary', isIncome: true),
      ];
      final fakeLocalDataSource = FakeHomeLocalDataSource(
        shouldThrow: false,
        budgets: fakeBudgets,
        expenses: fakeExpenses,
      );
      final repository = HomeRepository(fakeLocalDataSource);

      // Act
      final result = await repository.getHomeOverview('user_123');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not return failure: ${failure.message}'),
        (data) {
          // walletBalance = budget (5000) + income (3000) - expense (1500) = 6500
          expect(data.walletBalance, equals(6500.0));
          // thisMonthSpend = 1500
          expect(data.thisMonthSpend, equals(1500.0));
          expect(data.budgetAmount, equals(5000.0));
          expect(data.recentTransactions.length, equals(2));
        },
      );
    });
  });
}
