import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_feedback.dart';
import '../domain/payment_record.dart';

String paymentInvoiceLabel(String invoice) {
  if (invoice.isEmpty || invoice == '--') return 'Chưa có mã hóa đơn';
  final code = invoice.length > 10
      ? invoice.substring(invoice.length - 10)
      : invoice;
  return 'Hóa đơn #${code.toUpperCase()}';
}

String paymentDateTime(DateTime? value) {
  if (value == null) return '--';
  return '${Formatters.date(value)} · '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

String paymentDepartureLabel(DateTime date, String? startTime) =>
    'Khởi hành ${Formatters.date(date)}'
    '${startTime == null ? '' : ' · ${Formatters.time(startTime)}'}';

Color paymentStatusColor(String? status) => switch (status) {
  'PAID' => AppColors.success,
  'FAILED' || 'CANCELLED' => AppColors.error,
  'EXPIRED' || 'REVIEW_REQUIRED' => AppColors.secondaryDark,
  _ => AppColors.primary,
};

IconData paymentStatusIcon(String? status) => switch (status) {
  'PAID' => Icons.check_circle_outline_rounded,
  'FAILED' || 'CANCELLED' => Icons.error_outline_rounded,
  'EXPIRED' => Icons.timer_off_outlined,
  'REVIEW_REQUIRED' => Icons.support_agent_rounded,
  _ => Icons.schedule_rounded,
};

class PaymentStatusBadge extends StatelessWidget {
  final String status;
  const PaymentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = paymentStatusColor(status);
    final label = switch (status) {
      'PAID' => 'Đã thanh toán',
      'PENDING' => 'Đang chờ xác nhận',
      'EXPIRED' => 'Đã hết hạn',
      'FAILED' => 'Chưa thành công',
      'REVIEW_REQUIRED' => 'Cần đối soát',
      _ => paymentStatusLabel(status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Color.lerp(color, AppColors.textPrimary, 0.35),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PaymentPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const PaymentPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.df),
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
    ),
    child: child,
  );
}

class PaymentNotice extends StatelessWidget {
  final String message;
  final bool isError;
  const PaymentNotice({super.key, required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.primary;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.info_outline_rounded,
              color: color,
              size: 20,
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(child: Text(message, style: AppTextStyles.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

class PaymentReferenceRow extends StatelessWidget {
  final String label, value;
  final bool copyable;
  const PaymentReferenceRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  Future<void> _copy(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (context.mounted) AppFeedback.info(context, 'Đã sao chép $label');
    } catch (_) {
      if (context.mounted) {
        AppFeedback.error(context, 'Chưa sao chép được. Vui lòng thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: AppDimens.xs),
              SelectableText(value, style: AppTextStyles.labelMedium),
            ],
          ),
        ),
        if (copyable)
          IconButton(
            tooltip: 'Sao chép $label',
            onPressed: () => _copy(context),
            icon: const Icon(Icons.copy_outlined, size: 18),
          ),
      ],
    ),
  );
}
