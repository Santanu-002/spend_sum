import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/common/util/category_icon_util.dart';

/// A standard, premium styled transaction list item showing category, date, title and amount.
class TransactionTile extends StatelessWidget {
  final Expense transaction;
  final String currencySymbol;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencySymbol,
    this.onTap,
  });

  String _formatTxDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppThemeExtension>()!;
    final catDetails = getCategoryDetails(transaction.category);
    final prefix = transaction.isIncome ? '+' : '-';
    final amtColor =
        transaction.isIncome ? const Color(0xFF4CD964) : const Color(0xFFFF5252);

    return Container(
      decoration: BoxDecoration(
        color: themeExt.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: catDetails.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(catDetails.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeExt.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTxDate(transaction.date),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: themeExt.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$prefix$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: amtColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: themeExt.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
