import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// CTA tìm Buddy địa phương (thay cho thẻ "nhận xu mỗi ngày" cũ)
class BuddyMatchCard extends StatelessWidget {
  const BuddyMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.sunsetGradient,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.diversity_3_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.findBuddy,
                    style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  AppStrings.findBuddyDesc,
                  style: AppTextStyles.caption.copyWith(color: Colors.white, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.go(AppRouter.explore),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Khám phá',
                style: AppTextStyles.labelBold.copyWith(color: AppColors.secondaryDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
