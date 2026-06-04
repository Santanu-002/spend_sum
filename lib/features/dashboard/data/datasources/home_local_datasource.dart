import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_exception.dart';

abstract interface class IHomeLocalDataSource {
  Future<List<Budget>> getBudgetsForUser(String uid);
  Stream<List<Budget>> watchBudgetsForUser(String uid);
  Future<List<Expense>> getAllExpensesForUser(String uid);
  Stream<List<Expense>> watchAllExpensesForUser(String uid);
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getCategoriesByType({required bool isExpense});
  Future<int> insertExpense(ExpensesCompanion companion);
  Future<bool> updateBudget(Budget budget);
  Future<int> insertBudget(BudgetsCompanion companion);
  Future<int> insertCategory(CategoriesCompanion companion);
  Future<int> deleteCategory(Category category);
}

class HomeLocalDataSource implements IHomeLocalDataSource {
  final AppDatabase database;

  HomeLocalDataSource(this.database);

  @override
  Future<List<Budget>> getBudgetsForUser(String uid) async {
    try {
      return await database.getBudgetsForUser(uid);
    } catch (e) {
      throw DatabaseException('Failed to get budgets for user from local database', details: e);
    }
  }

  @override
  Stream<List<Budget>> watchBudgetsForUser(String uid) {
    try {
      return database.watchBudgetsForUser(uid);
    } catch (e) {
      throw DatabaseException('Failed to watch budgets for user from local database', details: e);
    }
  }

  @override
  Future<List<Expense>> getAllExpensesForUser(String uid) async {
    try {
      return await database.getAllExpensesForUser(uid);
    } catch (e) {
      throw DatabaseException('Failed to get all expenses for user from local database', details: e);
    }
  }

  @override
  Stream<List<Expense>> watchAllExpensesForUser(String uid) {
    try {
      return database.watchAllExpensesForUser(uid);
    } catch (e) {
      throw DatabaseException('Failed to watch all expenses for user from local database', details: e);
    }
  }

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      return await database.getAllCategories();
    } catch (e) {
      throw DatabaseException('Failed to get all categories from local database', details: e);
    }
  }

  @override
  Future<List<Category>> getCategoriesByType({required bool isExpense}) async {
    try {
      return await database.getCategoriesByType(isExpense: isExpense);
    } catch (e) {
      throw DatabaseException('Failed to get categories by type from local database', details: e);
    }
  }

  @override
  Future<int> insertExpense(ExpensesCompanion companion) async {
    try {
      return await database.insertExpense(companion);
    } catch (e) {
      throw DatabaseException('Failed to insert expense into local database', details: e);
    }
  }

  @override
  Future<bool> updateBudget(Budget budget) async {
    try {
      return await database.updateBudget(budget);
    } catch (e) {
      throw DatabaseException('Failed to update budget in local database', details: e);
    }
  }

  @override
  Future<int> insertBudget(BudgetsCompanion companion) async {
    try {
      return await database.insertBudget(companion);
    } catch (e) {
      throw DatabaseException('Failed to insert budget into local database', details: e);
    }
  }

  @override
  Future<int> insertCategory(CategoriesCompanion companion) async {
    try {
      return await database.insertCategory(companion);
    } catch (e) {
      throw DatabaseException('Failed to insert category into local database', details: e);
    }
  }

  @override
  Future<int> deleteCategory(Category category) async {
    try {
      return await database.deleteCategory(category);
    } catch (e) {
      throw DatabaseException('Failed to delete category from local database', details: e);
    }
  }
}
