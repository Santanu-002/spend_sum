import 'package:equatable/equatable.dart';

class CountryCode extends Equatable {
  final String code;
  final String flag;
  final String name;
  final int maxLength;
  final String currencySymbol;
  final String currencyLabel;

  const CountryCode({
    required this.code,
    required this.flag,
    required this.name,
    required this.maxLength,
    required this.currencySymbol,
    required this.currencyLabel,
  });

  @override
  List<Object?> get props => [code, flag, name, maxLength, currencySymbol, currencyLabel];
}
