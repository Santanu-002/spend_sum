import 'package:flutter/material.dart';

/// Spacing and icon matching helper for category visualization.
class CategoryDetails {
  final IconData icon;
  final Color color;

  const CategoryDetails({required this.icon, required this.color});
}

/// Resolves standard icon and styling configuration from category key names.
CategoryDetails getCategoryDetails(String categoryName) {
  final nameLower = categoryName.toLowerCase().trim();
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
