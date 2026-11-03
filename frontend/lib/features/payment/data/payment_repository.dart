import '../../../core/network/dio_client.dart';
import '../../../core/network/api_result.dart';
import '../domain/payment_record.dart';

class PaymentRepository {
  final DioClient client;
  PaymentRepository(this.client);
  Future<PaymentPage> history(int page) async {
    final r = await client.dio.get(
      '/api/payment/me',
      queryParameters: {'page': page, 'size': 10},
    );
    return PaymentPage.fromJson(Map<String, dynamic>.from(unwrapData<Map>(r)));
  }

  Future<PaymentRecord> detail(String id) async {
    final r = await client.dio.get('/api/payment/${Uri.encodeComponent(id)}');
    return PaymentRecord.fromJson(
      Map<String, dynamic>.from(unwrapData<Map>(r)),
    );
  }

  Future<PaymentRecord> reconcile(String id) async {
    final r = await client.dio.post(
      '/api/payment/${Uri.encodeComponent(id)}/reconcile',
    );
    return PaymentRecord.fromJson(
      Map<String, dynamic>.from(unwrapData<Map>(r)),
    );
  }
}
