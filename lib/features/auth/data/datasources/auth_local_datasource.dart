import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_exception.dart';

abstract interface class IAuthLocalDataSource {
  Future<User?> getUserByPhone(String phoneNumber);
  Future<User?> getUserByUid(String uid);
  Future<int> insertUser(UsersCompanion companion);
  Future<bool> updateUser(User user);
  Future<int> insertBudget(BudgetsCompanion companion);
  Future<void> saveUserLoggedInSession({required String uid});
  Future<void> clearUserSession();
}

class AuthLocalDataSource implements IAuthLocalDataSource {
  final AppDatabase database;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSource({required this.database, required this.sharedPreferences});

  @override
  Future<User?> getUserByPhone(String phoneNumber) async {
    try {
      return await database.getUserByPhone(phoneNumber);
    } catch (e) {
      throw DatabaseException('Failed to get user by phone number from local database', details: e);
    }
  }

  @override
  Future<User?> getUserByUid(String uid) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return await database.getUserByUid(uid);
    } catch (e) {
      throw DatabaseException('Failed to get user by UID from local database', details: e);
    }
  }

  @override
  Future<int> insertUser(UsersCompanion companion) async {
    try {
      return await database.insertUser(companion);
    } catch (e) {
      throw DatabaseException('Failed to insert user into local database', details: e);
    }
  }

  @override
  Future<bool> updateUser(User user) async {
    try {
      return await database.updateUser(user);
    } catch (e) {
      throw DatabaseException('Failed to update user in local database', details: e);
    }
  }

  @override
  Future<int> insertBudget(BudgetsCompanion companion) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return await database.insertBudget(companion);
    } catch (e) {
      throw DatabaseException('Failed to insert budget into local database', details: e);
    }
  }

  @override
  Future<void> saveUserLoggedInSession({required String uid}) async {
    try {
      await sharedPreferences.setBool('isUserLoggedIn', true);
      await sharedPreferences.setString('loggedInUserId', uid);
    } catch (e) {
      throw DatabaseException('Failed to save user session in SharedPreferences', details: e);
    }
  }

  @override
  Future<void> clearUserSession() async {
    try {
      await sharedPreferences.remove('isUserLoggedIn');
      await sharedPreferences.remove('loggedInUserId');
    } catch (e) {
      throw DatabaseException('Failed to clear user session from SharedPreferences', details: e);
    }
  }
}
