import 'package:equatable/equatable.dart';

/// Trạng thái đơn đặt tour - enum RegistrationStatus của BE
class BookingStatus {
  BookingStatus._();

  static String label(String? status) {
    switch (status) {
      case 'WAITING_FOR_BUDDY':
        return 'Đang tìm Buddy';
      case 'BUDDY_ASSIGNED':
        return 'Đã có Buddy';
      case 'PENDING_PAYMENT':
        return 'Chờ thanh toán';
      case 'PAYMENT_REVIEW':
        return 'Đang xác nhận thanh toán';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'IN_PROGRESS':
        return 'Đang diễn ra';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status ?? '--';
    }
  }
}

/// Đơn đặt tour (RegistrationResponse)
class Booking extends Equatable {
  final String id;
  final String? status;
  final String? tourId;
  final String? tourTitle;
  final DateTime? departureDate;
  final String? startTime;
  final int adultCount;
  final int childCount;
  final String? pickupLocation;
  final double? subtotal;
  final double? discountAmount;
  final double? totalAmount;
  final String? buddyName;
  final DateTime? paymentExpiresAt;
  final String? checkInStatus;
  final DateTime? checkedInAt;

  const Booking({
    required this.id,
    this.status,
    this.tourId,
    this.tourTitle,
    this.departureDate,
    this.startTime,
    this.adultCount = 1,
    this.childCount = 0,
    this.pickupLocation,
    this.subtotal,
    this.discountAmount,
    this.totalAmount,
    this.buddyName,
    this.paymentExpiresAt,
    this.checkInStatus,
    this.checkedInAt,
  });

  bool get canPay => status == 'PENDING_PAYMENT';
  bool get canReview => status == 'COMPLETED';
  bool get isCheckedIn => checkInStatus == 'CHECKED_IN' || checkedInAt != null;
  bool get canCheckIn => status == 'CONFIRMED' && !isCheckedIn;

  @override
  List<Object?> get props => [id, status, checkInStatus];
}

/// Báo giá tạm tính & áp mã giảm giá (PriceQuoteResponse)
class PriceQuote extends Equatable {
  final double? adultUnitPrice;
  final double? childUnitPrice;
  final double? subtotal;
  final double? discountAmount;
  final double? totalAmount;
  final String? appliedCouponCode;
  final String? message;

  const PriceQuote({
    this.adultUnitPrice,
    this.childUnitPrice,
    this.subtotal,
    this.discountAmount,
    this.totalAmount,
    this.appliedCouponCode,
    this.message,
  });

  @override
  List<Object?> get props => [subtotal, discountAmount, totalAmount, appliedCouponCode];
}

/// Thông tin thanh toán (CreatePaymentResponse)
class PaymentCheckout extends Equatable {
  final String paymentId;
  final String? invoiceNumber;
  final double? amount;
  final String? status;
  final String? checkoutUrl;
  final Map<String, String> fields;

  const PaymentCheckout({
    required this.paymentId,
    this.invoiceNumber,
    this.amount,
    this.status,
    this.checkoutUrl,
    this.fields = const {},
  });

  @override
  List<Object?> get props => [paymentId];
}

/// Lịch sử / Chi tiết giao dịch thanh toán (PaymentResponse)
class PaymentRecord extends Equatable {
  final String id;
  final String? registrationId;
  final String? invoiceNumber;
  final double? amount;
  final String? status;
  final String? paymentMethod;
  final String? sepayOrderId;
  final String? sepayTransactionId;
  final DateTime? paidAt;
  final DateTime? createdAt;

  const PaymentRecord({
    required this.id,
    this.registrationId,
    this.invoiceNumber,
    this.amount,
    this.status,
    this.paymentMethod,
    this.sepayOrderId,
    this.sepayTransactionId,
    this.paidAt,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, status];
}
