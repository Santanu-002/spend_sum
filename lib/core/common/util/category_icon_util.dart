import 'package:flutter/material.dart';

/// Spacing and icon matching helper for category visualization.
class CategoryDetails {
  final IconData icon;
  final Color color;

  const CategoryDetails({required this.icon, required this.color});
}

// Global cache for custom categories
final Map<String, CategoryDetails> _customCategoriesCache = {};

/// Registers a custom category in the cache so [getCategoryDetails] can resolve it dynamically.
void registerCustomCategory({
  required String name,
  required String iconHex,
  required String colorHex,
}) {
  try {
    final nameLower = name.toLowerCase().trim();
    final iconData = _getConstIconFromHex(iconHex);
    final cleanHex = colorHex.replaceAll('#', '').replaceAll('0x', '');
    final Color color;
    if (cleanHex.length == 6) {
      color = Color(int.parse('FF$cleanHex', radix: 16));
    } else if (cleanHex.length == 8) {
      color = Color(int.parse(cleanHex, radix: 16));
    } else {
      color = const Color(0xFF5856D6);
    }
    _customCategoriesCache[nameLower] = CategoryDetails(icon: iconData, color: color);
  } catch (_) {}
}

/// Dynamic IconData constructor call is avoided to support Flutter font tree-shaking.
IconData _getConstIconFromHex(String hex) {
  final cleanHex = hex.toLowerCase().trim().replaceAll('0x', '');
  switch (cleanHex) {
    case 'f58f':
      return Icons.attach_money_rounded;
    case 'f0170':
      return Icons.shopping_basket_rounded;
    case 'f0108':
      return Icons.restaurant_rounded;
    case 'f6b3':
      return Icons.directions_car_rounded;
    case 'f7f5':
      return Icons.home_rounded;
    case 'f012e':
      return Icons.school_rounded;
    case 'f767':
      return Icons.fitness_center_rounded;
    case 'f8b0':
      return Icons.medical_services_rounded;
    case 'f016f':
      return Icons.shopping_bag_rounded;
    case 'f54c':
      return Icons.airplanemode_active_rounded;
    case 'f02bf':
      return Icons.wifi_rounded;
    case 'f00e1':
      return Icons.receipt_long_rounded;
    case 'f0128':
      return Icons.savings_rounded;
    case 'f02c7':
      return Icons.work_rounded;
    case 'f0254':
      return Icons.trending_up_rounded;
    case 'f61a':
      return Icons.card_giftcard_rounded;
    case 'f614':
      return Icons.campaign_rounded;
    case 'f5b3':
      return Icons.beach_access_rounded;
    case 'f87a':
      return Icons.local_play_rounded;
    case 'f03b4':
      return Icons.water_drop_rounded;
    case 'f0343':
      return Icons.key_rounded;
    case 'f016b':
      return Icons.shield_rounded;
    case 'f002a':
      return Icons.notifications_rounded;
    case 'f0058':
      return Icons.payments_rounded;
    case 'f00e6':
      return Icons.redeem_rounded;
    case 'f0156':
      return Icons.settings_backup_restore_rounded;
    case 'f676':
      return Icons.corporate_fare_rounded;
    default:
      return Icons.attach_money_rounded;
  }
}

/// Resolves standard or custom icon and styling configuration from category key names.
CategoryDetails getCategoryDetails(String categoryName) {
  final nameLower = categoryName.toLowerCase().trim();

  // Check the custom category cache first
  if (_customCategoriesCache.containsKey(nameLower)) {
    return _customCategoriesCache[nameLower]!;
  }

  switch (nameLower) {
    case 'groceries':
      return const CategoryDetails(
        icon: Icons.shopping_basket_rounded,
        color: Color(0xFF00B475),
      );
    case 'travel':
      return const CategoryDetails(
        icon: Icons.airplanemode_active_rounded,
        color: Color(0xFF5AC8FA),
      );
    case 'car':
      return const CategoryDetails(
        icon: Icons.directions_car_rounded,
        color: Color(0xFF007AFF),
      );
    case 'home':
      return const CategoryDetails(
        icon: Icons.home_rounded,
        color: Color(0xFF5856D6),
      );
    case 'insurances':
      return const CategoryDetails(
        icon: Icons.shield_rounded,
        color: Color(0xFF00B475),
      );
    case 'education':
      return const CategoryDetails(
        icon: Icons.school_rounded,
        color: Color(0xFF5856D6),
      );
    case 'marketing':
      return const CategoryDetails(
        icon: Icons.campaign_rounded,
        color: Color(0xFFFF9500),
      );
    case 'shopping':
      return const CategoryDetails(
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFF00B475),
      );
    case 'internet':
      return const CategoryDetails(
        icon: Icons.wifi_rounded,
        color: Color(0xFF5856D6),
      );
    case 'water':
      return const CategoryDetails(
        icon: Icons.water_drop_rounded,
        color: Color(0xFF007AFF),
      );
    case 'rent':
      return const CategoryDetails(
        icon: Icons.key_rounded,
        color: Color(0xFFFF9500),
      );
    case 'gym':
      return const CategoryDetails(
        icon: Icons.fitness_center_rounded,
        color: Color(0xFFFF9500),
      );
    case 'subscription':
      return const CategoryDetails(
        icon: Icons.notifications_rounded,
        color: Color(0xFF5856D6),
      );
    case 'vacation':
      return const CategoryDetails(
        icon: Icons.beach_access_rounded,
        color: Color(0xFF00B475),
      );
    case 'food':
      return const CategoryDetails(
        icon: Icons.restaurant_rounded,
        color: Color(0xFFFF2D55),
      );
    case 'entertainment':
      return const CategoryDetails(
        icon: Icons.local_play_rounded,
        color: Color(0xFFFF9500),
      );
    case 'health':
      return const CategoryDetails(
        icon: Icons.medical_services_rounded,
        color: Color(0xFFFF3B30),
      );
    case 'bills':
      return const CategoryDetails(
        icon: Icons.receipt_long_rounded,
        color: Color(0xFFFFCC00),
      );
    case 'savings':
      return const CategoryDetails(
        icon: Icons.savings_rounded,
        color: Color(0xFF00B475),
      );
    case 'salary':
      return const CategoryDetails(
        icon: Icons.attach_money_rounded,
        color: Color(0xFF00B475),
      );
    case 'freelance':
      return const CategoryDetails(
        icon: Icons.work_rounded,
        color: Color(0xFF5AC8FA),
      );
    case 'investments':
      return const CategoryDetails(
        icon: Icons.trending_up_rounded,
        color: Color(0xFF5856D6),
      );
    case 'gifts':
      return const CategoryDetails(
        icon: Icons.card_giftcard_rounded,
        color: Color(0xFFFF2D55),
      );
    case 'bonus':
      return const CategoryDetails(
        icon: Icons.redeem_rounded,
        color: Color(0xFFFF9500),
      );
    case 'refunds':
      return const CategoryDetails(
        icon: Icons.settings_backup_restore_rounded,
        color: Color(0xFF007AFF),
      );
    case 'rental':
      return const CategoryDetails(
        icon: Icons.corporate_fare_rounded,
        color: Color(0xFFFFCC00),
      );
    case 'other income':
      return const CategoryDetails(
        icon: Icons.payments_rounded,
        color: Color(0xFFFFCC00),
      );
    default:
      return const CategoryDetails(
        icon: Icons.attach_money_rounded,
        color: Color(0xFF5856D6),
      );
  }
}
