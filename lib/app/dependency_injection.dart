import 'package:get_it/get_it.dart';
import 'package:spend_sum/core/theme/theme_cubit.dart';

/// Service Locator instance.
final GetIt sl = GetIt.instance;

/// Initialize all cross-cutting dependencies.
Future<void> initDependencies() async {
  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}
