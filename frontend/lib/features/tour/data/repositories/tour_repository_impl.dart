import '../../domain/entities/tour.dart';
import '../../domain/repositories/tour_repository.dart';
import '../datasources/tour_remote_datasource.dart';
import '../models/tour_model.dart';

class TourRepositoryImpl implements TourRepository {
  final TourRemoteDataSource _remote;

  /// Cache danh sách tour trong phiên để các màn hình dùng chung
  List<Tour>? _cache;

  TourRepositoryImpl(this._remote);

  @override
  Future<List<Tour>> getTours({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    final raw = await _remote.getTours();
    _cache = raw.map(TourModel.tourFromJson).toList();
    return _cache!;
  }

  @override
  Future<TourDetail> getTourDetail(String tourId) async {
    final detailJson = await _remote.getTourDetail(tourId);
    Tour? fromList;
    try {
      final tours = await getTours();
      for (final t in tours) {
        if (t.id == tourId) {
          fromList = t;
          break;
        }
      }
    } catch (_) {
      // Không có danh sách thì vẫn hiển thị detail, chỉ thiếu lịch khởi hành
    }

    // Nếu detail chưa có itineraryStops thì gọi thêm GET /api/activity/{id}/itinerary-stops
    if (detailJson['itineraryStops'] == null &&
        (fromList == null || fromList.itineraryStops.isEmpty)) {
      try {
        final stops = await _remote.getItineraryStops(tourId);
        if (stops.isNotEmpty) {
          detailJson['itineraryStops'] = stops;
        }
      } catch (_) {}
    }

    return TourModel.detailFromJson(tourId, detailJson, fromList: fromList);
  }

  static const String _defaultInstructions =
      'Vui lòng tập trung đúng giờ tại điểm hẹn và tuân thủ theo sự hướng dẫn của Buddy.';

  /// Khớp với GuidelineConstants.HARDCODED_SAFETY_RULES bên BE
  static const String _defaultSafetyRules =
      '1. Tuyệt đối không chia sẻ thông tin cá nhân nhạy cảm (SĐT, Địa chỉ nhà) ở lần gặp đầu tiên.\n'
      '2. Tôn trọng không gian cá nhân và sự khác biệt của các thành viên khác.\n'
      '3. Luôn báo cáo cho Buddy hoặc Admin nếu có bất kỳ hành vi quấy rối, thiếu chuẩn mực nào.\n'
      '4. Tuân thủ tuyệt đối sự điều phối của Buddy trong suốt thời gian diễn ra hoạt động.\n'
      '5. Phimium không hỗ trợ và không chịu trách nhiệm cho các cuộc gặp gỡ riêng lẻ 1-1 phát sinh ngoài nền tảng.';

  @override
  Future<TourGuideline?> getTourGuidelines(
    String tourId, {
    String lang = 'vi',
  }) async {
    final raw = await _remote.getTourGuidelines(tourId, lang: lang);
    final instructions =
        (raw?['instructions'] ?? raw?['content'])?.toString().trim();
    final safety =
        (raw?['safetyGuidelines'] ?? raw?['safetyRules'])?.toString().trim();

    return TourGuideline(
      id: (raw?['id'] ?? tourId).toString(),
      title: (raw?['title'] ?? 'Cẩm nang & Quy tắc an toàn').toString(),
      content: (instructions != null && instructions.isNotEmpty)
          ? instructions
          : _defaultInstructions,
      safetyRules: (safety != null && safety.isNotEmpty)
          ? safety
          : _defaultSafetyRules,
      languageCode: raw?['languageCode']?.toString() ?? lang,
    );
  }

  @override
  Future<List<MyTrip>> getMyTrips() async {
    final raw = await _remote.getMyTrips();
    return raw.map(TourModel.myTripFromJson).toList();
  }
}
