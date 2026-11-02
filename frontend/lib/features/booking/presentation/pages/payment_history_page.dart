import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

/// Lịch sử thanh toán của khách - GET /api/payment/me & GET /api/payment/{id}
class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late Future<List<PaymentRecord>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = getIt<BookingRepository>().getMyPayments();
  }

  void _showDetail(PaymentRecord item) {
    showDialog<void>(
      context: context,
      builder: (_) => _PaymentDetailDialog(paymentId: item.id, initial: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.paymentHistory)),
      body: RefreshIndicator(
        onRefresh: () async => setState(_load),
        child: AsyncView<List<PaymentRecord>>(
          future: _future,
          onRetry: () => setState(_load),
          isEmpty: (list) => list.isEmpty,
          empty: const EmptyStateWidget(
            message: 'Bạn chưa có giao dịch thanh toán nào.',
            icon: Icons.receipt_long_outlined,
          ),
          builder: (context, items) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = items[i];
              final color = switch (p.status) {
                'SUCCESS' || 'PAID' || 'COMPLETED' => AppColors.success,
                'FAILED' || 'CANCELLED' => AppColors.error,
                _ => AppColors.warning,
              };
              return InkWell(
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                onTap: () => _showDetail(p),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.receipt_rounded, color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.invoiceNumber ?? 'Hoá đơn #${p.id.substring(0, 6)}',
                              style: AppTextStyles.labelBold,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Formatters.date(p.paidAt ?? p.createdAt),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(Formatters.vnd(p.amount), style: AppTextStyles.price),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              p.status ?? '--',
                              style: AppTextStyles.badgeText.copyWith(color: color),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaymentDetailDialog extends StatefulWidget {
  final String paymentId;
  final PaymentRecord initial;

  const _PaymentDetailDialog({required this.paymentId, required this.initial});

  @override
  State<_PaymentDetailDialog> createState() => _PaymentDetailDialogState();
}

class _PaymentDetailDialogState extends State<_PaymentDetailDialog> {
  late Future<PaymentRecord> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<BookingRepository>().getPaymentDetail(widget.paymentId);
  }

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<PaymentRecord>(
            future: _future,
            builder: (context, snapshot) {
              final p = snapshot.data ?? widget.initial;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Chi tiết thanh toán',
                          style: AppTextStyles.heading3,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _row('Mã hoá đơn', p.invoiceNumber ?? '--'),
                  _row('Trạng thái', p.status ?? '--'),
                  _row('Phương thức', p.paymentMethod ?? 'BANK_TRANSFER'),
                  _row('Số tiền', Formatters.vnd(p.amount), bold: true),
                  if (p.sepayTransactionId != null)
                    _row('Mã GD SePay', p.sepayTransactionId!),
                  if (p.paidAt != null)
                    _row('Ngày thanh toán', Formatters.date(p.paidAt)),
                  if (p.createdAt != null)
                    _row('Ngày tạo', Formatters.date(p.createdAt)),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: const Text('Đóng'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            const Spacer(),
            Text(
              value,
              style: bold ? AppTextStyles.price : AppTextStyles.labelBold,
            ),
          ],
        ),
      );
}
