import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/domain/repositories/tour_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../widgets/payment_sheet.dart';

/// Đặt tour (thay cho màn mua xu cũ) - POST /api/v1/registrations
class BookingPage extends StatefulWidget {
  final String tourId;

  const BookingPage({super.key, required this.tourId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late Future<TourDetail> _future;
  TourDeparture? _departure;
  int _adults = 1;
  int _children = 0;
  bool _acceptedTerms = false;
  bool _submitting = false;
  final _pickupController = TextEditingController();
  final _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = getIt<TourRepository>().getTourDetail(widget.tourId);
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  double _estimate(Tour tour) =>
      (tour.price ?? 0) * _adults + (tour.childPrice ?? tour.price ?? 0) * _children;

  Future<void> _submit() async {
    if (context.read<AuthBloc>().state is! AuthAuthenticated) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.loginRequired)));
      context.push(AppRouter.login);
      return;
    }
    if (_departure == null || !_acceptedTerms) return;

    setState(() => _submitting = true);
    try {
      final booking = await getIt<BookingRepository>().createBooking(
        departureId: _departure!.id,
        adultCount: _adults,
        childCount: _children,
        safetyTermsAccepted: _acceptedTerms,
        pickupLocation: _pickupController.text.trim(),
        couponCode: _couponController.text.trim(),
      );
      if (!mounted) return;
      await showPaymentSheet(context, booking);
      if (mounted) context.pushReplacement(AppRouter.myBookings);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(readableError(e))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.booking)),
      body: AsyncView<TourDetail>(
        future: _future,
        onRetry: () => setState(() {
          _future = getIt<TourRepository>().getTourDetail(widget.tourId);
        }),
        builder: (context, detail) {
          final tour = detail.tour;
          final departures = tour.upcomingDepartures;
          if (departures.isEmpty) {
            return const EmptyStateWidget(
              message: AppStrings.noDepartures,
              icon: Icons.event_busy_rounded,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppDimens.df),
            children: [
              Text(tour.title, style: AppTextStyles.heading3),
              const SizedBox(height: AppDimens.lg),
              Text('Chọn ngày khởi hành', style: AppTextStyles.labelBold),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: departures.map((d) {
                  final selected = _departure?.id == d.id;
                  return ChoiceChip(
                    selected: selected,
                    onSelected: (_) => setState(() => _departure = d),
                    selectedColor: AppColors.primary,
                    label: Text(
                      '${Formatters.date(d.date)} • ${Formatters.time(d.startTime)}',
                      style: AppTextStyles.chipText.copyWith(
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimens.lg),
              _Counter(
                label: AppStrings.adults,
                price: tour.price,
                value: _adults,
                min: 1,
                onChanged: (v) => setState(() => _adults = v),
              ),
              _Counter(
                label: AppStrings.children,
                price: tour.childPrice ?? tour.price,
                value: _children,
                min: 0,
                onChanged: (v) => setState(() => _children = v),
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: _pickupController,
                decoration: const InputDecoration(
                  hintText: AppStrings.pickupLocation,
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: _couponController,
                decoration: const InputDecoration(
                  hintText: AppStrings.couponCode,
                  prefixIcon: Icon(Icons.local_offer_outlined),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              CheckboxListTile(
                value: _acceptedTerms,
                onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                title: Text(AppStrings.safetyTerms, style: AppTextStyles.bodyMedium),
              ),
              const Divider(height: 32),
              Row(
                children: [
                  Text('${AppStrings.total} (tạm tính)', style: AppTextStyles.bodyMedium),
                  const Spacer(),
                  Text(Formatters.vnd(_estimate(tour)),
                      style: AppTextStyles.price.copyWith(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Giá cuối cùng do hệ thống tính (đã gồm mã giảm giá nếu có).',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: AppDimens.lg),
              ElevatedButton(
                onPressed:
                    (_departure != null && _acceptedTerms && !_submitting) ? _submit : null,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                      )
                    : const Text(AppStrings.confirmBooking),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final double? price;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  const _Counter({
    required this.label,
    required this.price,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelBold),
              Text(Formatters.vnd(price), style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          IconButton.outlined(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded, size: 18),
          ),
          SizedBox(
            width: 36,
            child: Text('$value', textAlign: TextAlign.center, style: AppTextStyles.heading3),
          ),
          IconButton.outlined(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
