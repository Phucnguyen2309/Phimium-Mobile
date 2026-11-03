import '../../../tour/domain/entities/tour.dart';
import '../entities/buddy_schedule.dart';

abstract class BuddyRepository {
  /// GET /api/buddies/me/schedules
  Future<List<BuddySchedule>> getMySchedules();

  /// GET /api/buddies/me/schedules/{departureId}/members
  Future<List<TourMember>> getTourMembers(String departureId);

  /// POST /api/buddies/me/schedules/{departureId}/members/{registrationId}/check-in
  Future<TourMember> checkInMember(String departureId, String registrationId);

  /// PATCH /api/buddies/me/status?status=ACTIVE|INACTIVE
  Future<String> updateMyStatus(String status);

  /// GET /api/buddies/getActivityByBuddy?buddy={buddyId}
  Future<List<Tour>> getActivitiesByBuddy(String buddyId);
}

