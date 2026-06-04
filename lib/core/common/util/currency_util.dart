import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/features/auth/domain/repository/i_country_currency_repository.dart';

/// Mappings of country code prefixes to their corresponding currency symbols.
String getCurrencySymbol(String? phoneNumber) {
  return sl<ICountryCurrencyRepository>().getCurrencySymbolSync(phoneNumber);
}

/// Resolves the user's custom currency or falls back to registration country code currency.
String getUserCurrencySymbol(User user) {
  if (user.currency != null && user.currency!.trim().isNotEmpty) {
    return user.currency!.trim();
  }
  return getCurrencySymbol(user.phoneNumber);
}
