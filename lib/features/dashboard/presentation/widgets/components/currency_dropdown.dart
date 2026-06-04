import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

import 'package:spend_sum/features/auth/domain/entities/country_code.dart';

class CurrencyDropdownField extends StatelessWidget {
  final String? value;
  final String defaultSymbol;
  final ValueChanged<String?> onChanged;
  final List<CountryCode> currencies;
  final bool enabled;

  const CurrencyDropdownField({
    super.key,
    required this.value,
    required this.defaultSymbol,
    required this.onChanged,
    required this.currencies,
    this.enabled = true,
  });

  List<DropdownMenuItem<String?>> _buildCurrencyItems() {
    String defaultLabel = defaultSymbol;
    final defaultMatch = currencies.where((c) => c.currencySymbol == defaultSymbol);
    if (defaultMatch.isNotEmpty) {
      defaultLabel = '${defaultMatch.first.currencyLabel} (${defaultMatch.first.currencySymbol})';
    } else {
      if (defaultSymbol == '₹') {
        defaultLabel = 'INR (₹)';
      } else if (defaultSymbol == '\$') {
        defaultLabel = 'USD (\$)';
      }
    }

    final List<DropdownMenuItem<String?>> items = [
      DropdownMenuItem<String?>(
        value: null,
        child: Text('$defaultLabel (Default)'),
      ),
    ];

    // Collect other currencies, avoiding duplicates of the default symbol
    // Group by symbol to ensure uniqueness
    final Set<String> seenSymbols = {defaultSymbol};
    for (final cc in currencies) {
      if (!seenSymbols.contains(cc.currencySymbol)) {
        seenSymbols.add(cc.currencySymbol);
        items.add(
          DropdownMenuItem<String?>(
            value: cc.currencySymbol,
            child: Text('${cc.currencyLabel} (${cc.currencySymbol})'),
          ),
        );
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final themeExt = theme.colorscheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Currency / Symbol',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeExt.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: themeExt.surfaceContainer,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusDefault,
            ),
            border: Border.all(
              color: themeExt.outlineVariant,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: themeExt.onSurfaceVariant,
              ),
              dropdownColor: themeExt.surfaceContainerHigh,
              style: GoogleFonts.inter(
                color: themeExt.onSurface,
                fontSize: 15,
              ),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusDefault,
              ),
              items: _buildCurrencyItems(),
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}
