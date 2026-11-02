// ============================================================
// Phimium Mobile - Saigon food & history tour cùng Buddy địa phương
// Feature-based Architecture + BLoC
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Theme sáng -> icon status bar màu tối
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bottomNav,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await configureDependencies();
  getIt<AuthBloc>().add(AuthCheckRequested());

  runApp(const PhimiumApp());
}
