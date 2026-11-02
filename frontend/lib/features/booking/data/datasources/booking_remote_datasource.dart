import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';

/// Gọi RegistrationController + PricingController + PaymentController của BE
class BookingRemoteDataSource {
  final DioClient _client;

  BookingRemoteDataSource(this._client);

  Future<Map<String, dynamic>> getPriceQuote(Map<String, dynamic> body) async {
    final response = await _client.dio.post(ApiConstants.pricingQuote, data: body);
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }

  Future<Map<String, dynamic>> createRegistration(Map<String, dynamic> body) async {
    final response = await _client.dio.post(ApiConstants.registrations, data: body);
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }

  Future<List<Map<String, dynamic>>> getMyRegistrations() async {
    final response = await _client.dio.get(ApiConstants.myRegistrations);
    final raw = unwrapData<dynamic>(response);
    return raw is List
        ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> cancelRegistration(String id) async {
    final response = await _client.dio.post(ApiConstants.cancelRegistration(id));
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }

  Future<Map<String, dynamic>> checkInRegistration(String id) async {
    final response = await _client.dio.post(ApiConstants.checkInRegistration(id));
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }

  Future<Map<String, dynamic>> createPayment(String registrationId) async {
    final response = await _client.dio.post(
      ApiConstants.createPayment(registrationId),
      data: {'paymentMethod': 'BANK_TRANSFER'},
    );
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }

  Future<List<Map<String, dynamic>>> getMyPayments({int page = 0, int size = 20}) async {
    final response = await _client.dio.get(
      ApiConstants.myPayments,
      queryParameters: {'page': page, 'size': size},
    );
    final raw = unwrapData<dynamic>(response);
    if (raw is Map && raw['content'] is List) {
      return (raw['content'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return raw is List
        ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> getPaymentDetail(String paymentId) async {
    final response = await _client.dio.get(ApiConstants.paymentDetail(paymentId));
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }
}
