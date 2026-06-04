import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:spend_sum/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:spend_sum/features/auth/data/repository/auth_repository.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';
import 'package:spend_sum/features/auth/domain/usecases/get_active_user.dart';

class FakeAppDatabase implements AppDatabase {
  final User? userToReturn;

  FakeAppDatabase({this.userToReturn});

  @override
  Future<User?> getUserByUid(String uid) async {
    return userToReturn;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthLocalDataSource implements IAuthLocalDataSource {
  bool isLoggedIn = false;
  String? uid;
  User? user;

  FakeAuthLocalDataSource({this.user, this.isLoggedIn = false, this.uid});

  @override
  Future<User?> getUserByPhone(String phoneNumber) async => user;

  @override
  Future<User?> getUserByUid(String uid) async => user;

  @override
  Future<int> insertUser(dynamic companion) async => 1;

  @override
  Future<bool> updateUser(User user) async {
    this.user = user;
    return true;
  }

  @override
  Future<int> insertBudget(dynamic companion) async => 1;

  @override
  Future<void> saveUserLoggedInSession({required String uid}) async {
    isLoggedIn = true;
    this.uid = uid;
  }

  @override
  Future<void> clearUserSession() async {
    isLoggedIn = false;
    uid = null;
  }

  @override
  Future<bool> isUserLoggedIn() async => isLoggedIn;

  @override
  Future<String?> getLoggedInUserId() async => uid;
}

class FakeAuthRemoteDataSource implements IAuthRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthRepository implements IAuthRepository {
  User? activeUser;
  bool _loggedOut = false;

  FakeAuthRepository({this.activeUser});

  bool get isLoggedOut => _loggedOut;

  @override
  Future<Either<AppFailure, User?>> getActiveUser() async {
    return Right(activeUser);
  }

  @override
  Future<Either<AppFailure, User?>> getUser(String uid) async {
    return Right(activeUser);
  }

  @override
  Future<Either<AppFailure, Unit>> logout() async {
    _loggedOut = true;
    activeUser = null;
    return const Right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyUser = User(
    uid: 'user_12345',
    phoneNumber: '+1234567890',
    name: 'John Doe',
    isNew: false,
    isBudgetCompleted: true,
  );

  group('AuthLocalDataSource - Session Management', () {
    test('should save and retrieve session state from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fakeDb = FakeAppDatabase();
      final dataSource = AuthLocalDataSource(database: fakeDb, sharedPreferences: prefs);

      expect(await dataSource.isUserLoggedIn(), isFalse);
      expect(await dataSource.getLoggedInUserId(), isNull);

      await dataSource.saveUserLoggedInSession(uid: 'user_12345');

      expect(await dataSource.isUserLoggedIn(), isTrue);
      expect(await dataSource.getLoggedInUserId(), equals('user_12345'));

      await dataSource.clearUserSession();

      expect(await dataSource.isUserLoggedIn(), isFalse);
      expect(await dataSource.getLoggedInUserId(), isNull);
    });
  });

  group('AuthRepository - getActiveUser & logout', () {
    test('should return null user if not logged in', () async {
      final fakeLocalDataSource = FakeAuthLocalDataSource(isLoggedIn: false);
      final fakeRemoteDataSource = FakeAuthRemoteDataSource();
      final repository = AuthRepository(
        localDataSource: fakeLocalDataSource,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await repository.getActiveUser();
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should not fail'),
        (user) => expect(user, isNull),
      );
    });

    test('should return User if logged in and exists in database', () async {
      final fakeLocalDataSource = FakeAuthLocalDataSource(
        user: dummyUser,
        isLoggedIn: true,
        uid: 'user_12345',
      );
      final fakeRemoteDataSource = FakeAuthRemoteDataSource();
      final repository = AuthRepository(
        localDataSource: fakeLocalDataSource,
        remoteDataSource: fakeRemoteDataSource,
      );

      final result = await repository.getActiveUser();
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should not fail'),
        (user) {
          expect(user, isNotNull);
          expect(user!.uid, equals('user_12345'));
        },
      );
    });
  });

  group('GetActiveUserUseCase', () {
    test('should call getActiveUser on repository', () async {
      final fakeRepository = FakeAuthRepository(activeUser: dummyUser);
      final useCase = GetActiveUserUseCase(fakeRepository);

      final result = await useCase(const NoParams());
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should not fail'),
        (user) => expect(user, equals(dummyUser)),
      );
    });
  });

  group('UserCubit', () {
    test('should load user profile and emit UserLoggedIn on success', () async {
      final fakeRepository = FakeAuthRepository(activeUser: dummyUser);
      final cubit = UserCubit(authRepository: fakeRepository);

      expect(cubit.state, isA<UserInitial>());

      final future = cubit.loadUserProfile('user_12345');
      expect(cubit.state, isA<UserLoading>());

      await future;
      expect(cubit.state, isA<UserLoggedIn>());
      expect((cubit.state as UserLoggedIn).user, equals(dummyUser));
    });

    test('should emit UserLoggedOut on logout', () async {
      final fakeRepository = FakeAuthRepository(activeUser: dummyUser);
      final cubit = UserCubit(authRepository: fakeRepository);
      cubit.updateUserState(dummyUser);

      expect(cubit.state, isA<UserLoggedIn>());

      final future = cubit.logout();
      expect(cubit.state, isA<UserLoading>());

      await future;
      expect(cubit.state, isA<UserLoggedOut>());
      expect(fakeRepository.isLoggedOut, isTrue);
    });
  });
}
