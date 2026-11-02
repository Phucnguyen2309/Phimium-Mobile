import '../entities/tour.dart';

/// Tour repository interface - Domain layer
abstract class TourRepository {
  /// GET /api/activity/getAll
  Future<List<Tour>> getTours({bool forceRefresh = false});

  /// GET /api/activity/{id} (+ ghép lịch khởi hành từ danh sách tour)
  Future<TourDetail> getTourDetail(String tourId);

  /// GET /api/v1/activities/{id}/guidelines
  Future<TourGuideline?> getTourGuidelines(String tourId, {String lang = 'vi'});

  /// GET /api/activity/joined (cần đăng nhập)
  Future<List<MyTrip>> getMyTrips();
}
