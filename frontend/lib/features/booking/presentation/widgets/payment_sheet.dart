import 'dart:async';

import 'package:flutter/material.dart';

import '../../../payment/domain/payment_record.dart';
import '../../../payment/presentation/payment_widgets.dart';

import '../pages/payment_checkout_page.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

/// Dialog tóm tắt đơn + tạo thanh toán chuyển khoản (SePay)
Future<void> showPaymentSheet(BuildContext context, Booking booking) {
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: _PaymentSheet(booking: booking),
      ),
    ),
  );
}

class _PaymentSheet extends StatefulWidget {
  final Booking booking;

  const _PaymentSheet({required this.booking});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet>
    with WidgetsBindingObserver {
  bool _loading = false;
  bool _checking = false;
  PaymentCheckout? _checkout;
  String? _paymentStatus;
  String? _statusError;
  String? _statusNotice;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted &&
          !_loading &&
          !_checking &&
          _checkout != null &&
          _paymentStatus == 'PENDING' &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
        _checkStatus();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkStatus();
  }

  Future<void> _checkStatus({
    bool waitForIpn = false,
    bool notify = false,
  }) async {
    String? feedback;
    final checkout = _checkout;
    if (checkout == null || _checking || !mounted) return;
    setState(() {
      _checking = true;
      _statusError = null;
      _statusNotice = null;
    });
    try {
      for (var attempt = 0; attempt < (waitForIpn ? 6 : 1); attempt++) {
        final status = await getIt<BookingRepository>().getPaymentStatus(
          checkout.paymentId,
        );
        if (!mounted) return;
        setState(() => _paymentStatus = status);
        if (status != 'PENDING') break;
        if (waitForIpn && attempt < 5) {
          await Future<void>.delayed(const Duration(seconds: 2));
          if (!mounted) return;
        }
      }
      if (mounted) {
        setState(
          () => _statusNotice = paymentCheckMessage(_paymentStatus ?? ''),
        );
      }
      feedback = 'Đã kiểm tra: ${paymentCheckMessage(_paymentStatus ?? '')}';
    } catch (e) {
      feedback = readableError(e);
      if (mounted) setState(() => _statusError = feedback);
    } finally {
      if (mounted) {
        setState(() => _checking = false);
        if (notify && feedback != null) {
          AppFeedback.info(context, feedback);
        }
      }
    }
  }

  String get _statusLabel => switch (_paymentStatus) {
    'PAID' => 'Thanh toán thành công',
    'REVIEW_REQUIRED' =>
      'Đang đối soát thanh toán. Vui lòng không thanh toán lại.',
    'EXPIRED' => 'Thanh toán đã hết hạn',
    'FAILED' => 'Thanh toán không thành công',
    'CANCELLED' => 'Thanh toán đã hủy',
    _ => 'Chờ xác nhận thanh toán',
  };

  Future<void> _pay() async {
    if (_loading || _checking) return;
    setState(() => _loading = true);
    try {
      if (_checkout != null) {
        await _checkStatus();
        if (!mounted || _statusError != null || _paymentStatus != 'PENDING') {
          return;
        }
      }
      final checkout = await getIt<BookingRepository>().createPayment(
        widget.booking.id,
      );
      if (!mounted) return;
      setState(() {
        _checkout = checkout;
        _paymentStatus = checkout.status;
      });
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PaymentCheckoutPage(checkout: checkout),
        ),
      );
      if (mounted) await _checkStatus(waitForIpn: true);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.error(context, readableError(e), title: 'Lỗi thanh toán');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final paid = _paymentStatus == 'PAID';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: paid
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.secondaryMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  paid
                      ? Icons.check_circle_outline_rounded
                      : Icons.receipt_long_outlined,
                  color: paid ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paid ? 'Thanh toán thành công' : 'Thanh toán chuyến đi',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chuyển khoản qua SePay',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Đóng',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PaymentPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CHUYẾN ĐI', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Text(b.tourTitle ?? '--', style: AppTextStyles.labelBold),
                const SizedBox(height: 16),
                _tripLine(
                  Icons.calendar_today_outlined,
                  '${Formatters.date(b.departureDate)} · ${Formatters.time(b.startTime)}',
                ),
                const SizedBox(height: 8),
                _tripLine(
                  Icons.people_outline_rounded,
                  '${b.adultCount} người lớn · ${b.childCount} trẻ em',
                ),
                const Divider(height: 28),
                Text(
                  paid ? 'Số tiền đã thanh toán' : 'Số tiền cần thanh toán',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.vnd(_checkout?.amount ?? b.totalAmount),
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                if ((b.discountAmount ?? 0) > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Đã giảm ${Formatters.vnd(b.discountAmount)}',
                    style: AppTextStyles.caption,
                  ),
                ],
                if (_checkout != null) ...[
                  const SizedBox(height: 12),
                  PaymentStatusBadge(
                    status: _paymentStatus ?? _checkout!.status ?? '',
                  ),
                  const Divider(height: 28),
                  PaymentReferenceRow(
                    label: 'Mã hóa đơn',
                    value: _checkout!.invoiceNumber ?? '--',
                    copyable: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (paid)
            const PaymentNotice(
              message: 'Khoản thanh toán đã được xác nhận. Theo dõi chuyến đi trong Chuyến đi của tôi.',
            )
          else if (_statusNotice != null)
            PaymentNotice(message: _statusNotice!)
          else
            PaymentNotice(
              message: _checkout == null
                  ? (b.canPay
                        ? 'Đơn đặt tour đã được tạo. Hoàn tất thanh toán để xác nhận chuyến đi.'
                        : BookingStatus.label(b.status))
                  : _statusLabel,
            ),
          if (_statusError != null) ...[
            const SizedBox(height: 12),
            PaymentNotice(message: _statusError!, isError: true),
          ],
          const SizedBox(height: 20),
          if (b.canPay && (_checkout == null || _paymentStatus == 'PENDING'))
            ElevatedButton.icon(
              onPressed: (_loading || _checking) ? null : _pay,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_outline_rounded, size: 18),
              label: Text(
                _loading
                    ? 'Đang mở thanh toán…'
                    : (_checkout == null
                          ? AppStrings.payNow
                          : 'Tiếp tục thanh toán'),
              ),
            ),
          if (_checkout != null && !paid) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: (_checking || _loading)
                  ? null
                  : () => _checkStatus(waitForIpn: true, notify: true),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(_checking ? 'Đang kiểm tra…' : 'Kiểm tra thanh toán'),
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _checkout == null && b.canPay ? 'Thanh toán sau' : 'Đóng',
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripLine(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: AppColors.neutral),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
    ],
  );
}
