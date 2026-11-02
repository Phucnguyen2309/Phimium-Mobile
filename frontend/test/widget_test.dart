import 'package:flutter_test/flutter_test.dart';

import 'package:phimium_mobile/core/utils/formatters.dart';
import 'package:phimium_mobile/features/tour/data/models/tour_model.dart';
import 'package:phimium_mobile/features/tour/domain/entities/tour.dart';

void main() {
  test('Formatters định dạng thời lượng', () {
    expect(Formatters.duration(150), '2 giờ 30 phút');
    expect(Formatters.duration(60), '1 giờ');
    expect(Formatters.time('08:30:00'), '08:30');
  });

  test('Parse ActivityResponse của BE thành Tour', () {
    final tour = TourModel.tourFromJson({
      'id': 'abc',
      'title': 'Ăn đêm Chợ Lớn',
      'activityType': 'FOODTOUR',
      'participationFee': 350000,
      'tags': ['STREET_FOOD'],
      'departures': [
        {'departureId': 'd1', 'departureDate': '2099-01-01', 'startTime': '18:00:00'},
      ],
    });
    expect(tour.type, TourType.food);
    expect(tour.price, 350000);
    expect(tour.tags, ['Ẩm thực đường phố']);
    expect(tour.upcomingDepartures.length, 1);
  });
}
