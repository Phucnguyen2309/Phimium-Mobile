import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Tài khoản - thông tin user lấy từ AuthBloc (/api/auth/me)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await AppFeedback.confirm(
      context,
      title: 'Xác nhận đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Phimium?',
      confirmLabel: 'Đăng xuất',
      cancelLabel: 'Hủy',
      isDanger: true,
      icon: Icons.logout_rounded,
    );
    if (!ok || !context.mounted) return;
    context.read<AuthBloc>().add(AuthLogoutRequested());
    AppFeedback.info(
      context,
      'Bạn đã đăng xuất khỏi tài khoản.',
      title: 'Đã đăng xuất',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = state is AuthAuthenticated ? state.user : null;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                user == null ? const _GuestHeader() : _UserHeader(user: user),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'TIỆN ÍCH CÁ NHÂN',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (user != null) ...[
                  if (user.isBuddy)
                    _MenuTile(
                      icon: Icons.badge_rounded,
                      title: AppStrings.buddyWorkspace,
                      subtitle: 'Lịch dẫn tour, điểm danh đoàn khách, đánh giá',
                      iconColor: const Color(0xFFB45309),
                      badgeBg: const Color(0xFFFEF3C7),
                      onTap: () => context.push(AppRouter.buddyWorkspace),
                    ),
                  _MenuTile(
                    icon: Icons.luggage_rounded,
                    title: AppStrings.myTrips,
                    subtitle: 'Đơn đặt tour, thanh toán, check-in, hủy đơn',
                    iconColor: const Color(0xFF2563EB),
                    badgeBg: const Color(0xFFDBEAFE),
                    onTap: () => context.push(AppRouter.myBookings),
                  ),
                  _MenuTile(
                    icon: Icons.receipt_long_rounded,
                    title: AppStrings.paymentHistory,
                    subtitle: 'Hoá đơn và giao dịch thanh toán',
                    iconColor: const Color(0xFF059669),
                    badgeBg: const Color(0xFFD1FAE5),
                    onTap: () => context.push(AppRouter.paymentHistory),
                  ),
                  _MenuTile(
                    icon: Icons.star_rounded,
                    title: AppStrings.myReviews,
                    subtitle: 'Đánh giá chuyến đi & Buddy',
                    iconColor: const Color(0xFFD97706),
                    badgeBg: const Color(0xFFFEF3C7),
                    onTap: () => context.push(AppRouter.myReviews),
                  ),
                ],
                _MenuTile(
                  icon: Icons.favorite_rounded,
                  title: AppStrings.wishlist,
                  subtitle: 'Danh sách các tour bạn đã lưu',
                  iconColor: const Color(0xFFE11D48),
                  badgeBg: const Color(0xFFFFE4E6),
                  onTap: () => context.go(AppRouter.wishlist),
                ),
                if (user != null) ...[
                  const SizedBox(height: 6),
                  _MenuTile(
                    icon: Icons.logout_rounded,
                    title: AppStrings.logout,
                    subtitle: 'Thoát khỏi phiên đăng nhập hiện tại',
                    iconColor: AppColors.error,
                    badgeBg: const Color(0xFFFFE4E6),
                    titleColor: AppColors.error,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GuestHeader extends StatelessWidget {
  const _GuestHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              'PHIMIUM TRAVEL',
              style: AppTextStyles.badgeText.copyWith(
                color: AppColors.secondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chào bạn!',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Đăng nhập để đặt tour, lưu hành trình yêu thích và theo dõi chuyến đi của bạn.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(160, 44),
            ),
            onPressed: () => context.push(AppRouter.login),
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text(AppStrings.login),
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
    final initial = user.fullName.isEmpty
        ? '?'
        : user.fullName.characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.secondary, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primary,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
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
  final Color iconColor;
  final Color badgeBg;
  final Color? titleColor;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.badgeBg,
    required this.onTap,
    this.subtitle,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: AppTextStyles.labelBold.copyWith(
            color: titleColor ?? AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitle!, style: AppTextStyles.caption),
              ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
