import 'package:flutter/foundation.dart';

/// Represents a route definition with a name and a path.
@immutable
class AppRoute {
  final String name;
  final String path;

  const AppRoute({required this.name, required this.path});
}

/// Centralized route declarations for the SpendSum application.
class AppRoutes {
  AppRoutes._();

  static const onboarding = AppRoute(name: 'onboarding', path: '/onboarding');

  static const auth = _AuthRoutes();

  static const dashboard = AppRoute(name: 'dashboard', path: '/dashboard');

  static const addTransaction =
      AppRoute(name: 'add-transaction', path: '/add-transaction');

  static const addCategory =
      AppRoute(name: 'add-category', path: '/add-category');
}

/// Private class to group and categorize authentication-related routes.
class _AuthRoutes {
  const _AuthRoutes();

  AppRoute get login => const AppRoute(name: 'login', path: '/login');

  AppRoute get registration =>
      const AppRoute(name: 'registration', path: '/registration');

  AppRoute get expenseDetailsSurvey => const AppRoute(
    name: 'expense-details-survey',
    path: '/expense-details-survey',
  );
}
