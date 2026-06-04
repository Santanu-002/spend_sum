import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_sum/core/common/cubit/user_cubit.dart';
import 'package:spend_sum/core/database/app_database.dart';
import 'package:spend_sum/core/theme/theme_cubit.dart';
import 'package:spend_sum/features/auth/presentation/di/auth_di.dart';
import 'package:spend_sum/features/dashboard/data/datasources/home_local_datasource.dart';
import 'package:spend_sum/features/dashboard/data/repository/home_repository.dart';
import 'package:spend_sum/features/dashboard/domain/repository/i_home_repository.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/add_category_usecase.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/get_categories_usecase.dart';
import 'package:spend_sum/features/dashboard/domain/usecases/get_home_data_usecase.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';

/// Service Locator instance.
final GetIt sl = GetIt.instance;

/// Initialize all cross-cutting dependencies.
Future<void> initDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  // Local Drift Database Singleton
  sl.registerSingleton<AppDatabase>(AppDatabase());

  // User Session Cubit
  sl.registerLazySingleton<UserCubit>(
    () => UserCubit(localDataSource: sl()),
  );

  // Dashboard Home dependencies
  sl.registerLazySingleton<IHomeLocalDataSource>(() => HomeLocalDataSource(sl()));
  sl.registerLazySingleton<IHomeRepository>(() => HomeRepository(sl()));
  sl.registerLazySingleton<GetHomeDataUseCase>(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton<GetCategoriesUseCase>(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton<AddCategoryUseCase>(() => AddCategoryUseCase(sl()));
  sl.registerFactory<HomeCubit>(() => HomeCubit(getHomeDataUseCase: sl()));

  // Auth Feature Dependencies
  initAuthDependencies();
}
