import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/common/usecase/base_usecase.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/entities/country_code.dart';
import 'package:spend_sum/features/auth/domain/repository/i_country_currency_repository.dart';

/// UseCase to retrieve the list of available country configurations.
class GetCountryCurrenciesUseCase implements BaseUseCase<List<CountryCode>, NoParams> {
  final ICountryCurrencyRepository repository;

  const GetCountryCurrenciesUseCase(this.repository);

  @override
  Future<Either<AppFailure, List<CountryCode>>> call(NoParams params) {
    return repository.getCountryCurrencies();
  }
}
