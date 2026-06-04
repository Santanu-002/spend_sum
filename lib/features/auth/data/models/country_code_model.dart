import 'package:spend_sum/features/auth/domain/entities/country_code.dart';
import 'package:spend_sum/core/database/app_database.dart';

class CountryCodeModel extends CountryCode {
  const CountryCodeModel({
    required super.code,
    required super.flag,
    required super.name,
    required super.maxLength,
    required super.currencySymbol,
    required super.currencyLabel,
  });

  factory CountryCodeModel.fromDb(CountryCurrency dbEntry) {
    return CountryCodeModel(
      code: dbEntry.code,
      flag: dbEntry.flag,
      name: dbEntry.name,
      maxLength: dbEntry.maxLength,
      currencySymbol: dbEntry.currencySymbol,
      currencyLabel: dbEntry.currencyLabel,
    );
  }
}
