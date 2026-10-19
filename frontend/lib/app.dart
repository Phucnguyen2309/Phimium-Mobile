import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class AppShortDrama extends StatelessWidget {
  const AppShortDrama({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Wrap with MultiBlocProvider once AuthBloc is registered in DI
    // BlocProvider<AuthBloc>(
    //   create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()),
    // ),
    return MaterialApp.router(
      title: 'Short Drama',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
