import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_cached_image.dart';
import '../../../tour/domain/entities/tour.dart';
import 'horizontal_tour_row.dart';

/// Các tour có lịch khởi hành gần nhất
class DepartingSoonSection extends StatelessWidget {
  final List<Tour> tours;

  const DepartingSoonSection({super.key, required this.tours});

  @override
  Widget build(BuildContext context) {
    final items = tours.where((t) => t.upcomingDepartures.isNotEmpty).toList()
      ..sort((a, b) =>
          a.upcomingDepartures.first.date!.compareTo(b.upcomingDepartures.first.date!));
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Sắp khởi hành', icon: Icons.event_available_rounded),
        ...items.take(5).map((t) => _Item(tour: t)),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final Tour tour;

  const _Item({required this.tour});

  @override
  Widget build(BuildContext context) {
    final next = tour.upcomingDepartures.first;
    return GestureDetector(
      onTap: () => context.push('/tour/${tour.id}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            AppCachedImage(
              imageUrl: tour.thumbnailUrl,
              width: 64,
              height: 64,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tour.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.tourTitle),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.date(next.date)} • ${Formatters.time(next.startTime)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.secondaryDark),
                  ),
                ],
              ),
            ),
            Text(Formatters.vnd(tour.price), style: AppTextStyles.price.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
