import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/router/app_routes.dart';

/// App routing gatekeeper checking persistent authentication and onboarding status.
class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  @override
  void initState() {
    super.initState();
    // Using post-frame callback to ensure routing is executed outside layout builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateAuthRoute();
    });
  }

  Future<void> _evaluateAuthRoute() async {
    final sharedPrefs = sl<SharedPreferences>();
    final database = sl<AppDatabase>();

    final isUserLoggedIn = sharedPrefs.getBool('isUserLoggedIn') ?? false;

    if (isUserLoggedIn) {
      final uid = sharedPrefs.getString('loggedInUserId');
      if (uid != null) {
        final user = await database.getUserByUid(uid);
        if (user != null) {
          if (mounted) {
            context.read<UserCubit>().updateUserState(user);
          }
          if (user.isBudgetCompleted) {
            if (mounted) {
              context.go(AppRoutes.dashboard.path);
            }
            return;
          } else {
            if (mounted) {
              context.go(AppRoutes.auth.expenseDetailsSurvey.path, extra: uid);
            }
            return;
          }
        }
      }
      // If user session exists but record is missing, redirect to login
      if (mounted) {
        context.go(AppRoutes.auth.login.path);
      }
    } else {
      final isOnboardingCompleted =
          sharedPrefs.getBool('isOnboardingCompleted') ?? false;
      if (mounted) {
        if (isOnboardingCompleted) {
          context.go(AppRoutes.auth.login.path);
        } else {
          context.go(AppRoutes.onboarding.path);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
