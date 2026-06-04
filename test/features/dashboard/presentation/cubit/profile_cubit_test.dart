import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';
import 'package:spend_sum/features/auth/domain/usecases/update_profile.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/profile_cubit.dart';

import 'package:spend_sum/features/auth/domain/repository/i_country_currency_repository.dart';
import 'package:spend_sum/features/auth/domain/entities/country_code.dart';

class FakeAuthRepository implements IAuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCountryCurrencyRepository implements ICountryCurrencyRepository {
  @override
  List<CountryCode> getCountryCurrenciesSync() => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUpdateProfile extends UpdateProfile {
  final Either<AppFailure, Unit> result;

  FakeUpdateProfile(this.result) : super(FakeAuthRepository());

  @override
  Future<Either<AppFailure, Unit>> call(UpdateProfileParams params) async {
    return result;
  }
}

void main() {
  group('ProfileCubit', () {
    test('should emit ProfileLoading and then ProfileSuccess on successful update', () async {
      final fakeUpdateProfile = FakeUpdateProfile(const Right(unit));
      final cubit = ProfileCubit(
        updateProfileUseCase: fakeUpdateProfile,
        countryCurrencyRepository: FakeCountryCurrencyRepository(),
      );

      expect(cubit.state, isA<ProfileInitial>());

      final future = cubit.updateProfile(
        uid: 'user_123',
        name: 'Santanu Dev',
        dob: DateTime(1995, 5, 5),
        gender: 'Male',
        email: 'santanu@example.com',
        currency: 'INR',
      );

      expect(cubit.state, isA<ProfileLoading>());

      await future;

      expect(cubit.state, isA<ProfileSuccess>());
    });

    test('should emit ProfileLoading and then ProfileFailure on failed update', () async {
      const fakeFailure = DatabaseFailure('Database update failed');
      final fakeUpdateProfile = FakeUpdateProfile(const Left(fakeFailure));
      final cubit = ProfileCubit(
        updateProfileUseCase: fakeUpdateProfile,
        countryCurrencyRepository: FakeCountryCurrencyRepository(),
      );

      expect(cubit.state, isA<ProfileInitial>());

      final future = cubit.updateProfile(
        uid: 'user_123',
        name: 'Santanu Dev',
        dob: DateTime(1995, 5, 5),
        gender: 'Male',
        email: 'santanu@example.com',
        currency: 'INR',
      );

      expect(cubit.state, isA<ProfileLoading>());

      await future;

      expect(cubit.state, isA<ProfileFailure>());
      expect((cubit.state as ProfileFailure).message, equals('Database update failed'));
    });
  });
}
