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
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../../tour/domain/repositories/tour_repository.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../widgets/payment_sheet.dart';

/// Đặt tour - POST /api/v1/registrations & báo giá POST /api/v1/pricing/quote
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
  bool _loadingQuote = false;
  PriceQuote? _quote;
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

  Future<void> _fetchQuote({bool showFeedback = false}) async {
    if (_departure == null) return;
    setState(() => _loadingQuote = true);
    try {
      final quote = await getIt<BookingRepository>().getPriceQuote(
        departureId: _departure!.id,
        adultCount: _adults,
        childCount: _children,
        couponCode: _couponController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _quote = quote);
      if (showFeedback && (quote.message ?? '').isNotEmpty) {
        if ((quote.discountAmount ?? 0) > 0) {
          AppFeedback.success(
            context,
            quote.message!,
            title: 'Đã áp dụng ưu đãi',
          );
        } else {
          AppFeedback.info(context, quote.message!);
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (showFeedback) {
        AppFeedback.error(
          context,
          readableError(e),
          title: 'Mã giảm giá không hợp lệ',
        );
      }
    } finally {
      if (mounted) setState(() => _loadingQuote = false);
    }
  }

  Future<void> _submit() async {
    if (context.read<AuthBloc>().state is! AuthAuthenticated) {
      AppFeedback.info(
        context,
        AppStrings.loginRequired,
        title: 'Yêu cầu đăng nhập',
      );
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
      AppFeedback.success(
        context,
        'Đơn đặt tour đã được tạo. Vui lòng hoàn tất thanh toán!',
        title: 'Đặt tour thành công',
      );
      await showPaymentSheet(context, booking);
      if (mounted) context.pushReplacement(AppRouter.myBookings);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, readableError(e), title: 'Không thể đặt tour');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          final subtotal = _quote?.subtotal ?? _estimate(tour);
          final discount = _quote?.discountAmount ?? 0;
          final total = _quote?.totalAmount ?? (subtotal - discount);

          return ListView(
            padding: const EdgeInsets.all(AppDimens.df),
            children: [
              // ── 1. THÔNG TIN CA TOUR ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tour.title, style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    Text('Chọn ngày khởi hành', style: AppTextStyles.labelBold),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: departures.map((d) {
                        final selected = _departure?.id == d.id;
                        return ChoiceChip(
                          selected: selected,
                          onSelected: (_) {
                            setState(() => _departure = d);
                            _fetchQuote();
                          },
                          selectedColor: AppColors.primary,
                          label: Text(
                            '${Formatters.date(d.date)} • ${Formatters.time(d.startTime)}',
                            style: AppTextStyles.chipText.copyWith(
                              color:
                                  selected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── 2. SỐ LƯỢNG KHÁCH & ĐIỂM ĐÓN ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Counter(
                      label: AppStrings.adults,
                      price: _quote?.adultUnitPrice ?? tour.price,
                      value: _adults,
                      min: 1,
                      onChanged: (v) {
                        setState(() => _adults = v);
                        _fetchQuote();
                      },
                    ),
                    const Divider(height: 16),
                    _Counter(
                      label: AppStrings.children,
                      price: _quote?.childUnitPrice ??
                          tour.childPrice ??
                          tour.price,
                      value: _children,
                      min: 0,
                      onChanged: (v) {
                        setState(() => _children = v);
                        _fetchQuote();
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pickupController,
                      decoration: const InputDecoration(
                        hintText: AppStrings.pickupLocation,
                        prefixIcon: Icon(Icons.place_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: AppStrings.couponCode,
                              prefixIcon: const Icon(
                                Icons.local_offer_outlined,
                                size: 20,
                              ),
                              suffixIcon: _couponController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        _couponController.clear();
                                        setState(() {});
                                        _fetchQuote();
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: (_departure != null && !_loadingQuote)
                              ? () => _fetchQuote(showFeedback: true)
                              : null,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(96, 48),
                          ),
                          child: _loadingQuote
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(AppStrings.applyCoupon),
                        ),
                      ],
                    ),
                    if ((_quote?.message ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _quote!.message!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: (_quote?.discountAmount ?? 0) > 0
                              ? AppColors.success
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── 3. TÓM TẮT CHI PHÍ & XÁC NHẬN ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CheckboxListTile(
                      value: _acceptedTerms,
                      onChanged: (v) =>
                          setState(() => _acceptedTerms = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primary,
                      title: Text(
                        AppStrings.safetyTerms,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    const Divider(height: 24),
                    if (discount > 0) ...[
                      Row(
                        children: [
                          Text('Tạm tính', style: AppTextStyles.bodyMedium),
                          const Spacer(),
                          Text(
                            Formatters.vnd(subtotal),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Giảm giá${_quote?.appliedCouponCode != null ? ' (${_quote!.appliedCouponCode})' : ''}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.success),
                          ),
                          const Spacer(),
                          Text(
                            '- ${Formatters.vnd(discount)}',
                            style: AppTextStyles.labelBold
                                .copyWith(color: AppColors.success),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Text(
                          '${AppStrings.total} (tạm tính)',
                          style: AppTextStyles.labelBold,
                        ),
                        const Spacer(),
                        Text(
                          Formatters.vnd(total),
                          style: AppTextStyles.price.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Giá được tính tự động từ hệ thống (đã gồm mã giảm giá nếu có).',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          (_departure != null && _acceptedTerms && !_submitting)
                              ? _submit
                              : null,
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Text(AppStrings.confirmBooking),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3,
            ),
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
