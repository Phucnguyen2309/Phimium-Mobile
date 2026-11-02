import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/review/data/repositories/review_repository_impl.dart';
import '../../features/review/domain/repositories/review_repository.dart';
import '../../features/tour/data/datasources/tour_remote_datasource.dart';
import '../../features/tour/data/repositories/tour_repository_impl.dart';
import '../../features/tour/domain/repositories/tour_repository.dart';
import '../../features/wishlist/data/datasources/wishlist_local_datasource.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

/// Đăng ký toàn bộ dependency (GetIt)
Future<void> configureDependencies() async {
  // ===== Core =====
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // ===== Auth =====
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl());
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory(() => LoginUseCase(getIt()));
  getIt.registerFactory(() => RegisterUseCase(getIt()));
  getIt.registerFactory(() => VerifyOtpUseCase(getIt()));
  getIt.registerFactory(() => LogoutUseCase(getIt()));
  getIt.registerFactory(() => CheckAuthUseCase(getIt()));
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(getIt(), getIt(), getIt(), getIt(), getIt()),
  );

  // ===== Tour =====
  getIt.registerLazySingleton(() => TourRemoteDataSource(getIt()));
  getIt.registerLazySingleton<TourRepository>(() => TourRepositoryImpl(getIt()));

  // ===== Booking & Payment =====
  getIt.registerLazySingleton(() => BookingRemoteDataSource(getIt()));
  getIt.registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl(getIt()));

  // ===== Review =====
  getIt.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(getIt()));

  // ===== Wishlist (lưu local) =====
  final wishlist = WishlistLocalDataSource();
  await wishlist.load();
  getIt.registerSingleton<WishlistLocalDataSource>(wishlist);
}
