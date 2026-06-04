import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/dashboard/domain/entities/home_overview_data.dart';

/// Domain Layer repository contract for dashboard metrics and home data.
abstract interface class IHomeRepository {
  /// Fetches budget overview calculations and recent transactions for the active user session.
  Future<Either<AppFailure, HomeOverviewData>> getHomeOverview(String uid);

  /// Watches budget overview calculations and recent transactions for the active user session.
  Stream<Either<AppFailure, HomeOverviewData>> watchHomeOverview(String uid);

  /// Fetches categories filtered by type inside local storage database.
  Future<Either<AppFailure, List<Category>>> getCategories({required bool isExpense});

  /// Updates or inserts a user budget value in local storage database.
  Future<Either<AppFailure, Unit>> updateBudget(String uid, double amount);

  /// Inserts a new transaction (expense or income) in the local database.
  Future<Either<AppFailure, int>> addExpense({
    required String userUid,
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    required bool isIncome,
    String? notes,
  });

  /// Inserts a new custom category into the local database.
  Future<Either<AppFailure, int>> addCategory({
    required String name,
    required String icon,
    required String color,
    required bool isExpense,
  });
}
