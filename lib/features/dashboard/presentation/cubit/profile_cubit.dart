import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/features/auth/domain/usecases/update_profile.dart';

import 'package:spend_sum/features/auth/domain/repository/i_country_currency_repository.dart';
import 'package:spend_sum/features/auth/domain/entities/country_code.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  const ProfileSuccess();
}

class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final UpdateProfile updateProfileUseCase;
  final ICountryCurrencyRepository countryCurrencyRepository;

  ProfileCubit({
    required this.updateProfileUseCase,
    required this.countryCurrencyRepository,
  }) : super(const ProfileInitial());

  List<CountryCode> getAvailableCurrencies() {
    return countryCurrencyRepository.getCountryCurrenciesSync();
  }

  Future<void> updateProfile({
    required String uid,
    required String name,
    required DateTime? dob,
    required String? gender,
    required String? email,
    required String? currency,
  }) async {
    emit(const ProfileLoading());
    final result = await updateProfileUseCase(
      UpdateProfileParams(
        uid: uid,
        name: name,
        dob: dob,
        gender: gender,
        email: email,
        currency: currency,
      ),
    );
    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) => emit(const ProfileSuccess()),
    );
  }
}
