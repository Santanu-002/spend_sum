import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';
import 'package:spend_sum/features/auth/domain/entities/country_code.dart';

/// Phone entry form component extracted as a dedicated Stateless widget.
class PhoneForm extends StatelessWidget {
  final CountryCode selectedCountry;
  final TextEditingController phoneController;
  final FocusNode phoneFocusNode;
  final String? phoneError;
  final List<CountryCode> countries;
  final ValueChanged<CountryCode?> onCountryChanged;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onSubmitted;

  const PhoneForm({
    super.key,
    required this.selectedCountry,
    required this.phoneController,
    required this.phoneFocusNode,
    required this.phoneError,
    required this.countries,
    required this.onCountryChanged,
    required this.onPhoneChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = context.colorscheme;

    return Column(
      key: const ValueKey('phone_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input container matching glassmorphic fintech design
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: themeExt.surfaceContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
            border: Border.all(
              color: phoneError != null
                  ? themeExt.error
                  : (phoneFocusNode.hasFocus
                        ? themeExt.primary
                        : themeExt.outlineVariant),
              width: phoneFocusNode.hasFocus ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Country Picker Dropdown Button
              DropdownButtonHideUnderline(
                child: DropdownButton<CountryCode>(
                  value: selectedCountry,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: themeExt.onSurfaceVariant,
                    size: 20,
                  ),
                  dropdownColor: themeExt.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusDefault,
                  ),
                  onChanged: onCountryChanged,
                  items: countries.map<DropdownMenuItem<CountryCode>>((
                    CountryCode country,
                  ) {
                    return DropdownMenuItem<CountryCode>(
                      value: country,
                      child: Row(
                        children: [
                          Text(
                            country.flag,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            country.code,
                            style: TextStyle(fontFamily: 'Inter', 
                              color: themeExt.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Vertical Divider
              Container(
                width: 1,
                height: 24,
                color: themeExt.outlineVariant,
                margin: const EdgeInsets.symmetric(horizontal: 12.0),
              ),

              // Mobile number input field
              Expanded(
                child: TextField(
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontFamily: 'Inter', 
                    color: themeExt.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(selectedCountry.maxLength),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter mobile number',
                    hintStyle: TextStyle(fontFamily: 'Inter', 
                      color: themeExt.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onPhoneChanged,
                  onSubmitted: (_) => onSubmitted(),
                ),
              ),
            ],
          ),
        ),

        // Error state feedback
        if (phoneError != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              phoneError!,
              style: TextStyle(fontFamily: 'Inter', 
                color: themeExt.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
