import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

/// Hộp thoại tóm tắt đơn + tạo thanh toán chuyển khoản (SePay)
Future<void> showPaymentSheet(BuildContext context, Booking booking) {
  return showDialog<void>(
    context: context,
    builder: (_) => _PaymentDialog(booking: booking),
  );
}

class _PaymentDialog extends StatefulWidget {
  final Booking booking;

  const _PaymentDialog({required this.booking});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  bool _loading = false;
  PaymentCheckout? _checkout;

  Future<void> _openSepayCheckout(PaymentCheckout checkout) async {
    final url = checkout.checkoutUrl;
    if (url == null || url.isEmpty) return;

    // Nếu SePay yêu cầu submit form POST kèm fields (giống Web submitSepayForm)
    if (checkout.fields.isNotEmpty) {
      final inputs = checkout.fields.entries
          .map((e) =>
              '<input type="hidden" name="${const HtmlEscape().convert(e.key)}" value="${const HtmlEscape().convert(e.value)}" />')
          .join();
      final html = '''
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Đang chuyển tới SePay...</title></head>
<body onload="document.forms[0].submit()">
  <form method="POST" action="${const HtmlEscape().convert(url)}">$inputs</form>
</body>
</html>
''';
      final dataUri = Uri.dataFromString(
        html,
        mimeType: 'text/html',
        encoding: utf8,
      );
      final launched = await launchUrl(dataUri, mode: LaunchMode.inAppBrowserView);
      if (launched) return;
    }

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      final checkout =
          await getIt<BookingRepository>().createPayment(widget.booking.id);
      if (!mounted) return;
      setState(() => _checkout = checkout);
      await _openSepayCheckout(checkout);
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
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thông tin đơn đặt tour',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 4),
              Text(
                BookingStatus.label(b.status),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const Divider(height: 24),
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
              _line(AppStrings.total, Formatters.vnd(b.totalAmount), bold: true),
              if (_checkout != null) ...[
                const Divider(height: 24),
                _line('Mã hoá đơn', _checkout!.invoiceNumber ?? '--'),
                _line('Số tiền', Formatters.vnd(_checkout!.amount), bold: true),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Vui lòng chuyển khoản đúng nội dung mã hoá đơn. '
                    'Hệ thống sẽ tự xác nhận khi nhận được tiền.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (_checkout == null)
                ElevatedButton(
                  onPressed: _loading ? null : _pay,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Text(AppStrings.payNow),
                ),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                ),
                child: Text(_checkout == null ? 'Thanh toán sau' : 'Hoàn tất'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
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
