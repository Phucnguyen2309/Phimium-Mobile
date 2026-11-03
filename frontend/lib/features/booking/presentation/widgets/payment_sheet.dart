import 'dart:async';

import 'package:flutter/material.dart';

import '../../../payment/domain/payment_record.dart';

import '../pages/payment_checkout_page.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

/// Bottom sheet tóm tắt đơn + tạo thanh toán chuyển khoản (SePay)
Future<void> showPaymentSheet(BuildContext context, Booking booking) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _PaymentSheet(booking: booking),
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
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(feedback)));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(readableError(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                _paymentStatus == 'PAID'
                    ? Icons.check_circle_rounded
                    : Icons.receipt_long_rounded,
                color: AppColors.success,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                _paymentStatus == 'PAID'
                    ? 'Thanh toán thành công'
                    : 'Đã tạo đơn đặt tour',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 4),
              Text(
                _paymentStatus == 'PAID'
                    ? 'Đã được hệ thống xác nhận'
                    : (_checkout == null
                          ? BookingStatus.label(b.status)
                          : _statusLabel),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const Divider(height: 28),
              _line('Tour', b.tourTitle ?? '--'),
              _line(
                'Ngày đi',
                '${Formatters.date(b.departureDate)} ${Formatters.time(b.startTime)}',
              ),
              _line(
                'Số khách',
                '${b.adultCount} người lớn, ${b.childCount} trẻ em',
              ),
              if ((b.discountAmount ?? 0) > 0)
                _line('Giảm giá', '- ${Formatters.vnd(b.discountAmount)}'),
              _line(
                AppStrings.total,
                Formatters.vnd(b.totalAmount),
                bold: true,
              ),
              if (_checkout != null) ...[
                const Divider(height: 28),
                _line('Mã hoá đơn', _checkout!.invoiceNumber ?? '--'),
                _line('Số tiền', Formatters.vnd(_checkout!.amount), bold: true),
                const SizedBox(height: 4),
                Text(
                  _paymentStatus == 'PAID'
                      ? 'Bạn có thể xem thông tin chuyến đi trong Đơn đặt tour.'
                      : 'Nếu vừa thanh toán, vui lòng chờ xác nhận; không chuyển tiền lần nữa.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              if (b.canPay &&
                  (_checkout == null || _paymentStatus == 'PENDING'))
                ElevatedButton(
                  onPressed: (_loading || _checking) ? null : _pay,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : Text(
                          _checkout == null
                              ? AppStrings.payNow
                              : 'Mở lại thanh toán',
                        ),
                ),
              if (_checkout != null && _paymentStatus != 'PAID')
                TextButton(
                  onPressed: (_checking || _loading)
                      ? null
                      : () => _checkStatus(waitForIpn: true, notify: true),
                  child: Text(
                    _checking
                        ? 'Đang kiểm tra thanh toán…'
                        : 'Kiểm tra thanh toán',
                  ),
                ),
              if (_statusNotice != null)
                Semantics(
                  liveRegion: true,
                  child: Text(_statusNotice!, style: AppTextStyles.bodySmall),
                ),
              if (_statusError != null)
                Text(_statusError!, style: AppTextStyles.bodySmall),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_checkout == null ? 'Thanh toán sau' : 'Xong'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: bold ? AppTextStyles.price : AppTextStyles.labelMedium,
          ),
        ),
      ],
    ),
  );
}
