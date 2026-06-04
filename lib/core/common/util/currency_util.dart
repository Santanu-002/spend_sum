/// Mappings of country code prefixes to their corresponding currency symbols.
///
/// Supported countries based on standard locale definitions:
/// - India (+91) -> ₹
/// - United States (+1) -> $
/// - United Kingdom (+44) -> £
/// - Singapore (+65) -> S$
/// - Australia (+61) -> A$
String getCurrencySymbol(String? phoneNumber) {
  if (phoneNumber == null) return '\$';

  // Standardize search string
  final cleanPhone = phoneNumber.trim();

  if (cleanPhone.startsWith('+91')) {
    return '₹';
  } else if (cleanPhone.startsWith('+44')) {
    return '£';
  } else if (cleanPhone.startsWith('+65')) {
    return 'S\$';
  } else if (cleanPhone.startsWith('+61')) {
    return 'A\$';
  } else if (cleanPhone.startsWith('+1')) {
    return '\$';
  }

  return '\$'; // Default fallback symbol
}
