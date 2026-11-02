import '../entities/booking.dart';

abstract class BookingRepository {
  /// POST /api/v1/registrations
  Future<Booking> createBooking({
    required String departureId,
    required int adultCount,
    required int childCount,
    required bool safetyTermsAccepted,
    String? pickupLocation,
    String? couponCode,
  });

  /// GET /api/v1/registrations/me
  Future<List<Booking>> getMyBookings();

  /// POST /api/v1/registrations/{id}/cancel
  Future<Booking> cancelBooking(String bookingId);

  /// POST /api/payment/registration/{id}
  Future<PaymentCheckout> createPayment(String bookingId);
}
