import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Top bar for Home Page: Logo + VIP Coin Pill + Search + Profile Avatar
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Logo: CineShorts
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'CineShorts',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),

          // VIP Coin Pill Badge
          GestureDetector(
            onTap: () => context.push('/payment'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.vipBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.vipGold.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.vipGold,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'VIP',
                    style: AppTextStyles.badgeText.copyWith(
                      color: AppColors.vipGold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Search Icon Button
          GestureDetector(
            onTap: () => context.go('/search'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Profile Avatar Button
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C2C3E), Color(0xFF1E1E2C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight, width: 1),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.neutralLight,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
