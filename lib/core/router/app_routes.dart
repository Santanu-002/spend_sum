import 'package:flutter/foundation.dart';

/// Represents a route definition with a name and a path.
@immutable
class AppRoute {
  final String name;
  final String path;

  const AppRoute({
    required this.name,
    required this.path,
  });
}

/// Centralized route declarations for the SpendSum application.
class AppRoutes {
  AppRoutes._();

  static const onboarding = AppRoute(
    name: 'onboarding',
    path: '/onboarding',
  );

  static const auth = _AuthRoutes();
}

/// Private class to group and categorize authentication-related routes.
class _AuthRoutes {
  const _AuthRoutes();

  AppRoute get login => const AppRoute(
        name: 'login',
        path: '/login',
      );
}
