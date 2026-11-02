import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_cached_image.dart';
import '../../../wishlist/data/datasources/wishlist_local_datasource.dart';
import '../../domain/entities/tour.dart';

/// Màu & icon theo loại tour
extension TourTypeStyle on TourType {
  Color get color => switch (this) {
        TourType.food => AppColors.foodTour,
        TourType.history => AppColors.historyTour,
        TourType.unknown => AppColors.primary,
      };

  IconData get icon => switch (this) {
        TourType.food => Icons.ramen_dining_rounded,
        TourType.history => Icons.account_balance_rounded,
        TourType.unknown => Icons.travel_explore_rounded,
      };
}

/// Nhãn nhỏ "Food tour" / "History tour"
class TourTypeBadge extends StatelessWidget {
  final TourType type;
  final bool onImage;

  const TourTypeBadge({super.key, required this.type, this.onImage = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: onImage ? type.color : type.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 12, color: onImage ? Colors.white : type.color),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: AppTextStyles.badgeText.copyWith(
              color: onImage ? Colors.white : type.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút tim yêu thích (lưu local)
class WishlistButton extends StatelessWidget {
  final String tourId;
  final double size;

  const WishlistButton({super.key, required this.tourId, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final wishlist = getIt<WishlistLocalDataSource>();
    return ListenableBuilder(
      listenable: wishlist,
      builder: (context, _) {
        final saved = wishlist.contains(tourId);
        return GestureDetector(
          onTap: () => wishlist.toggle(tourId),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: Icon(
              saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: size * 0.55,
              color: saved ? AppColors.secondary : AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

/// Thẻ tour dọc - dùng cho hàng ngang & lưới
class TourCard extends StatelessWidget {
  final Tour tour;
  final double? width;

  const TourCard({super.key, required this.tour, this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tour/${tour.id}'),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppCachedImage(
                  imageUrl: tour.thumbnailUrl,
                  height: AppDimens.tourCardImageHeight,
                  width: double.infinity,
                  placeholderIcon: tour.type.icon,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimens.radiusLg),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: TourTypeBadge(type: tour.type, onImage: true),
                ),
                Positioned(right: 8, top: 8, child: WishlistButton(tourId: tour.id, size: 30)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.tourTitle,
                  ),
                  const SizedBox(height: 4),
                  if (tour.locationName != null)
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 13, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            tour.locationName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.tourLocation,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: Formatters.vnd(tour.price), style: AppTextStyles.price),
                        TextSpan(text: AppStrings.perPerson, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ tour ngang - dùng cho danh sách tìm kiếm / yêu thích
class TourListTile extends StatelessWidget {
  final Tour tour;

  const TourListTile({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tour/${tour.id}'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCachedImage(
              imageUrl: tour.thumbnailUrl,
              width: 96,
              height: 96,
              placeholderIcon: tour.type.icon,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TourTypeBadge(type: tour.type),
                      const Spacer(),
                      WishlistButton(tourId: tour.id, size: 28),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(tour.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.tourTitle),
                  const SizedBox(height: 4),
                  if (tour.locationName != null)
                    Text(tour.locationName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.tourLocation),
                  const SizedBox(height: 6),
                  Text(Formatters.vnd(tour.price), style: AppTextStyles.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
