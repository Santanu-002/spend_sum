import 'dart:async';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/core/error/app_exception.dart';
import 'package:spend_sum/features/dashboard/data/datasources/home_local_datasource.dart';
import 'package:spend_sum/features/dashboard/domain/entities/home_overview_data.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';

/// Data Layer concrete implementation of IHomeRepository.
class HomeRepository implements IHomeRepository {
  final IHomeLocalDataSource localDataSource;

  HomeRepository(this.localDataSource);

  @override
  Future<Either<AppFailure, HomeOverviewData>> getHomeOverview(String uid) async {
    try {
      // 1. Fetch user budgets
      final budgets = await localDataSource.getBudgetsForUser(uid);
      final double budgetAmount = budgets.isNotEmpty ? budgets.first.amount : 0.0;

      // 2. Fetch all expenses/transactions
      final rawExpenses = await localDataSource.getAllExpensesForUser(uid);
      final expenses = rawExpenses.map((e) {
        final resolvedIsIncome = e.isIncome || _isIncomeCategory(e.category);
        return e.copyWith(isIncome: resolvedIsIncome);
      }).toList();

      // 3. Calculate total expenses and income
      final double totalExpenses = expenses.where((e) => !e.isIncome).fold(0.0, (sum, e) => sum + e.amount);
      final double totalIncome = expenses.where((e) => e.isIncome).fold(0.0, (sum, e) => sum + e.amount);

      // 4. Calculate wallet balance: budget + total income - total expenses
      final double walletBalance = budgetAmount + totalIncome - totalExpenses;

      // 5. Calculate spend for this month (only non-income records)
      final now = DateTime.now();
      final double thisMonthSpend = expenses.where((e) {
        return !e.isIncome && e.date.year == now.year && e.date.month == now.month;
      }).fold(0.0, (sum, e) => sum + e.amount);

      // 6. Get 4 most recent transactions sorted by date descending
      final sortedExpenses = List<Expense>.from(expenses)
        ..sort((a, b) => b.date.compareTo(a.date));
      final recentTransactions = sortedExpenses.take(4).toList();

      return Right(
        HomeOverviewData(
          thisMonthSpend: thisMonthSpend,
          walletBalance: walletBalance,
          budgetAmount: budgetAmount,
          recentTransactions: recentTransactions,
          allTransactions: sortedExpenses,
        ),
      );
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('An unexpected database error occurred: $e'));
    }
  }

  @override
  Stream<Either<AppFailure, HomeOverviewData>> watchHomeOverview(String uid) {
    final controller = StreamController<Either<AppFailure, HomeOverviewData>>();
    StreamSubscription? expensesSub;
    StreamSubscription? budgetsSub;

    Future<void> update() async {
      if (controller.isClosed) return;
      try {
        final budgets = await localDataSource.getBudgetsForUser(uid);
        final double budgetAmount = budgets.isNotEmpty ? budgets.first.amount : 0.0;

        final rawExpenses = await localDataSource.getAllExpensesForUser(uid);
        final expenses = rawExpenses.map((e) {
          final resolvedIsIncome = e.isIncome || _isIncomeCategory(e.category);
          return e.copyWith(isIncome: resolvedIsIncome);
        }).toList();

        final double totalExpenses = expenses.where((e) => !e.isIncome).fold(0.0, (sum, e) => sum + e.amount);
        final double totalIncome = expenses.where((e) => e.isIncome).fold(0.0, (sum, e) => sum + e.amount);
        final double walletBalance = budgetAmount + totalIncome - totalExpenses;

        final now = DateTime.now();
        final double thisMonthSpend = expenses.where((e) {
          return !e.isIncome && e.date.year == now.year && e.date.month == now.month;
        }).fold(0.0, (sum, e) => sum + e.amount);

        final sortedExpenses = List<Expense>.from(expenses)
          ..sort((a, b) => b.date.compareTo(a.date));
        final recentTransactions = sortedExpenses.take(4).toList();

        if (!controller.isClosed) {
          controller.add(Right(
            HomeOverviewData(
              thisMonthSpend: thisMonthSpend,
              walletBalance: walletBalance,
              budgetAmount: budgetAmount,
              recentTransactions: recentTransactions,
              allTransactions: sortedExpenses,
            ),
          ));
        }
      } on DatabaseException catch (e) {
        if (!controller.isClosed) {
          controller.add(Left(DatabaseFailure(e.message)));
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.add(Left(DatabaseFailure('Failed to watch database: $e')));
        }
      }
    }

    try {
      expensesSub = localDataSource.watchAllExpensesForUser(uid).listen((_) => update());
      budgetsSub = localDataSource.watchBudgetsForUser(uid).listen((_) => update());
    } catch (e) {
      controller.add(Left(DatabaseFailure('Failed to listen to database streams: $e')));
    }

    controller.onCancel = () {
      expensesSub?.cancel();
      budgetsSub?.cancel();
    };

    // Initial trigger
    update();

    return controller.stream;
  }

  @override
  Future<Either<AppFailure, List<Category>>> getCategories({required bool isExpense}) async {
    try {
      final list = await localDataSource.getCategoriesByType(isExpense: isExpense);
      return Right(list);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to load categories: $e'));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> updateBudget(String uid, double amount) async {
    try {
      final list = await localDataSource.getBudgetsForUser(uid);
      if (list.isNotEmpty) {
        final existing = list.first;
        await localDataSource.updateBudget(existing.copyWith(amount: amount));
      } else {
        await localDataSource.insertBudget(BudgetsCompanion(
          userUid: Value(uid),
          amount: Value(amount),
          period: const Value('Monthly'),
        ));
      }
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to update budget: $e'));
    }
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
  }) async {
    try {
      final bool resolvedIsIncome = isIncome || _isIncomeCategory(category);
      final companion = ExpensesCompanion(
        userUid: Value(userUid),
        title: Value(title),
        amount: Value(amount),
        date: Value(date),
        category: Value(category),
        isIncome: Value(resolvedIsIncome),
        notes: Value(notes),
      );
      final id = await localDataSource.insertExpense(companion);
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to save transaction: $e'));
    }
  }

  @override
  Future<Either<AppFailure, int>> addCategory({
    required String name,
    required String icon,
    required String color,
    required bool isExpense,
  }) async {
    try {
      final companion = CategoriesCompanion(
        name: Value(name),
        icon: Value(icon),
        color: Value(color),
        isExpense: Value(isExpense),
      );
      final id = await localDataSource.insertCategory(companion);
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to save category: $e'));
    }
  }

  bool _isIncomeCategory(String categoryName) {
    final nameLower = categoryName.toLowerCase().trim();
    final incomeCategories = {
      'salary',
      'freelance',
      'investments',
      'gifts',
      'bonus',
      'refunds',
      'rental',
      'other income',
    };
    return incomeCategories.contains(nameLower);
  }
}
