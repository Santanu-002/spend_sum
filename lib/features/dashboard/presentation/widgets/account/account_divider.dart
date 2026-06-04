import 'package:flutter/material.dart';
import 'package:spend_sum/core/theme/app_colors.dart';

class AccountDivider extends StatelessWidget {
  const AccountDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;

    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: themeExt.outlineVariant.withValues(alpha: 0.2),
    );
  }
}
