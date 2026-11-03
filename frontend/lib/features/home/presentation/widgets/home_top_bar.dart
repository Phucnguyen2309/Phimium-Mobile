import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Hero Header Trang chủ đồng bộ giao diện Web:
/// - Nền Navy chuyển sắc (#162456 -> #1E3A8A) + điểm nhấn Vàng (#FDC700)
/// - Thanh tìm kiếm nổi kèm nút Vàng "Khám phá"
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng trên: Logo + Lời chào + Tài khoản
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 34,
                    height: 34,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final name =
                        state is AuthAuthenticated ? state.user.fullName : null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                name == null
                                    ? 'SAIGON LOCAL BUDDY'
                                    : 'XIN CHÀO, ${name.toUpperCase()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.badgeText.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Phimium Travel',
                          style: AppTextStyles.labelBold.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () => context.go(AppRouter.profile),
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tiêu đề Hero
          RichText(
            text: TextSpan(
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 19,
                height: 1.25,
              ),
              children: const [
                TextSpan(text: 'Khám phá Sài Gòn '),
                TextSpan(
                  text: 'theo cách bản địa',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Thanh tìm kiếm nổi kèm nút Vàng #FDC700
          GestureDetector(
            onTap: () => context.go(AppRouter.explore),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tìm Food Tour, di sản, điểm đến...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Khám phá',
                          style: AppTextStyles.badgeText.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
