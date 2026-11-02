import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';

class BookingModel {
  BookingModel._();

  /// RegistrationResponse
  static Booking fromJson(Map<String, dynamic> j) {
    final departure = j['departure'] is Map ? Map<String, dynamic>.from(j['departure']) : null;
    final activity = departure?['activity'] is Map
        ? Map<String, dynamic>.from(departure!['activity'])
        : null;
    final buddy = j['buddy'] is Map ? Map<String, dynamic>.from(j['buddy']) : null;

    return Booking(
      id: (j['registrationId'] ?? '').toString(),
      status: j['status']?.toString(),
      tourId: activity?['activityId']?.toString(),
      tourTitle: activity?['title']?.toString(),
      departureDate: Formatters.toDate(departure?['departureDate']),
      startTime: departure?['startTime']?.toString(),
      adultCount: Formatters.toInt(j['adultCount']) ?? 1,
      childCount: Formatters.toInt(j['childCount']) ?? 0,
      pickupLocation: j['pickupLocation']?.toString(),
      subtotal: Formatters.toDouble(j['subtotal']),
      discountAmount: Formatters.toDouble(j['discountAmount']),
      totalAmount: Formatters.toDouble(j['totalAmount']),
      buddyName: buddy?['name']?.toString(),
      paymentExpiresAt: Formatters.toDate(j['paymentExpiresAt']),
      checkInStatus: j['checkInStatus']?.toString(),
      checkedInAt: Formatters.toDate(j['checkedInAt']),
    );
  }

  /// PriceQuoteResponse
  static PriceQuote quoteFromJson(Map<String, dynamic> j) => PriceQuote(
        adultUnitPrice: Formatters.toDouble(j['adultUnitPrice']),
        childUnitPrice: Formatters.toDouble(j['childUnitPrice']),
        subtotal: Formatters.toDouble(j['subtotal']),
        discountAmount: Formatters.toDouble(j['discountAmount']),
        totalAmount: Formatters.toDouble(j['totalAmount']),
        appliedCouponCode: j['appliedCouponCode']?.toString(),
        message: j['message']?.toString(),
      );

  /// CreatePaymentResponse
  static PaymentCheckout paymentFromJson(Map<String, dynamic> j) => PaymentCheckout(
        paymentId: (j['paymentId'] ?? '').toString(),
        invoiceNumber: j['invoiceNumber']?.toString(),
        amount: Formatters.toDouble(j['amount']),
        status: j['status']?.toString(),
        checkoutUrl: j['checkoutUrl']?.toString(),
        fields: j['fields'] is Map
            ? (j['fields'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
            : const {},
      );

  /// PaymentResponse
  static PaymentRecord paymentRecordFromJson(Map<String, dynamic> j) => PaymentRecord(
        id: (j['id'] ?? j['paymentId'] ?? '').toString(),
        registrationId: j['registrationId']?.toString(),
        invoiceNumber: j['invoiceNumber']?.toString(),
        amount: Formatters.toDouble(j['amount']),
        status: j['status']?.toString(),
        paymentMethod: j['paymentMethod']?.toString(),
        sepayOrderId: j['sepayOrderId']?.toString(),
        sepayTransactionId: j['sepayTransactionId']?.toString(),
        paidAt: Formatters.toDate(j['paidAt']),
        createdAt: Formatters.toDate(j['createdAt']),
      );
}
