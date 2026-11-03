import 'package:equatable/equatable.dart';

/// Loại tour - khớp enum TourType của BE (FOODTOUR, HISTORYTOUR)
enum TourType {
  food('FOODTOUR', 'Food tour'),
  history('HISTORYTOUR', 'History tour'),
  unknown('', 'Tour');

  final String apiValue;
  final String label;
  const TourType(this.apiValue, this.label);

  static TourType fromApi(String? value) => TourType.values.firstWhere(
        (t) => t.apiValue == value,
        orElse: () => TourType.unknown,
      );
}

/// Tour entity - Domain layer (ActivityResponse của BE)
class Tour extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TourType type;
  final String? thumbnailUrl;
  final String? locationName;
  final String? address;
  final double? price;
  final double? childPrice;
  final int? maxParticipants;
  final List<String> tags;
  final List<ItineraryStop> itineraryStops;
  final List<TourDeparture> departures;
  final String? status;

  const Tour({
    required this.id,
    required this.title,
    this.description,
    this.type = TourType.unknown,
    this.thumbnailUrl,
    this.locationName,
    this.address,
    this.price,
    this.childPrice,
    this.maxParticipants,
    this.tags = const [],
    this.itineraryStops = const [],
    this.departures = const [],
    this.status,
  });

  /// Tổng thời lượng ước tính theo lịch trình (phút)
  int get totalDurationMinutes => itineraryStops.fold(
        0,
        (sum, s) => sum + (s.durationMinutes ?? 0),
      );

  /// Các lịch khởi hành còn mở, từ hôm nay trở đi
  List<TourDeparture> get upcomingDepartures {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final list = departures.where((d) {
      if (d.date == null) return false;
      final status = (d.status ?? '').toUpperCase();
      if (status == 'CANCELLED' || status == 'COMPLETED' || status == 'CLOSED') {
        return false;
      }
      final day = DateTime(d.date!.year, d.date!.month, d.date!.day);
      if (day.isBefore(start)) return false;
      if (day.isAtSameMomentAs(start)) {
        final timeStr = d.endTime ?? d.startTime;
        if (timeStr != null && timeStr.isNotEmpty) {
          final parts = timeStr.split(':');
          if (parts.length >= 2) {
            final h = int.tryParse(parts[0]) ?? 23;
            final m = int.tryParse(parts[1]) ?? 59;
            if (DateTime(day.year, day.month, day.day, h, m).isBefore(now)) {
              return false;
            }
          }
        }
      }
      return true;
    }).toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));
    return list;
  }

  @override
  List<Object?> get props => [id, title];
}

/// Chi tiết tour (ActivityDetailResponse + departures)
class TourDetail extends Equatable {
  final Tour tour;
  final List<String> imageUrls;
  final String? hostBuddyId;
  final String? hostBuddyName;
  final String? hostAvatarUrl;
  final String? hostIntroduction;
  final int averageRating;

  const TourDetail({
    required this.tour,
    this.imageUrls = const [],
    this.hostBuddyId,
    this.hostBuddyName,
    this.hostAvatarUrl,
    this.hostIntroduction,
    this.averageRating = 0,
  });

  @override
  List<Object?> get props => [tour.id];
}

/// Điểm dừng trong lịch trình (ItineraryStopResponse)
class ItineraryStop extends Equatable {
  final String id;
  final int order;
  final String title;
  final String? description;
  final int? offsetMinutes;
  final int? durationMinutes;
  final String? imageUrl;

  const ItineraryStop({
    required this.id,
    required this.order,
    required this.title,
    this.description,
    this.offsetMinutes,
    this.durationMinutes,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, order];
}

/// Lịch khởi hành (ActivityDepartureResponse)
class TourDeparture extends Equatable {
  final String id;
  final DateTime? date;
  final String? startTime; // "HH:mm:ss"
  final String? endTime;
  final int? capacity;
  final String? status;

  const TourDeparture({
    required this.id,
    this.date,
    this.startTime,
    this.endTime,
    this.capacity,
    this.status,
  });

  @override
  List<Object?> get props => [id];
}

/// Cẩm nang & quy tắc an toàn của tour (GlobalGuidelineResponse)
class TourGuideline extends Equatable {
  final String id;
  final String title;
  final String? content;
  final String? safetyRules;
  final String? languageCode;

  const TourGuideline({
    required this.id,
    required this.title,
    this.content,
    this.safetyRules,
    this.languageCode,
  });

  @override
  List<Object?> get props => [id, title];
}

/// Chuyến đi đã đặt của user (MyActivityResponse)
class MyTrip extends Equatable {
  final String tourId;
  final String title;
  final TourType type;
  final String? thumbnailUrl;
  final DateTime? departureDate;
  final String? startTime;
  final String? endTime;
  final String? locationName;
  final String? status;
  final String? registrationId;
  final String? hostBuddyName;
  final String? hostAvatarUrl;

  const MyTrip({
    required this.tourId,
    required this.title,
    this.type = TourType.unknown,
    this.thumbnailUrl,
    this.departureDate,
    this.startTime,
    this.endTime,
    this.locationName,
    this.status,
    this.registrationId,
    this.hostBuddyName,
    this.hostAvatarUrl,
  });

  @override
  List<Object?> get props => [tourId, registrationId];
}
