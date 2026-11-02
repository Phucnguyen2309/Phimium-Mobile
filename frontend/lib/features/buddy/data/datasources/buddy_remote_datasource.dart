import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';

/// Gọi BuddyController (/api/buddies) của BE
class BuddyRemoteDataSource {
  final DioClient _client;

  BuddyRemoteDataSource(this._client);

  /// GET /api/buddies/me/schedules
  Future<List<Map<String, dynamic>>> getMySchedules() async {
    final response = await _client.dio.get(ApiConstants.buddyMySchedules);
    return _asList(unwrapData<dynamic>(response));
  }

  /// GET /api/buddies/me/schedules/{departureId}/members
  Future<List<Map<String, dynamic>>> getTourMembers(String departureId) async {
    final response =
        await _client.dio.get(ApiConstants.buddyTourMembers(departureId));
    return _asList(unwrapData<dynamic>(response));
  }

  /// POST /api/buddies/me/schedules/{departureId}/members/{registrationId}/check-in
  Future<Map<String, dynamic>> checkInMember(
    String departureId,
    String registrationId,
  ) async {
    final response = await _client.dio.post(
      ApiConstants.buddyCheckInMember(departureId, registrationId),
    );
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }

  /// PATCH /api/buddies/me/status?status=ACTIVE|INACTIVE
  Future<Map<String, dynamic>> updateMyStatus(String status) async {
    final response = await _client.dio.patch(
      ApiConstants.buddyUpdateStatus,
      queryParameters: {'status': status},
    );
    return Map<String, dynamic>.from(unwrapData<Map>(response));
  }

  /// GET /api/buddies/getActivityByBuddy?buddy={buddyId}
  Future<List<Map<String, dynamic>>> getActivitiesByBuddy(String buddyId) async {
    final response = await _client.dio.get(
      ApiConstants.buddyActivities,
      queryParameters: {'buddy': buddyId},
    );
    return _asList(unwrapData<dynamic>(response));
  }

  static List<Map<String, dynamic>> _asList(dynamic raw) => raw is List
      ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];
}

