import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_cached_image.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/domain/repositories/tour_repository.dart';
import 'horizontal_tour_row.dart';

/// Chuyến đi sắp tới của user (GET /api/activity/joined).
/// Chỉ hiện khi đã đăng nhập và có chuyến; lỗi thì ẩn đi.
class UpcomingTripsSection extends StatefulWidget {
  const UpcomingTripsSection({super.key});

  @override
  State<UpcomingTripsSection> createState() => _UpcomingTripsSectionState();
}

class _UpcomingTripsSectionState extends State<UpcomingTripsSection> {
  late final Future<List<MyTrip>> _future = getIt<TourRepository>().getMyTrips();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MyTrip>>(
      future: _future,
      builder: (context, snapshot) {
        final trips = snapshot.data ?? const <MyTrip>[];
        if (snapshot.hasError || trips.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: AppStrings.upcomingTrips,
              icon: Icons.luggage_rounded,
              onSeeAll: () => context.push(AppRouter.myBookings),
            ),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _TripCard(trip: trips[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  final MyTrip trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tour/${trip.tourId}'),
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryMuted,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        child: Row(
          children: [
            AppCachedImage(
              imageUrl: trip.thumbnailUrl,
              width: 64,
              height: 72,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.tourTitle),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.date(trip.departureDate)} • ${Formatters.time(trip.startTime)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                  ),
                  if (trip.hostBuddyName != null)
                    Text('Buddy: ${trip.hostBuddyName}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
