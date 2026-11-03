import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Tài khoản - thông tin user lấy từ AuthBloc (/api/auth/me)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state is AuthAuthenticated ? state.user : null;
          return ListView(
            padding: const EdgeInsets.all(AppDimens.df),
            children: [
              user == null ? const _GuestHeader() : _UserHeader(user: user),
              const SizedBox(height: AppDimens.lg),
              if (user != null) ...[
                _MenuTile(
                  icon: Icons.luggage_outlined,
                  title: AppStrings.myTrips,
                  subtitle: 'Đơn đặt tour, thanh toán, hủy đơn',
                  onTap: () => context.push(AppRouter.myBookings),
                ),
                _MenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Lịch sử thanh toán',
                  subtitle: 'Xem giao dịch và kiểm tra thanh toán',
                  onTap: () => context.push(AppRouter.payments),
                ),
                _MenuTile(
                  icon: Icons.rate_review_outlined,
                  title: AppStrings.myReviews,
                  subtitle: 'Đánh giá chuyến đi & Buddy',
                  onTap: () => context.push(AppRouter.myReviews),
                ),
              ],
              _MenuTile(
                icon: Icons.favorite_border_rounded,
                title: AppStrings.wishlist,
                subtitle: 'Tour bạn đã lưu',
                onTap: () => context.go(AppRouter.wishlist),
              ),
              if (user != null)
                _MenuTile(
                  icon: Icons.logout_rounded,
                  title: AppStrings.logout,
                  color: AppColors.error,
                  onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chào bạn!', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            'Đăng nhập để đặt tour và theo dõi chuyến đi của bạn.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppDimens.md),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(140, 44),
            ),
            onPressed: () => context.push(AppRouter.login),
            child: const Text(AppStrings.login),
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final User user;

  const _UserHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final initial = user.fullName.isEmpty ? '?' : user.fullName.characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryMuted,
            child: Text(initial, style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: AppTextStyles.heading3),
                Text(user.email, style: AppTextStyles.bodyMedium),
                if (user.isBuddy)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Buddy',
                        style: AppTextStyles.badgeText.copyWith(color: AppColors.secondaryDark)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: c, size: 20),
        ),
        title: Text(title, style: AppTextStyles.labelBold.copyWith(color: color)),
        subtitle: subtitle == null ? null : Text(subtitle!, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
      ),
    );
  }
}
