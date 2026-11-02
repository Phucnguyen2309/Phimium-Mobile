import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _PaymentSheetState extends State<_PaymentSheet> {
  bool _loading = false;
  PaymentCheckout? _checkout;

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      final checkout = await getIt<BookingRepository>().createPayment(widget.booking.id);
      if (!mounted) return;
      setState(() => _checkout = checkout);
      final url = checkout.checkoutUrl;
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(readableError(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return SafeArea(
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
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
            const SizedBox(height: 8),
            Text('Đã tạo đơn đặt tour',
                textAlign: TextAlign.center, style: AppTextStyles.heading3),
            const SizedBox(height: 4),
            Text(BookingStatus.label(b.status),
                textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
            const Divider(height: 28),
            _line('Tour', b.tourTitle ?? '--'),
            _line('Ngày đi', '${Formatters.date(b.departureDate)} ${Formatters.time(b.startTime)}'),
            _line('Số khách', '${b.adultCount} người lớn, ${b.childCount} trẻ em'),
            if ((b.discountAmount ?? 0) > 0) _line('Giảm giá', '- ${Formatters.vnd(b.discountAmount)}'),
            _line(AppStrings.total, Formatters.vnd(b.totalAmount), bold: true),
            if (_checkout != null) ...[
              const Divider(height: 28),
              _line('Mã hoá đơn', _checkout!.invoiceNumber ?? '--'),
              _line('Số tiền', Formatters.vnd(_checkout!.amount), bold: true),
              const SizedBox(height: 4),
              Text(
                'Vui lòng chuyển khoản đúng nội dung mã hoá đơn. '
                'Hệ thống sẽ tự xác nhận khi nhận được tiền.',
                style: AppTextStyles.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            if (_checkout == null)
              ElevatedButton(
                onPressed: _loading ? null : _pay,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                      )
                    : const Text(AppStrings.payNow),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_checkout == null ? 'Thanh toán sau' : 'Xong'),
            ),
          ],
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
