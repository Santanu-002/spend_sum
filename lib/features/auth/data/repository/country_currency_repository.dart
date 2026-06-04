import 'package:fpdart/fpdart.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/error/app_errors.dart';
import 'package:spend_sum/features/auth/data/models/country_code_model.dart';
import 'package:spend_sum/features/auth/domain/entities/country_code.dart';
import 'package:spend_sum/features/auth/domain/repository/i_country_currency_repository.dart';

class CountryCurrencyRepository implements ICountryCurrencyRepository {
  final AppDatabase database;
  List<CountryCode> _cache = [];

  CountryCurrencyRepository({required this.database});

  /// Asynchronously queries the SQLite database and populates the in-memory cache.
  Future<void> initCache() async {
    try {
      final list = await database.getAllCountryCurrencies();
      _cache = list.map((e) => CountryCodeModel.fromDb(e)).toList();
    } catch (e) {
      _cache = [];
    }
  }

  @override
  Future<Either<AppFailure, List<CountryCode>>> getCountryCurrencies() async {
    try {
      if (_cache.isEmpty) {
        await initCache();
      }
      return Right(_cache);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load country currencies from database: ${e.toString()}'));
    }
  }

  @override
  List<CountryCode> getCountryCurrenciesSync() {
    return _cache;
  }

  @override
  String getCurrencySymbolSync(String? phoneNumber) {
    if (phoneNumber == null) return '\$';
    final cleanPhone = phoneNumber.trim();

    // Sort cache by code length descending to match the longest code prefix first
    final sortedCurrencies = List<CountryCode>.from(_cache)
      ..sort((a, b) => b.code.length.compareTo(a.code.length));

    for (final cc in sortedCurrencies) {
      if (cleanPhone.startsWith(cc.code)) {
        return cc.currencySymbol;
      }
    }

    for (final cc in sortedCurrencies) {
      final codeWithoutPlus = cc.code.replaceFirst('+', '');
      if (cleanPhone.startsWith(codeWithoutPlus)) {
        return cc.currencySymbol;
      }
    }

    return '\$';
  }
}
