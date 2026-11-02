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
    return TourModel.detailFromJson(tourId, detailJson, fromList: fromList);
  }

  @override
  Future<List<MyTrip>> getMyTrips() async {
    final raw = await _remote.getMyTrips();
    return raw.map(TourModel.myTripFromJson).toList();
  }
}
