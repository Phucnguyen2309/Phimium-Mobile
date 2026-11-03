import 'package:equatable/equatable.dart';

/// Ca dẫn tour được phân công cho Buddy (BuddyScheduleResponse)
class BuddySchedule extends Equatable {
  final String departureId;
  final String? activityId;
  final String activityTitle;
  final DateTime? departureDate;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? status; // UPCOMING, IN_PROGRESS, COMPLETED
  final int totalGuests;
  final int checkedInCount;

  const BuddySchedule({
    required this.departureId,
    this.activityId,
    required this.activityTitle,
    this.departureDate,
    this.startTime,
    this.endTime,
    this.location,
    this.status,
    this.totalGuests = 0,
    this.checkedInCount = 0,
  });

  static String statusLabel(String? status) {
    switch (status) {
      case 'UPCOMING':
        return 'Sắp tới';
      case 'IN_PROGRESS':
        return 'Đang diễn ra';
      case 'COMPLETED':
        return 'Hoàn thành';
      default:
        return status ?? 'Sắp tới';
    }
  }

  @override
  List<Object?> get props => [departureId, status, checkedInCount, totalGuests];
}

/// Khách tham gia trong một ca tour của Buddy (TourMemberResponse)
class TourMember extends Equatable {
  final String registrationId;
  final String? userId;
  final String guestName;
  final String? phoneNumber;
  final int adultCount;
  final int childCount;
  final int participantCount;
  final String? pickupLocation;
  final String? checkInStatus; // NOT_CHECKED_IN, CHECKED_IN
  final DateTime? checkedInAt;

  const TourMember({
    required this.registrationId,
    this.userId,
    required this.guestName,
    this.phoneNumber,
    this.adultCount = 1,
    this.childCount = 0,
    this.participantCount = 1,
    this.pickupLocation,
    this.checkInStatus,
    this.checkedInAt,
  });

  bool get isCheckedIn =>
      checkInStatus == 'PRESENT' ||
      checkInStatus == 'CHECKED_IN' ||
      checkedInAt != null;

  @override
  List<Object?> get props => [registrationId, checkInStatus, checkedInAt];
}

