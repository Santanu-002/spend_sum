import 'package:spend_sum/app/dependency_injection.dart';
import 'package:spend_sum/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:spend_sum/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:spend_sum/features/auth/data/repository/auth_repository.dart';
import 'package:spend_sum/features/auth/domain/repository/i_auth_repository.dart';
import 'package:spend_sum/features/auth/domain/usecases/register_user.dart';
import 'package:spend_sum/features/auth/domain/usecases/send_otp.dart';
import 'package:spend_sum/features/auth/domain/usecases/submit_budget_details.dart';
import 'package:spend_sum/features/auth/domain/usecases/verify_otp.dart';
import 'package:spend_sum/features/auth/presentation/bloc/auth_bloc.dart';

/// Initializes dependency injection for the Authentication feature module.
void initAuthDependencies() {
  // Data Sources
  sl.registerLazySingleton<IAuthLocalDataSource>(
    () => AuthLocalDataSource(database: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSource(),
  );

  // Repository Implementation (injecting local and remote data sources)
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(localDataSource: sl(), remoteDataSource: sl()),
  );

  // Domain Layer Use Cases
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => SubmitBudgetDetails(sl()));

  // Presentation Layer BLoC
  sl.registerFactory(
    () => AuthBloc(
      sendOtp: sl(),
      verifyOtp: sl(),
      registerUser: sl(),
      submitBudgetDetails: sl(),
    ),
  );
}
