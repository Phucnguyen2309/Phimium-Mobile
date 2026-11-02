import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

/// Gọi FeedBackController của BE
class ReviewRepositoryImpl implements ReviewRepository {
  final DioClient _client;

  ReviewRepositoryImpl(this._client);

  static Review _fromJson(Map<String, dynamic> j) => Review(
        id: (j['feedbackId'] ?? '').toString(),
        reviewerName: j['reviewerName']?.toString(),
        buddyName: j['buddyName']?.toString(),
        tourTitle: j['activityTitle']?.toString(),
        tripRating: Formatters.toInt(j['tripRating']),
        tripComment: j['tripComment']?.toString(),
        buddyRating: Formatters.toInt(j['buddyRating']),
        buddyComment: j['buddyComment']?.toString(),
        createdAt: Formatters.toDate(j['createdAt']),
      );

  Future<List<Review>> _getList(String path) async {
    final response = await _client.dio.get(path);
    final raw = unwrapData<dynamic>(response);
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) => _fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<List<Review>> getBuddyReviews(String buddyId) =>
      _getList(ApiConstants.buddyReviews(buddyId));

  @override
  Future<List<Review>> getMyReviews() => _getList(ApiConstants.myReviews);

  @override
  Future<Review> createReview({
    required String bookingId,
    required int tourRating,
    String? tourComment,
    required int buddyRating,
    String? buddyComment,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.createReview(bookingId),
      data: {
        'tourRating': tourRating,
        'tourComment': tourComment,
        'buddyRating': buddyRating,
        'buddyComment': buddyComment,
      },
    );
    return _fromJson(Map<String, dynamic>.from(unwrapData<Map>(response)));
  }
}
