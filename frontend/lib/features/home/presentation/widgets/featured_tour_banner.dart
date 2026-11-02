import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_cached_image.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/presentation/widgets/tour_card.dart';

/// Banner trượt các tour nổi bật (lấy từ dữ liệu thật)
class FeaturedTourBanner extends StatefulWidget {
  final List<Tour> tours;

  const FeaturedTourBanner({super.key, required this.tours});

  @override
  State<FeaturedTourBanner> createState() => _FeaturedTourBannerState();
}

class _FeaturedTourBannerState extends State<FeaturedTourBanner> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tours.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: AppDimens.bannerHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.tours.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _BannerItem(tour: widget.tours[i]),
            ),
          ),
        ),
        if (widget.tours.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.tours.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.secondary : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                  border: i == _page
                      ? Border.all(color: AppColors.primary, width: 0.8)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final Tour tour;

  const _BannerItem({required this.tour});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tour/${tour.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppCachedImage(
              imageUrl: tour.thumbnailUrl,
              placeholderIcon: tour.type.icon,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.imageOverlay),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TourTypeBadge(type: tour.type, onImage: true),
                  const SizedBox(height: 8),
                  Text(
                    tour.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heroTitle,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (tour.locationName != null) ...[
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            tour.locationName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${Formatters.vnd(tour.price)}${AppStrings.perPerson}',
                          style: AppTextStyles.badgeText.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
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
      ),
    );
  }
}
