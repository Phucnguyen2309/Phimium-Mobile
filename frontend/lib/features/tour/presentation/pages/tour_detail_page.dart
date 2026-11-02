import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_cached_image.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/tour.dart';
import '../../domain/repositories/tour_repository.dart';
import '../widgets/itinerary_timeline.dart';
import '../widgets/tour_card.dart';

/// Chi tiết tour - dữ liệu từ GET /api/activity/{id}
class TourDetailPage extends StatefulWidget {
  final String tourId;

  const TourDetailPage({super.key, required this.tourId});

  @override
  State<TourDetailPage> createState() => _TourDetailPageState();
}

class _TourDetailPageState extends State<TourDetailPage> {
  late Future<TourDetail> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = getIt<TourRepository>().getTourDetail(widget.tourId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView<TourDetail>(
        future: _future,
        onRetry: () => setState(_load),
        builder: (context, detail) => _DetailBody(detail: detail),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final TourDetail detail;

  const _DetailBody({required this.detail});

  Tour get tour => detail.tour;

  @override
  Widget build(BuildContext context) {
    final departures = tour.upcomingDepartures;
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.background,
              leading: Padding(
                padding: const EdgeInsets.all(6),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.92),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: WishlistButton(tourId: tour.id, size: 38),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: AppCachedImage(
                  imageUrl: tour.thumbnailUrl ??
                      (detail.imageUrls.isNotEmpty ? detail.imageUrls.first : null),
                  width: double.infinity,
                  height: 320,
                  placeholderIcon: tour.type.icon,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TourTypeBadge(type: tour.type),
                        const Spacer(),
                        if (detail.averageRating > 0) ...[
                          const Icon(Icons.star_rounded, color: AppColors.ratingStar, size: 18),
                          const SizedBox(width: 2),
                          Text('${detail.averageRating}/5', style: AppTextStyles.labelBold),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(tour.title, style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.place_outlined,
                      text: [tour.locationName, tour.address]
                          .where((e) => e != null && e.isNotEmpty)
                          .join(' • '),
                    ),
                    if (tour.totalDurationMinutes > 0)
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        text: 'Khoảng ${Formatters.duration(tour.totalDurationMinutes)}',
                      ),
                    if (tour.maxParticipants != null)
                      _InfoRow(
                        icon: Icons.groups_2_outlined,
                        text: 'Tối đa ${tour.maxParticipants} khách',
                      ),
                    if (tour.tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tour.tags
                            .map((t) => Chip(
                                  label: Text(t),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                    if (detail.hostBuddyName != null) ...[
                      const SizedBox(height: AppDimens.lg),
                      _BuddyCard(detail: detail),
                    ],
                    if ((tour.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppDimens.lg),
                      Text(AppStrings.description, style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      Text(tour.description!, style: AppTextStyles.bodyMedium),
                    ],
                    if (tour.itineraryStops.isNotEmpty) ...[
                      const SizedBox(height: AppDimens.lg),
                      Row(
                        children: [
                          Text(AppStrings.itinerary, style: AppTextStyles.heading3),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/tour/${tour.id}/itinerary'),
                            child: const Text(AppStrings.seeAll),
                          ),
                        ],
                      ),
                      ItineraryTimeline(stops: tour.itineraryStops.take(3).toList()),
                    ],
                    const SizedBox(height: AppDimens.lg),
                    Text(AppStrings.departures, style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    if (departures.isEmpty)
                      Text(AppStrings.noDepartures, style: AppTextStyles.bodyMedium)
                    else
                      ...departures.take(4).map((d) => _DepartureTile(departure: d)),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BookingBar(tour: tour, enabled: departures.isNotEmpty),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _BuddyCard extends StatelessWidget {
  final TourDetail detail;

  const _BuddyCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: [
          ClipOval(
            child: AppCachedImage(
              imageUrl: detail.hostAvatarUrl,
              width: 48,
              height: 48,
              placeholderIcon: Icons.person_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.yourBuddy, style: AppTextStyles.caption),
                Text(detail.hostBuddyName!, style: AppTextStyles.labelBold),
                if ((detail.hostIntroduction ?? '').isNotEmpty)
                  Text(
                    detail.hostIntroduction!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
          if (detail.hostBuddyId != null)
            TextButton(
              onPressed: () => context.push(
                '/buddy/${detail.hostBuddyId}/reviews'
                '?name=${Uri.encodeComponent(detail.hostBuddyName ?? '')}',
              ),
              child: const Text(AppStrings.reviews),
            ),
        ],
      ),
    );
  }
}

class _DepartureTile extends StatelessWidget {
  final TourDeparture departure;

  const _DepartureTile({required this.departure});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Text(Formatters.date(departure.date), style: AppTextStyles.labelBold),
          const SizedBox(width: 8),
          Text(
            '${Formatters.time(departure.startTime)} - ${Formatters.time(departure.endTime)}',
            style: AppTextStyles.bodyMedium,
          ),
          const Spacer(),
          if (departure.capacity != null)
            Text('${departure.capacity} chỗ', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  final Tour tour;
  final bool enabled;

  const _BookingBar({required this.tour, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Giá từ', style: AppTextStyles.caption),
              Text.rich(TextSpan(children: [
                TextSpan(text: Formatters.vnd(tour.price), style: AppTextStyles.price.copyWith(fontSize: 18)),
                TextSpan(text: AppStrings.perPerson, style: AppTextStyles.caption),
              ])),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: enabled ? () => context.push('/tour/${tour.id}/book') : null,
              child: const Text(AppStrings.bookNow),
            ),
          ),
        ],
      ),
    );
  }
}
