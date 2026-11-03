import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../data/payment_repository.dart';
import '../domain/payment_record.dart';
import 'payment_detail_page.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});
  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late Future<PaymentPage> _future;
  int _page = 0;
  @override
  void initState() {
    super.initState();
    _future = Future<PaymentPage>.sync(
      () => getIt<PaymentRepository>().history(_page),
    );
  }

  void _load(int page) => setState(() {
    _page = page;
    _future = Future<PaymentPage>.sync(
      () => getIt<PaymentRepository>().history(page),
    );
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Lịch sử thanh toán'),
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: () => _load(_page),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<PaymentPage>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(readableError(snapshot.error!)),
                  TextButton(
                    onPressed: () => _load(_page),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }
        final result = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: result.items.isEmpty
                  ? const Center(
                      child: Text('Bạn chưa có giao dịch thanh toán.'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _load(_page);
                        try {
                          await _future;
                        } catch (_) {
                          // The FutureBuilder renders this same failure with a retry action.
                        }
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: result.items.length,
                        separatorBuilder: (_, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final p = result.items[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(Formatters.vnd(p.amount)),
                            subtitle: Text('${p.statusLabel}\n${p.invoice}'),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      PaymentDetailPage(paymentId: p.id),
                                ),
                              );
                              if (mounted) _load(_page);
                            },
                          );
                        },
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _page > 0 ? () => _load(_page - 1) : null,
                    child: const Text('Trang trước'),
                  ),
                  Text('Trang ${_page + 1}'),
                  TextButton(
                    onPressed: !result.last ? () => _load(_page + 1) : null,
                    child: const Text('Trang sau'),
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
