import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/features/onboarding/presentation/pages/onboarding_page.dart';

/// AppRouter defines the GoRouter configuration and pages getters for the application.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Static getter for the main GoRouter configuration.
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.onboarding.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding.path,
        name: AppRoutes.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
    ],
  );
}
