import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Configure all dependencies using GetIt
///
/// TODO: Uncomment and wire up registrations as each feature
/// module's data/domain/presentation layers are fully implemented.
/// Currently only the Auth feature has complete implementations.
Future<void> configureDependencies() async {
  // ===== Core =====
  // getIt.registerLazySingleton<DioClient>(() => DioClient());

  // ===== Auth Feature (fully implemented) =====
  // Uncomment below once you want to connect to a real backend:
  //
  // getIt.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(client: getIt()),
  // );
  // getIt.registerLazySingleton<AuthLocalDataSource>(
  //   () => AuthLocalDataSourceImpl(),
  // );
  // getIt.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     remoteDataSource: getIt(),
  //     localDataSource: getIt(),
  //   ),
  // );
  // getIt.registerFactory(() => LoginUseCase(getIt()));
  // getIt.registerFactory(() => RegisterUseCase(getIt()));
  // getIt.registerFactory(() => LogoutUseCase(getIt()));
  // getIt.registerFactory(() => CheckAuthUseCase(getIt()));
  // getIt.registerFactory(() => AuthBloc(
  //       loginUseCase: getIt(),
  //       registerUseCase: getIt(),
  //       logoutUseCase: getIt(),
  //       checkAuthUseCase: getIt(),
  //     ));

  // ===== Other Features =====
  // Wire up as implemented: Home, Drama, Search, Bookmark, Comment, Payment, Profile
}
