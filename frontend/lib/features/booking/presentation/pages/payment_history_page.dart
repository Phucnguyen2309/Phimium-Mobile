import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../../payment/domain/payment_record.dart';
import '../../../payment/data/payment_repository.dart';
import '../../../payment/presentation/payment_detail_page.dart';
import '../../../payment/presentation/payment_widgets.dart';

/// Lịch sử thanh toán của khách - GET /api/payment/me & GET /api/payment/{id}
class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late Future<PaymentPage> _future;
  int _page = 0;
  String _sort = 'createdAt,desc';
  static const _sortOptions = {
    'createdAt,desc': 'Mới nhất',
    'createdAt,asc': 'Cũ nhất',
    'amount,asc': 'Số tiền tăng dần',
    'amount,desc': 'Số tiền giảm dần',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = Future<PaymentPage>.sync(
      () => getIt<PaymentRepository>().history(_page, sort: _sort),
    );
  }

  Future<void> _showDetail(PaymentRecord item) async {
    await showDialog<void>(
      context: context,
      builder: (_) => PaymentDetailPage(paymentId: item.id, asDialog: true),
    );
    if (mounted) setState(_load);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(AppStrings.paymentHistory),
      actions: [
        IconButton(
          tooltip: 'Cập nhật lịch sử',
          onPressed: () => setState(_load),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryMuted,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giao dịch của bạn',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppDimens.xs),
                        Text(
                          'Theo dõi thanh toán cho từng chuyến đi.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 16, 8),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                children: [
                  Text('Các giao dịch', style: AppTextStyles.caption),
                  PopupMenuButton<String>(
                    tooltip: 'Sắp xếp giao dịch',
                    initialValue: _sort,
                    onSelected: (value) {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _sort = value;
                        _page = 0;
                        _load();
                      });
                    },
                    itemBuilder: (context) => _sortOptions.entries
                        .map(
                          (entry) => CheckedPopupMenuItem<String>(
                            value: entry.key,
                            checked: _sort == entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sort_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _sortOptions[_sort]!,
                            style: AppTextStyles.labelMedium,
                          ),
                          const Icon(Icons.expand_more_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(_load);
                  try {
                    await _future;
                  } catch (_) {
                    // AsyncView displays the same failure with a retry action.
                  }
                },
                child: AsyncView<PaymentPage>(
                  future: _future,
                  onRetry: () => setState(_load),
                  isEmpty: (page) => page.items.isEmpty && _page == 0,
                  empty: const EmptyStateWidget(
                    message: 'Chưa có giao dịch.\nThanh toán cho chuyến đi sẽ xuất hiện tại đây.',
                    icon: Icons.receipt_long_outlined,
                  ),
                  builder: (context, page) => ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: page.items.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppDimens.md),
                    itemBuilder: (context, i) {
                      if (i == page.items.length) return _pagination(page);
                      final payment = page.items[i];
                      return Material(
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusLg,
                          ),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showDetail(payment),
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimens.df),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.luggage_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppDimens.sm),
                                    Expanded(
                                      child: Text(
                                        payment.tourTitle?.trim().isNotEmpty ==
                                                true
                                            ? payment.tourTitle!
                                            : 'Thanh toán chuyến đi',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelBold,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimens.sm),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.neutral,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                if (payment.departureDate != null) ...[
                                  const SizedBox(height: AppDimens.sm),
                                  Text(
                                    paymentDepartureLabel(
                                      payment.departureDate!,
                                      payment.startTime,
                                    ),
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                                const SizedBox(height: AppDimens.xs),
                                Text(
                                  paymentInvoiceLabel(payment.invoice),
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: AppDimens.md),
                                Wrap(
                                  spacing: AppDimens.md,
                                  runSpacing: AppDimens.sm,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      Formatters.vnd(payment.amount),
                                      style: AppTextStyles.heading3.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    PaymentStatusBadge(status: payment.status),
                                  ],
                                ),
                                const SizedBox(height: AppDimens.sm),
                                Text(
                                  'Giao dịch ${paymentDateTime(payment.paidAt ?? payment.createdAt)}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _pagination(PaymentPage page) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppDimens.sm,
      children: [
        IconButton(
          tooltip: 'Trang trước',
          onPressed: _page == 0
              ? null
              : () => setState(() {
                  _page--;
                  _load();
                }),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Text('Trang ${_page + 1}', style: AppTextStyles.labelMedium),
        IconButton(
          tooltip: 'Trang sau',
          onPressed: page.last
              ? null
              : () => setState(() {
                  _page++;
                  _load();
                }),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    ),
  );
}
