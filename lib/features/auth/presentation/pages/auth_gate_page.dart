import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/router/app_routes.dart';
import 'package:spend_sum/features/auth/presentation/cubit/auth_gate_cubit.dart';

/// App routing gatekeeper checking persistent authentication and onboarding status.
class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthGateCubit>(
      create: (context) => sl<AuthGateCubit>()..evaluateAuthRoute(),
      child: const AuthGatePageContent(),
    );
  }
}

class AuthGatePageContent extends StatelessWidget {
  const AuthGatePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthGateCubit, AuthGateState>(
      listener: (context, state) {
        if (state is AuthGateOnboardingRequired) {
          context.goNamed(AppRoutes.onboarding.name);
        } else if (state is AuthGateLoginRequired) {
          context.goNamed(AppRoutes.auth.login.name);
        } else if (state is AuthGateSurveyRequired) {
          context.goNamed(AppRoutes.auth.expenseDetailsSurvey.name, extra: state.uid);
        } else if (state is AuthGateDashboardRequired) {
          context.read<UserCubit>().updateUserState(state.user);
          context.goNamed(AppRoutes.dashboard.name);
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
