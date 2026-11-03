import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remote;

  BookingRepositoryImpl(this._remote);

  @override
  Future<Booking> createBooking({
    required String departureId,
    required int adultCount,
    required int childCount,
    required bool safetyTermsAccepted,
    String? pickupLocation,
    String? couponCode,
  }) async {
    final body = <String, dynamic>{
      'departureId': departureId,
      'adultCount': adultCount,
      'childCount': childCount,
      'isSafetyTermsAccepted': safetyTermsAccepted,
      if (pickupLocation != null && pickupLocation.isNotEmpty)
        'pickupLocation': pickupLocation,
      if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
    };
    return BookingModel.fromJson(await _remote.createRegistration(body));
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    final raw = await _remote.getMyRegistrations();
    return raw.map(BookingModel.fromJson).toList();
  }

  @override
  Future<Booking> cancelBooking(String bookingId) async =>
      BookingModel.fromJson(await _remote.cancelRegistration(bookingId));

  @override
  Future<String> getPaymentStatus(String paymentId) =>
      _remote.getPaymentStatus(paymentId);

  @override
  Future<PaymentCheckout> createPayment(String bookingId) async =>
      BookingModel.paymentFromJson(await _remote.createPayment(bookingId));
}
