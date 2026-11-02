import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/presentation/widgets/tour_card.dart';

/// Tiêu đề section dùng chung
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.icon, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.secondary, size: 20),
            const SizedBox(width: 6),
          ],
          Expanded(child: Text(title, style: AppTextStyles.heading3)),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text(AppStrings.seeAll)),
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
          height: 250,
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
