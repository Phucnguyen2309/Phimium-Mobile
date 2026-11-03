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
import '../../../tour/presentation/widgets/tour_card.dart';
import 'horizontal_tour_row.dart';

/// Chuyến đi sắp tới của user (GET /api/activity/joined).
/// Chỉ hiện các chuyến chưa qua ngày/giờ khởi hành và chưa hủy/hoàn thành.
class UpcomingTripsSection extends StatefulWidget {
  const UpcomingTripsSection({super.key});

  @override
  State<UpcomingTripsSection> createState() => _UpcomingTripsSectionState();
}

class _UpcomingTripsSectionState extends State<UpcomingTripsSection> {
  late final Future<List<MyTrip>> _future = getIt<TourRepository>().getMyTrips();

  bool _isUpcoming(MyTrip trip, DateTime now) {
    final status = (trip.status ?? '').toUpperCase();
    if (status == 'CANCELLED' || status == 'COMPLETED') {
      return false;
    }
    final date = trip.departureDate;
    if (date == null) return false;

    final today = DateTime(now.year, now.month, now.day);
    final tripDay = DateTime(date.year, date.month, date.day);

    if (tripDay.isBefore(today)) {
      return false;
    }

    if (tripDay.isAtSameMomentAs(today)) {
      final timeStr = trip.endTime ?? trip.startTime;
      if (timeStr != null && timeStr.isNotEmpty) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 23;
          final m = int.tryParse(parts[1]) ?? 59;
          final tripDateTime = DateTime(date.year, date.month, date.day, h, m);
          if (tripDateTime.isBefore(now)) {
            return false;
          }
        }
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MyTrip>>(
      future: _future,
      builder: (context, snapshot) {
        final now = DateTime.now();
        final trips = (snapshot.data ?? const <MyTrip>[])
            .where((t) => _isUpcoming(t, now))
            .toList()
          ..sort((a, b) => a.departureDate!.compareTo(b.departureDate!));

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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AppCachedImage(
              imageUrl: trip.thumbnailUrl,
              width: 64,
              height: 72,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              placeholderIcon: trip.type.icon,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.tourTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.date(trip.departureDate)} • ${Formatters.time(trip.startTime)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (trip.hostBuddyName != null)
                    Text(
                      'Buddy: ${trip.hostBuddyName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
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
