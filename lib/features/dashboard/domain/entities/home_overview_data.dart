import 'package:equatable/equatable.dart';
import 'package:spend_sum/core/database/app_database.dart';

/// Domain Layer entity representing loaded overview dashboard/home metrics.
class HomeOverviewData extends Equatable {
  final double thisMonthSpend;
  final double walletBalance;
  final double budgetAmount;
  final List<Expense> recentTransactions;
  final List<Expense> allTransactions;

  const HomeOverviewData({
    required this.thisMonthSpend,
    required this.walletBalance,
    required this.budgetAmount,
    required this.recentTransactions,
    this.allTransactions = const [],
  });

  @override
  List<Object?> get props => [
        thisMonthSpend,
        walletBalance,
        budgetAmount,
        recentTransactions,
        allTransactions,
      ];
}
