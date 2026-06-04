import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/features/auth/domain/entities/country_code.dart';
import 'package:spend_sum/features/auth/domain/usecases/get_country_currencies.dart';

sealed class CountryCurrencyState {
  const CountryCurrencyState();
}

class CountryCurrencyInitial extends CountryCurrencyState {
  const CountryCurrencyInitial();
}

class CountryCurrencyLoading extends CountryCurrencyState {
  const CountryCurrencyLoading();
}

class CountryCurrencyLoaded extends CountryCurrencyState {
  final List<CountryCode> countries;
  const CountryCurrencyLoaded(this.countries);
}

class CountryCurrencyError extends CountryCurrencyState {
  final String message;
  const CountryCurrencyError(this.message);
}

class CountryCurrencyCubit extends Cubit<CountryCurrencyState> {
  final GetCountryCurrenciesUseCase getCountryCurrenciesUseCase;

  CountryCurrencyCubit({required this.getCountryCurrenciesUseCase})
      : super(const CountryCurrencyInitial());

  Future<void> loadCountryCurrencies() async {
    emit(const CountryCurrencyLoading());
    final result = await getCountryCurrenciesUseCase(const NoParams());
    result.fold(
      (failure) => emit(CountryCurrencyError(failure.message)),
      (countries) => emit(CountryCurrencyLoaded(countries)),
    );
  }
}
