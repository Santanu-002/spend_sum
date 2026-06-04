import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/router/app_router.dart';
import 'package:spend_sum/core/theme/app_theme.dart';
import 'package:spend_sum/core/theme/theme_cubit.dart';

/// The root widget of the SpendSum application.
class SpendSumApp extends StatelessWidget {
  const SpendSumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => sl<ThemeCubit>()),
        BlocProvider<UserCubit>(create: (context) => sl<UserCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'SpendSum',
            routerConfig: AppRouter.router,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
