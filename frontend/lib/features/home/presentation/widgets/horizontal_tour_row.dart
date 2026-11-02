import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/presentation/widgets/tour_card.dart';

/// Tiêu đề section dùng chung có điểm nhấn Vàng + icon nền màu
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.icon, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: AppColors.primary, size: 17),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
            ),
          ),
          if (onSeeAll != null)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.seeAll,
                      style: AppTextStyles.badgeText.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: AppColors.primary,
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

/// Hàng ngang các tour
class HorizontalTourRow extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Tour> tours;
  final VoidCallback? onSeeAll;

  const HorizontalTourRow({
    super.key,
    required this.title,
    required this.tours,
    this.icon,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (tours.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, icon: icon, onSeeAll: onSeeAll),
        SizedBox(
          height: 256,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tours.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) =>
                TourCard(tour: tours[i], width: AppDimens.tourCardWidth),
          ),
        ),
      ],
    );
  }
}
