import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/buddy/presentation/pages/buddy_workspace_page.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import 'app_router.dart';

/// Khung chính có Bottom Navigation: Trang chủ / Khám phá / Yêu thích / Tài khoản
/// Nếu tài khoản đang đăng nhập có role BUDDY thì hiển thị thẳng Cổng Điều Hành Buddy (giống Web).
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    AppRouter.home,
    AppRouter.explore,
    AppRouter.wishlist,
    AppRouter.profile,
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _tabs.indexWhere((t) => location.startsWith(t));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated && authState.user.isBuddy) {
          return const BuddyWorkspacePage();
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.bottomNav,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: _selectedIndex(context),
                onTap: (i) => context.go(_tabs[i]),
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.neutral,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: AppStrings.home,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore_rounded),
                    label: AppStrings.explore,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border_rounded),
                    activeIcon: Icon(Icons.favorite_rounded),
                    label: AppStrings.wishlist,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: AppStrings.profile,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
