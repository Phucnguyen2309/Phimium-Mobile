import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_feedback.dart';
import '../data/payment_repository.dart';
import '../domain/payment_record.dart';
import 'payment_widgets.dart';

class PaymentDetailPage extends StatefulWidget {
  final String paymentId;
  final bool asDialog;
  const PaymentDetailPage({
    super.key,
    required this.paymentId,
    this.asDialog = false,
  });
  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage>
    with WidgetsBindingObserver {
  PaymentRecord? _payment;
  String? _error, _notice;
  bool _loading = true;
  Timer? _refreshTimer;
  DateTime? _lastCheckedAt;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted &&
          !_loading &&
          _payment?.status == 'PENDING' &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
        _check();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_loading &&
        _payment?.status == 'PENDING') {
      _check();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _check({bool reconcile = false, bool notify = false}) async {
    String? feedback;
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
        _notice = null;
      });
    }
    try {
      final repo = getIt<PaymentRepository>();
      final p = reconcile
          ? await repo.reconcile(widget.paymentId)
          : await repo.detail(widget.paymentId);
      if (mounted) {
        setState(() {
          _payment = p;
          _lastCheckedAt = DateTime.now();
          _notice = paymentCheckMessage(p.status);
          feedback = 'Đã kiểm tra: ${paymentCheckMessage(p.status)}';
        });
      }
    } catch (e) {
      feedback = readableError(e);
      if (mounted) setState(() => _error = feedback);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        if (notify && feedback != null) {
          if (_error != null) {
            AppFeedback.error(context, feedback!);
          } else {
            AppFeedback.info(context, feedback!);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _payment;
    final body = _loading && p == null
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_loading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],
              if (p != null) ...[
                PaymentPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHUYẾN ĐI', style: AppTextStyles.caption),
                      const SizedBox(height: 8),
                      Text(
                        p.tourTitle?.trim().isNotEmpty == true
                            ? p.tourTitle!
                            : 'Thanh toán chuyến đi',
                        style: AppTextStyles.labelBold,
                      ),
                      if (p.departureDate != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          paymentDepartureLabel(p.departureDate!, p.startTime),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PaymentPanel(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: paymentStatusColor(p.status)
                              .withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          paymentStatusIcon(p.status),
                          color: paymentStatusColor(p.status),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p.statusLabel,
                        style: AppTextStyles.heading3,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text('Tổng thanh toán', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.vnd(p.amount),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paymentInvoiceLabel(p.invoice),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (p.status == 'PAID')
                  const PaymentNotice(
                    message: 'Khoản thanh toán đã được xác nhận. Bạn có thể xem chuyến đi trong Chuyến đi của tôi.',
                  )
                else if (_notice != null)
                  PaymentNotice(message: _notice!),
                const SizedBox(height: 16),
                PaymentPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin thanh toán',
                        style: AppTextStyles.labelBold,
                      ),
                      const SizedBox(height: 4),
                      PaymentReferenceRow(
                        label: 'Ngày tạo',
                        value: paymentDateTime(p.createdAt),
                      ),
                      if (p.paidAt != null)
                        PaymentReferenceRow(
                          label: 'Thời điểm ghi nhận',
                          value: paymentDateTime(p.paidAt),
                        ),
                      PaymentReferenceRow(label: 'Tiền tệ', value: p.currency),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PaymentPanel(
                  padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(
                      'Thông tin tham chiếu',
                      style: AppTextStyles.labelBold,
                    ),
                    subtitle: Text(
                      'Xem và sao chép mã đầy đủ',
                      style: AppTextStyles.caption,
                    ),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      PaymentReferenceRow(
                        label: 'Mã hóa đơn',
                        value: p.invoice,
                        copyable: true,
                      ),
                      PaymentReferenceRow(
                        label: 'Mã đặt tour',
                        value: p.registrationId,
                        copyable: true,
                      ),
                      if (p.transactionId != null)
                        PaymentReferenceRow(
                          label: 'Mã giao dịch',
                          value: p.transactionId!,
                          copyable: true,
                        ),
                      if (p.receiptId != null)
                        PaymentReferenceRow(
                          label: 'Mã biên nhận SePay',
                          value: p.receiptId!,
                          copyable: true,
                        ),
                    ],
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                PaymentNotice(message: _error!, isError: true),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _loading ? null : () => _check(notify: true),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  _loading ? 'Đang kiểm tra…' : 'Kiểm tra thanh toán',
                ),
              ),
              if (p?.canReconcile ?? false)
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => _check(reconcile: true, notify: true),
                  child: const Text(
                    'Đã thanh toán nhưng chưa cập nhật?',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_lastCheckedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Cập nhật lúc ${paymentDateTime(_lastCheckedAt)}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          );
    if (!widget.asDialog) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết thanh toán')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: body,
          ),
        ),
      );
    }
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: SizedBox(
        width: 420,
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 12, 0),
              child: Row(
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
                    tooltip: 'Đóng',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
