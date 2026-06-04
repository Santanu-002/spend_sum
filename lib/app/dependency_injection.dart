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
import 'package:spend_sum/features/dashboard/domain/usecases/delete_transaction_usecase.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/home_cubit.dart';
import 'package:spend_sum/features/auth/data/repository/country_currency_repository.dart';
import 'package:spend_sum/features/auth/domain/repository/i_country_currency_repository.dart';
import 'package:spend_sum/features/auth/domain/usecases/get_country_currencies.dart';
import 'package:spend_sum/features/onboarding/presentation/di/onboarding_di.dart';

import 'package:spend_sum/features/auth/presentation/cubit/auth_gate_cubit.dart';
import 'package:spend_sum/features/auth/presentation/cubit/country_currency_cubit.dart';
import 'package:spend_sum/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/category_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/transaction_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/budget_cubit.dart';
import 'package:spend_sum/features/dashboard/presentation/cubit/profile_cubit.dart';

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
  final database = AppDatabase();
  sl.registerSingleton<AppDatabase>(database);

  // Country Currency Configuration
  final countryCurrencyRepository = CountryCurrencyRepository(database: database);
  await countryCurrencyRepository.initCache();
  sl.registerSingleton<ICountryCurrencyRepository>(countryCurrencyRepository);
  sl.registerLazySingleton<GetCountryCurrenciesUseCase>(
    () => GetCountryCurrenciesUseCase(sl()),
  );

  // User Session Cubit
  sl.registerLazySingleton<UserCubit>(
    () => UserCubit(authRepository: sl()),
  );

  // Dashboard Home dependencies
  sl.registerLazySingleton<IHomeLocalDataSource>(() => HomeLocalDataSource(sl()));
  sl.registerLazySingleton<IHomeRepository>(() => HomeRepository(sl()));
  sl.registerLazySingleton<GetHomeDataUseCase>(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton<GetCategoriesUseCase>(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton<AddCategoryUseCase>(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton<DeleteTransactionUseCase>(() => DeleteTransactionUseCase(sl()));
  sl.registerFactory<HomeCubit>(() => HomeCubit(getHomeDataUseCase: sl()));

  // New Cubits
  sl.registerFactory<AuthGateCubit>(
    () => AuthGateCubit(
      isOnboardingCompletedUseCase: sl(),
      getActiveUserUseCase: sl(),
    ),
  );
  sl.registerFactory<CountryCurrencyCubit>(
    () => CountryCurrencyCubit(getCountryCurrenciesUseCase: sl()),
  );
  sl.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(
      completeOnboardingUseCase: sl(),
      isOnboardingCompletedUseCase: sl(),
    ),
  );
  sl.registerFactory<CategoryCubit>(
    () => CategoryCubit(
      getCategoriesUseCase: sl(),
      addCategoryUseCase: sl(),
    ),
  );
  sl.registerFactory<TransactionCubit>(
    () => TransactionCubit(
      homeRepository: sl(),
      deleteTransactionUseCase: sl(),
    ),
  );
  sl.registerFactory<BudgetCubit>(
    () => BudgetCubit(homeRepository: sl()),
  );
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      updateProfileUseCase: sl(),
      countryCurrencyRepository: sl(),
    ),
  );

  // Onboarding Feature Dependencies
  initOnboardingDependencies();

  // Auth Feature Dependencies
  initAuthDependencies();
}
