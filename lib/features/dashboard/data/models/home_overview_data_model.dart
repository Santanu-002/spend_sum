import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/features/dashboard/domain/entities/home_overview_data.dart';

class HomeOverviewDataModel extends HomeOverviewData {
  const HomeOverviewDataModel({
    required super.thisMonthSpend,
    required super.walletBalance,
    required super.budgetAmount,
    required super.recentTransactions,
    super.allTransactions = const [],
  });

  factory HomeOverviewDataModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['recentTransactions'] as List<dynamic>? ?? [];
    final transactions = list.map((item) {
      if (item is Map<String, dynamic>) {
        return Expense.fromJson(item);
      }
      return item as Expense;
    }).toList();

    final List<dynamic> allList = json['allTransactions'] as List<dynamic>? ?? [];
    final allTx = allList.map((item) {
      if (item is Map<String, dynamic>) {
        return Expense.fromJson(item);
      }
      return item as Expense;
    }).toList();

    return HomeOverviewDataModel(
      thisMonthSpend: (json['thisMonthSpend'] as num).toDouble(),
      walletBalance: (json['walletBalance'] as num).toDouble(),
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      recentTransactions: transactions,
      allTransactions: allTx,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thisMonthSpend': thisMonthSpend,
      'walletBalance': walletBalance,
      'budgetAmount': budgetAmount,
      'recentTransactions': recentTransactions.map((e) => e.toJson()).toList(),
      'allTransactions': allTransactions.map((e) => e.toJson()).toList(),
    };
  }
}
