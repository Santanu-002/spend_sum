import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/core/error/app_exception.dart';
import 'package:spend_sum/core/common/util/id_generator.dart';
import 'package:spend_sum/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:spend_sum/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:spend_sum/features/auth/domain/entities/auth_response.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';

/// Data Layer repository implementing the domain repository contract using Local and Remote Data Sources.
class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource localDataSource;
  final IAuthRemoteDataSource remoteDataSource;

  AuthRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<AppFailure, Unit>> sendOtp(String phoneNumber) async {
    try {
      await remoteDataSource.sendOtp(phoneNumber);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Connection error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, AuthResponse>> verifyOtp({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    try {
      // 1. Verify OTP remotely
      await remoteDataSource.verifyOtp(phoneNumber, verificationCode);

      // 2. Check if user already exists
      final existingUser = await localDataSource.getUserByPhone(phoneNumber);
      if (existingUser == null) {
        // Create new user record
        final newUid = generateNanoId(length: 10);
        final companion = UsersCompanion.insert(
          uid: newUid,
          phoneNumber: phoneNumber,
          isNew: const Value(true),
          isBudgetCompleted: const Value(false),
        );
        await localDataSource.insertUser(companion);

        return Right(
          AuthResponse(uid: newUid, isNew: true, isBudgetCompleted: false),
        );
      } else {
        // Exists: If not new, save persistent logged-in session state
        if (!existingUser.isNew) {
          await localDataSource.saveUserLoggedInSession(uid: existingUser.uid);
        }

        return Right(
          AuthResponse(
            uid: existingUser.uid,
            isNew: existingUser.isNew,
            isBudgetCompleted: existingUser.isBudgetCompleted,
          ),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Verification failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> registerUser({
    required String uid,
    required String name,
    DateTime? dob,
    String? gender,
    String? email,
  }) async {
    try {
      final existingUser = await localDataSource.getUserByUid(uid);
      if (existingUser == null) {
        return const Left(DatabaseFailure('User profile not found.'));
      }

      // Create an updated user row representation
      final updatedUser = existingUser.copyWith(
        name: Value(name),
        dob: Value(dob),
        gender: Value(gender),
        email: Value(email),
        isNew: false,
      );

      await localDataSource.updateUser(updatedUser);

      // Save user log in persistent state
      await localDataSource.saveUserLoggedInSession(uid: uid);

      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Failed to save profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> submitBudgetDetails({
    required String uid,
    required double amount,
    required String period,
  }) async {
    try {
      final existingUser = await localDataSource.getUserByUid(uid);
      if (existingUser == null) {
        return const Left(DatabaseFailure('User profile not found.'));
      }

      // Insert budget record
      final companion = BudgetsCompanion.insert(
        userUid: uid,
        amount: amount,
        period: period,
      );
      await localDataSource.insertBudget(companion);

      // Update user completes budget details flag
      final updatedUser = existingUser.copyWith(isBudgetCompleted: true);
      await localDataSource.updateUser(updatedUser);

      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to save budget details: ${e.toString()}'),
      );
    }
  }
}

