import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/tour.dart';
import '../../domain/repositories/tour_repository.dart';
import '../widgets/itinerary_timeline.dart';

/// Lịch trình đầy đủ của tour (thay cho màn xem video cũ)
class TourItineraryPage extends StatefulWidget {
  final String tourId;

  const TourItineraryPage({super.key, required this.tourId});

  @override
  State<TourItineraryPage> createState() => _TourItineraryPageState();
}

class _TourItineraryPageState extends State<TourItineraryPage> {
  late Future<TourDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<TourRepository>().getTourDetail(widget.tourId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.itinerary)),
      body: AsyncView<TourDetail>(
        future: _future,
        onRetry: () => setState(() {
          _future = getIt<TourRepository>().getTourDetail(widget.tourId);
        }),
        isEmpty: (d) => d.tour.itineraryStops.isEmpty,
        empty: const EmptyStateWidget(
          message: 'Tour này chưa có lịch trình chi tiết.',
          icon: Icons.route_outlined,
        ),
        builder: (context, detail) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(detail.tour.title, style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            ItineraryTimeline(stops: detail.tour.itineraryStops, showImages: true),
          ],
        ),
      ),
    );
  }
}
