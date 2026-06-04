import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/domain/entities/country_code.dart';

abstract interface class ICountryCurrencyRepository {
  Future<Either<AppFailure, List<CountryCode>>> getCountryCurrencies();
  String getCurrencySymbolSync(String? phoneNumber);
  List<CountryCode> getCountryCurrenciesSync();
}
