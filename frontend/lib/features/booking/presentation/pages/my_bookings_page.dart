import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../widgets/payment_sheet.dart';

/// Danh sách đơn đặt tour của tôi - GET /api/v1/registrations/me
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<BookingRepository>().getMyBookings();
  }

  void _reload() => setState(() {
        _future = getIt<BookingRepository>().getMyBookings();
      });

  Future<void> _cancel(Booking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đơn đặt tour?'),
        content: Text(b.tourTitle ?? ''),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy đơn', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await getIt<BookingRepository>().cancelBooking(b.id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(readableError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myTrips)),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: AsyncView<List<Booking>>(
          future: _future,
          onRetry: _reload,
          isEmpty: (list) => list.isEmpty,
          empty: const EmptyStateWidget(
            message: 'Bạn chưa đặt tour nào.',
            icon: Icons.luggage_outlined,
          ),
          builder: (context, bookings) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final b = bookings[i];
              return _BookingCard(
                booking: b,
                onPay: () async {
                  await showPaymentSheet(context, b);
                  _reload();
                },
                onCancel: () => _cancel(b),
                onReview: () async {
                  await context.push('/bookings/${b.id}/review');
                  _reload();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onPay;
  final VoidCallback onCancel;
  final VoidCallback onReview;

  const _BookingCard({
    required this.booking,
    required this.onPay,
    required this.onCancel,
    required this.onReview,
  });

  Color get _statusColor => switch (booking.status) {
        'CONFIRMED' || 'COMPLETED' => AppColors.success,
        'CANCELLED' => AppColors.error,
        'PENDING_PAYMENT' || 'PAYMENT_REVIEW' => AppColors.warning,
        _ => AppColors.info,
      };

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final cancellable = b.status != 'CANCELLED' && b.status != 'COMPLETED' && b.status != 'IN_PROGRESS';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(b.tourTitle ?? 'Tour',
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.tourTitle),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(BookingStatus.label(b.status),
                    style: AppTextStyles.badgeText.copyWith(color: _statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${Formatters.date(b.departureDate)} • ${Formatters.time(b.startTime)}',
              style: AppTextStyles.caption),
          Text('${b.adultCount} người lớn, ${b.childCount} trẻ em'
              '${b.buddyName != null ? ' • Buddy: ${b.buddyName}' : ''}',
              style: AppTextStyles.caption),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(Formatters.vnd(b.totalAmount), style: AppTextStyles.price),
              const Spacer(),
              if (cancellable)
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Hủy', style: TextStyle(color: AppColors.error)),
                ),
              if (b.canPay)
                ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38)),
                  child: const Text(AppStrings.payNow),
                ),
              if (b.canReview)
                OutlinedButton(onPressed: onReview, child: const Text(AppStrings.reviews)),
            ],
          ),
        ],
      ),
    );
  }
}
