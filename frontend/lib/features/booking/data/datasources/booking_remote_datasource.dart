import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';

/// Gọi RegistrationController + PaymentController của BE
class BookingRemoteDataSource {
  final DioClient _client;

  BookingRemoteDataSource(this._client);

  Future<Map<String, dynamic>> createRegistration(
    Map<String, dynamic> body,
  ) async {
    final response = await _client.dio.post(
      ApiConstants.registrations,
      data: body,
    );
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
    final response = await _client.dio.post(
      ApiConstants.cancelRegistration(id),
    );
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }

  Future<String> getPaymentStatus(String paymentId) async {
    final response = await _client.dio.get(
      '/api/payment/${Uri.encodeComponent(paymentId)}',
    );
    final data = unwrapData<Map>(response);
    return data['status'].toString();
  }

  Future<Map<String, dynamic>> createPayment(String registrationId) async {
    final response = await _client.dio.post(
      ApiConstants.createPayment(registrationId),
      data: {'paymentMethod': 'BANK_TRANSFER'},
    );
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }
}
