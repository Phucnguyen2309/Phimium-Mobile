import '../../../core/utils/formatters.dart';

class PaymentRecord {
  final String id, registrationId, invoice, status, currency;
  final String? transactionId;
  final String? receiptId;
  final double amount;
  final DateTime? createdAt, paidAt;
  const PaymentRecord({
    required this.id,
    required this.registrationId,
    required this.invoice,
    required this.status,
    required this.currency,
    required this.amount,
    this.transactionId,
    this.receiptId,
    this.createdAt,
    this.paidAt,
  });
  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
    id: json['id'].toString(),
    registrationId: json['registrationId'].toString(),
    invoice: json['invoiceNumber']?.toString() ?? '--',
    status: json['status']?.toString() ?? '',
    currency: json['currency']?.toString() ?? 'VND',
    amount: Formatters.toDouble(json['amount']) ?? 0,
    transactionId: json['providerTransactionId']?.toString(),
    receiptId: json['providerReceiptId']?.toString(),
    createdAt: Formatters.toDate(json['createdAt']),
    paidAt: Formatters.toDate(json['paidAt']),
  );
  bool get canReconcile => ['PENDING', 'EXPIRED', 'FAILED'].contains(status);
  String get statusLabel => paymentStatusLabel(status);
}

String paymentStatusLabel(String? status) => switch (status) {
  'PAID' => 'Thanh toán thành công',
  'PENDING' => 'Chờ xác nhận thanh toán',
  'EXPIRED' => 'Thanh toán đã hết hạn',
  'FAILED' => 'Thanh toán không thành công',
  'REVIEW_REQUIRED' => 'Cần đối soát thanh toán',
  _ => 'Chưa xác định trạng thái',
};

String paymentCheckMessage(String status) => switch (status) {
  'PENDING' => 'Đang chờ xác nhận thanh toán. Hệ thống sẽ tự kiểm tra lại. Nếu đã chuyển tiền, vui lòng không thanh toán lần nữa.',
  'REVIEW_REQUIRED' =>
    'Giao dịch cần được hỗ trợ đối soát. Vui lòng không thanh toán lại.',
  _ => paymentStatusLabel(status),
};

class PaymentPage {
  final List<PaymentRecord> items;
  final int page;
  final bool last;
  const PaymentPage(this.items, this.page, this.last);
  factory PaymentPage.fromJson(Map<String, dynamic> json) => PaymentPage(
    (json['content'] as List)
        .map((j) => PaymentRecord.fromJson(Map<String, dynamic>.from(j)))
        .toList(),
    (json['number'] as num).toInt(),
    json['last'] == true,
  );
}
