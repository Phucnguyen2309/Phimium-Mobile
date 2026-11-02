import '../entities/review.dart';

abstract class ReviewRepository {
  /// GET /api/feedback/buddies/{buddyId}
  Future<List<Review>> getBuddyReviews(String buddyId);

  /// GET /api/feedback/me
  Future<List<Review>> getMyReviews();

  /// POST /api/feedback/registrations/{registrationId}
  Future<Review> createReview({
    required String bookingId,
    required int tourRating,
    String? tourComment,
    required int buddyRating,
    String? buddyComment,
  });
}
