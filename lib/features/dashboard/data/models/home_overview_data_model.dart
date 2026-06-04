import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/features/dashboard/domain/entities/home_overview_data.dart';

class HomeOverviewDataModel extends HomeOverviewData {
  const HomeOverviewDataModel({
    required super.thisMonthSpend,
    required super.walletBalance,
    required super.budgetAmount,
    super.percentageChange = 0.0,
    required super.recentTransactions,
    super.allTransactions = const [],
  });

  factory HomeOverviewDataModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'thisMonthSpend': num thisMonthSpend,
        'walletBalance': num walletBalance,
        'budgetAmount': num budgetAmount,
        'recentTransactions': List<dynamic> recentTransactions,
      } =>
        HomeOverviewDataModel(
          thisMonthSpend: thisMonthSpend.toDouble(),
          walletBalance: walletBalance.toDouble(),
          budgetAmount: budgetAmount.toDouble(),
          percentageChange: (json['percentageChange'] as num?)?.toDouble() ?? 0.0,
          recentTransactions: recentTransactions
              .map((item) => item is Map<String, dynamic> ? Expense.fromJson(item) : item as Expense)
              .toList(),
          allTransactions: (json['allTransactions'] as List<dynamic>?)
                  ?.map((item) => item is Map<String, dynamic> ? Expense.fromJson(item) : item as Expense)
                  .toList() ??
              const [],
        ),
      _ => throw const FormatException('Failed to parse HomeOverviewDataModel.'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'thisMonthSpend': thisMonthSpend,
      'walletBalance': walletBalance,
      'budgetAmount': budgetAmount,
      'percentageChange': percentageChange,
      'recentTransactions': recentTransactions.map((e) => e.toJson()).toList(),
      'allTransactions': allTransactions.map((e) => e.toJson()).toList(),
    };
  }
}
