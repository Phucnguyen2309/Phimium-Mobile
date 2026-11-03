import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../data/payment_repository.dart';
import '../domain/payment_record.dart';

class PaymentDetailPage extends StatefulWidget {
  final String paymentId;
  const PaymentDetailPage({super.key, required this.paymentId});
  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage>
    with WidgetsBindingObserver {
  PaymentRecord? _payment;
  String? _error, _notice;
  bool _loading = true;
  Timer? _refreshTimer;
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
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(feedback!)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _payment;
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết thanh toán')),
      body: _loading && p == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (p != null) ...[
                  Text(
                    p.statusLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  _line('Mã hóa đơn', p.invoice),
                  _line('Mã đặt tour', p.registrationId),
                  _line('Số tiền', Formatters.vnd(p.amount)),
                  _line('Tiền tệ', p.currency),
                  _line('Ngày tạo', _dateTime(p.createdAt)),
                  if (p.paidAt != null)
                    _line('Thời điểm ghi nhận', _dateTime(p.paidAt)),
                  if (p.transactionId != null)
                    _line('Mã giao dịch', p.transactionId!),
                  if (p.receiptId != null)
                    _line('Mã biên nhận SePay', p.receiptId!),
                ],
                if (_notice != null)
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(_notice!),
                    ),
                  ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (_loading) const LinearProgressIndicator(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : () => _check(notify: true),
                  child: Text(
                    _loading
                        ? 'Đang kiểm tra thanh toán…'
                        : 'Kiểm tra thanh toán',
                  ),
                ),
                if (p?.canReconcile ?? false)
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => _check(reconcile: true, notify: true),
                    child: const Text('Đã thanh toán nhưng chưa cập nhật?'),
                  ),
              ],
            ),
    );
  }

  String _dateTime(DateTime? value) {
    if (value == null) return '--';
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '${Formatters.date(value)} $hour:$minute:$second';
  }

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(label), SelectableText(value)],
    ),
  );
}
