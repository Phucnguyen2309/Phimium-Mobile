import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';

/// Tour remote data source - gọi ActivityController & GuidelineController của BE
class TourRemoteDataSource {
  final DioClient _client;

  TourRemoteDataSource(this._client);

  Future<List<Map<String, dynamic>>> getTours() async {
    final response = await _client.dio.get(ApiConstants.tours);
    return _asList(unwrapData<dynamic>(response));
  }

  Future<Map<String, dynamic>> getTourDetail(String id) async {
    final response = await _client.dio.get(ApiConstants.tourDetail(id));
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }

  Future<List<Map<String, dynamic>>> getItineraryStops(String tourId) async {
    final response = await _client.dio.get(ApiConstants.itineraryStops(tourId));
    return _asList(unwrapData<dynamic>(response));
  }

  Future<Map<String, dynamic>?> getTourGuidelines(
    String tourId, {
    String lang = 'vi',
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.tourGuidelines(tourId),
        queryParameters: {'lang': lang},
      );
      final data = unwrapData<dynamic>(response);
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMyTrips() async {
    final response = await _client.dio.get(ApiConstants.joinedTours);
    return _asList(unwrapData<dynamic>(response));
  }

  static List<Map<String, dynamic>> _asList(dynamic raw) => raw is List
      ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];
}
