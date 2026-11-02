import '../../../../core/utils/formatters.dart';
import '../../../tour/data/models/tour_model.dart';
import '../../../tour/domain/entities/tour.dart';
import '../../domain/entities/buddy_schedule.dart';
import '../../domain/repositories/buddy_repository.dart';
import '../datasources/buddy_remote_datasource.dart';

class BuddyRepositoryImpl implements BuddyRepository {
  final BuddyRemoteDataSource _remote;

  BuddyRepositoryImpl(this._remote);

  @override
  Future<List<BuddySchedule>> getMySchedules() async {
    final raw = await _remote.getMySchedules();
    return raw.map(_scheduleFromJson).toList();
  }

  @override
  Future<List<TourMember>> getTourMembers(String departureId) async {
    final raw = await _remote.getTourMembers(departureId);
    return raw.map(_memberFromJson).toList();
  }

  @override
  Future<TourMember> checkInMember(
    String departureId,
    String registrationId,
  ) async {
    final raw = await _remote.checkInMember(departureId, registrationId);
    return _memberFromJson(raw);
  }

  @override
  Future<String> updateMyStatus(String status) async {
    final raw = await _remote.updateMyStatus(status);
    return (raw['status'] ?? status).toString();
  }

  @override
  Future<List<Tour>> getActivitiesByBuddy(String buddyId) async {
    final raw = await _remote.getActivitiesByBuddy(buddyId);
    return raw.map(TourModel.tourFromJson).toList();
  }

  static BuddySchedule _scheduleFromJson(Map<String, dynamic> j) => BuddySchedule(
        departureId: (j['departureId'] ?? j['id'] ?? '').toString(),
        activityId: j['activityId']?.toString(),
        activityTitle: (j['activityTitle'] ?? j['title'] ?? 'Tour').toString(),
        departureDate: Formatters.toDate(j['departureDate']),
        startTime: j['startTime']?.toString(),
        endTime: j['endTime']?.toString(),
        location: (j['location'] ?? j['locationName'])?.toString(),
        status: j['status']?.toString(),
        totalGuests: Formatters.toInt(j['totalGuests']) ?? 0,
        checkedInCount: Formatters.toInt(j['checkedInCount']) ?? 0,
      );

  static TourMember _memberFromJson(Map<String, dynamic> j) => TourMember(
        registrationId: (j['registrationId'] ?? j['id'] ?? '').toString(),
        userId: j['userId']?.toString(),
        guestName: (j['guestName'] ?? j['fullName'] ?? 'Khách').toString(),
        phoneNumber: (j['phoneNumber'] ?? j['phone'])?.toString(),
        adultCount: Formatters.toInt(j['adultCount']) ?? 1,
        childCount: Formatters.toInt(j['childCount']) ?? 0,
        participantCount: Formatters.toInt(j['participantCount']) ??
            ((Formatters.toInt(j['adultCount']) ?? 1) +
                (Formatters.toInt(j['childCount']) ?? 0)),
        pickupLocation: j['pickupLocation']?.toString(),
        checkInStatus: j['checkInStatus']?.toString(),
        checkedInAt: Formatters.toDate(j['checkedInAt']),
      );
}

