import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/features/auth/presentation/pages/auth_gate_page.dart';
import 'package:spend_sum/features/auth/presentation/pages/expense_details_survey_page.dart';
import 'package:spend_sum/features/auth/presentation/pages/login_page.dart';
import 'package:spend_sum/features/auth/presentation/pages/registration_page.dart';
import 'package:spend_sum/features/dashboard/presentation/pages/add_category_page.dart';
import 'package:spend_sum/features/dashboard/presentation/pages/add_transaction_page.dart';
import 'package:spend_sum/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:spend_sum/features/dashboard/presentation/pages/profile_settings_page.dart';
import 'package:spend_sum/features/dashboard/presentation/pages/edit_profile_page.dart';
import 'package:spend_sum/features/onboarding/presentation/pages/onboarding_page.dart';

import 'package:spend_sum/features/dashboard/presentation/pages/wallet_page.dart';

/// AppRouter defines the GoRouter configuration and pages getters for the application.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Static getter for the main GoRouter configuration.
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AuthGatePage()),
      GoRoute(
        path: AppRoutes.onboarding.path,
        name: AppRoutes.onboarding.name,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.auth.login.path,
        name: AppRoutes.auth.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.auth.registration.path,
        name: AppRoutes.auth.registration.name,
        builder: (context, state) {
          final uid = state.extra as String;
          return RegistrationPage(uid: uid);
        },
      ),
      GoRoute(
        path: AppRoutes.auth.expenseDetailsSurvey.path,
        name: AppRoutes.auth.expenseDetailsSurvey.name,
        builder: (context, state) {
          final uid = state.extra as String;
          return ExpenseDetailsSurveyPage(uid: uid);
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard.path,
        name: AppRoutes.dashboard.name,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.addTransaction.path,
        name: AppRoutes.addTransaction.name,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AddTransactionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.vertical,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.addCategory.path,
        name: AppRoutes.addCategory.name,
        pageBuilder: (context, state) {
          final isExpense = state.extra as bool? ?? true;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: AddCategoryPage(isExpense: isExpense),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileSettings.path,
        name: AppRoutes.profileSettings.name,
        builder: (context, state) => const ProfileSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile.path,
        name: AppRoutes.editProfile.name,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.wallet.path,
        name: AppRoutes.wallet.name,
        builder: (context, state) {
          final initialBudget = state.extra as double? ?? 0.0;
          return WalletPage(initialBudget: initialBudget);
        },
      ),
    ],
  );
}
