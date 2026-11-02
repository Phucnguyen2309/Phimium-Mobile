import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_cached_image.dart';
import '../../domain/entities/tour.dart';

/// Dòng thời gian các điểm dừng của tour
class ItineraryTimeline extends StatelessWidget {
  final List<ItineraryStop> stops;
  final bool showImages;

  const ItineraryTimeline({super.key, required this.stops, this.showImages = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stops.length; i++)
          _StopItem(stop: stops[i], index: i, isLast: i == stops.length - 1, showImage: showImages),
      ],
    );
  }
}

class _StopItem extends StatelessWidget {
  final ItineraryStop stop;
  final int index;
  final bool isLast;
  final bool showImage;

  const _StopItem({
    required this.stop,
    required this.index,
    required this.isLast,
    required this.showImage,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.badgeText.copyWith(color: Colors.white, fontSize: 11),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stop.title, style: AppTextStyles.labelBold),
                  if (stop.durationMinutes != null)
                    Text(
                      Formatters.duration(stop.durationMinutes),
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                    ),
                  if ((stop.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(stop.description!, style: AppTextStyles.bodyMedium),
                  ],
                  if (showImage && (stop.imageUrl ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AppCachedImage(
                      imageUrl: stop.imageUrl,
                      height: 150,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
