import '../../../../core/utils/formatters.dart';
import '../../domain/entities/tour.dart';

/// Chuyển JSON của BE thành entity tour
class TourModel {
  TourModel._();

  /// Nhãn tiếng Việt cho enum MatchingTag của BE
  static const Map<String, String> tagLabels = {
    'PHOTOGRAPHY': 'Chụp ảnh',
    'FOOD': 'Ẩm thực',
    'HISTORY': 'Lịch sử',
    'ARCHITECTURE': 'Kiến trúc',
    'LOCAL_CULTURE': 'Văn hóa địa phương',
    'SNACKS': 'Ăn vặt',
    'STREET_FOOD': 'Ẩm thực đường phố',
    'CHINESE_CUISINE': 'Món Hoa',
    'TRADITIONAL_FOOD': 'Món truyền thống',
    'CAFE': 'Cà phê',
    'OLD_NEIGHBORHOODS': 'Phố cổ',
    'HERITAGE': 'Di sản',
    'HIDDEN_GEMS': 'Địa điểm ít người biết',
    'RETRO': 'Hoài cổ',
    'CHILL': 'Thư giãn',
    'LIVELY': 'Sôi động',
  };

  static List<String> _tags(dynamic raw) => raw is List
      ? raw.map((e) => tagLabels[e.toString()] ?? e.toString()).toList()
      : const [];

  static List<Map<String, dynamic>> _list(dynamic raw) => raw is List
      ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : const [];

  static ItineraryStop stopFromJson(Map<String, dynamic> j) => ItineraryStop(
        id: (j['stopId'] ?? '').toString(),
        order: Formatters.toInt(j['stopOrder']) ?? 0,
        title: (j['title'] ?? '').toString(),
        description: j['description']?.toString(),
        offsetMinutes: Formatters.toInt(j['offsetMinutes']),
        durationMinutes: Formatters.toInt(j['durationMinutes']),
        imageUrl: j['imageUrl']?.toString(),
      );

  static List<ItineraryStop> _stops(dynamic raw) =>
      _list(raw).map(stopFromJson).toList()..sort((a, b) => a.order.compareTo(b.order));

  static TourDeparture departureFromJson(Map<String, dynamic> j) => TourDeparture(
        id: (j['departureId'] ?? '').toString(),
        date: Formatters.toDate(j['departureDate']),
        startTime: j['startTime']?.toString(),
        endTime: j['endTime']?.toString(),
        capacity: Formatters.toInt(j['capacity']),
        status: j['status']?.toString(),
      );

  /// ActivityResponse
  static Tour tourFromJson(Map<String, dynamic> j) => Tour(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        description: j['description']?.toString(),
        type: TourType.fromApi(j['activityType']?.toString()),
        thumbnailUrl: j['thumbnailUrl']?.toString(),
        locationName: j['locationName']?.toString(),
        address: j['address']?.toString(),
        price: Formatters.toDouble(j['participationFee']),
        childPrice: Formatters.toDouble(j['childParticipationFee']),
        maxParticipants: Formatters.toInt(j['maximumParticipants']),
        tags: _tags(j['tags']),
        itineraryStops: _stops(j['itineraryStops']),
        departures: _list(j['departures']).map(departureFromJson).toList(),
        status: j['status']?.toString(),
      );

  /// ActivityDetailResponse (BE không trả id & departures trong detail
  /// nên ghép thêm từ [fromList] nếu có)
  static TourDetail detailFromJson(
    String id,
    Map<String, dynamic> j, {
    Tour? fromList,
  }) {
    final tour = Tour(
      id: id,
      title: (j['title'] ?? fromList?.title ?? '').toString(),
      description: j['description']?.toString() ?? fromList?.description,
      type: fromList?.type ?? TourType.unknown,
      thumbnailUrl: j['thumbnailUrl']?.toString() ?? fromList?.thumbnailUrl,
      locationName: j['locationName']?.toString() ?? fromList?.locationName,
      address: j['address']?.toString() ?? fromList?.address,
      price: Formatters.toDouble(j['participationFee']) ?? fromList?.price,
      childPrice: fromList?.childPrice,
      maxParticipants: Formatters.toInt(j['maximumParticipants']) ?? fromList?.maxParticipants,
      tags: j['tags'] != null ? _tags(j['tags']) : (fromList?.tags ?? const []),
      itineraryStops: j['itineraryStops'] != null
          ? _stops(j['itineraryStops'])
          : (fromList?.itineraryStops ?? const []),
      departures: fromList?.departures ?? const [],
      status: fromList?.status,
    );

    final images = j['imageUrls'] is List
        ? (j['imageUrls'] as List).map((e) => e.toString()).toList()
        : <String>[];

    return TourDetail(
      tour: tour,
      imageUrls: images,
      hostBuddyId: j['hostBuddyId']?.toString(),
      hostBuddyName: j['hostBuddyName']?.toString(),
      hostAvatarUrl: j['avatarUrl']?.toString(),
      hostIntroduction: j['introduction']?.toString(),
      averageRating: Formatters.toInt(j['averageRating']) ?? 0,
    );
  }

  /// MyActivityResponse
  static MyTrip myTripFromJson(Map<String, dynamic> j) => MyTrip(
        tourId: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        type: TourType.fromApi(j['activityType']?.toString()),
        thumbnailUrl: j['thumbnailUrl']?.toString(),
        departureDate: Formatters.toDate(j['departureDate']),
        startTime: j['startTime']?.toString(),
        endTime: j['endTime']?.toString(),
        locationName: j['locationName']?.toString(),
        status: j['status']?.toString(),
        registrationId: j['registrationId']?.toString(),
        hostBuddyName: j['hostBuddyName']?.toString(),
        hostAvatarUrl: j['avatarUrl']?.toString(),
      );
}
