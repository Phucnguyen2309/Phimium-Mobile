import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/presentation/widgets/tour_card.dart';

/// Bộ lọc loại tour: Tất cả / Food tour / History tour
/// [selected] = null nghĩa là "Tất cả"
class TourTypeChipsBar extends StatelessWidget {
  final TourType? selected;
  final ValueChanged<TourType?> onChanged;

  const TourTypeChipsBar({super.key, required this.selected, required this.onChanged});

  static const List<TourType?> options = [null, TourType.food, TourType.history];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = options[index];
          final isSelected = type == selected;
          final label = type?.label ?? AppStrings.allTours;
          final icon = type?.icon ?? Icons.apps_rounded;
          return GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.chipText.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
